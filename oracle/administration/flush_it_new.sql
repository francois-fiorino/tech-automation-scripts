/*
===============================================================================
SCRIPT: flush_it_new.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/flush_it_new.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar variante FLUSH_IT que mantém objetos antes de purgar shared pool.

FUNCIONAMENTO DETALHADO
  Compara uso/configuração, faz KEEP de cursores reutilizados/sequências/objetos SYS internos, FLUSH e registro em DBA_RUNNING_STATS com COMMIT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SGASTAT, V$PARAMETER, SYS.V_$SQLAREA, SYS.DBA_SEQUENCES, SYS.X_$KGLOB, DBMS_SHARED_POOL, DBMS_SQL, DBA_RUNNING_STATS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE/grants diretos/ALTER SYSTEM. KEEP aumenta pressão sobre pool e purge dispara hard parse; ASMM/AMM configurado zero invalida heurística. SYS.X_$KGLOB depende de objeto/sinônimo autorizado e versão. Cursores/KEEPs podem falhar parcialmente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Revisão somente; não instalar junto das outras variantes FLUSH_IT.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Procedimento criado; chamada pode modificar keep/cache e confirmar histórico.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  conforme descritos. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF no divisor, buffers de nomes ampliados, cursores fechados e / adicionado; política de KEEP/purge preservada com créditos Steve Adams. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

AVISO DE RESPONSABILIDADE
Os scripts são disponibilizados para fins técnicos, educacionais e administrativos.
Antes da utilização, analise integralmente o código, compreenda seu funcionamento
e realize testes em ambiente controlado, preferencialmente desenvolvimento ou
homologação. Conteúdo fornecido no estado em que se encontra (AS IS), sem garantias
de funcionamento, compatibilidade, desempenho ou adequação a ambientes específicos.
A utilização ocorre por conta e risco de quem executa. Os mantenedores não assumem
responsabilidade por danos, perdas de dados, indisponibilidade ou outros impactos
decorrentes do uso, nos limites permitidos pela legislação aplicável.
===============================================================================
*/

/*  */
CREATE OR REPLACE PROCEDURE flush_it(
    p_free IN NUMBER, num_runs IN NUMBER) IS
--
CURSOR get_share IS
SELECT 
  LEAST(MAX(b.value)/(1024*1024),SUM(a.bytes)/(1024*1024))
   FROM v$sgastat a, v$parameter b
 WHERE (a.pool='shared pool'
 AND a.name <> ('free memory'))
 AND b.name = 'shared_pool_size';
--
CURSOR get_var IS
 SELECT  value/(1024*1024) 
 FROM v$parameter
 WHERE name = 'shared_pool_size';
--
CURSOR get_time IS 
 SELECT sysdate FROM dual;
--
-- Following cursors from Steve Adams Nice_flush
--
  CURSOR reused_cursors IS
    SELECT address || ',' || hash_value
    FROM sys.v_$sqlarea
    WHERE executions > num_runs;
  cursor_string varchar2(128);
--
  CURSOR cached_sequences IS
    SELECT  sequence_owner, sequence_name
    FROM  sys.dba_sequences
    WHERE cache_size > 0;
  sequence_owner varchar2(128);
  sequence_name varchar2(128);
--
  CURSOR candidate_objects IS
    SELECT kglnaobj, decode(kglobtyp, 6, 'Q', 'P')
    FROM sys.x_$kglob
    WHERE inst_id = userenv('Instance') AND
      kglnaown = 'SYS' AND kglobtyp in (6, 7, 8, 9);
  object_name varchar2(128);
  object_type char(1);
--
-- end of Steve Adams Cursors
--
  todays_date 	DATE;
  mem_ratio 	NUMBER;
  share_mem 	NUMBER;
  variable_mem 	NUMBER;
  cur 		INTEGER;
  sql_com 	VARCHAR2(60);
  row_proc 	NUMBER;
--
BEGIN
 OPEN get_share;
 OPEN get_var;
 FETCH get_share INTO share_mem;
 FETCH get_var INTO variable_mem;
 CLOSE get_share;
 CLOSE get_var;
 mem_ratio:=share_mem/nullif(variable_mem,0);
 IF mem_ratio>p_free/100 THEN
 --
 -- Following keep sections from Steve Adams nice_flush
 --
 BEGIN
  OPEN reused_cursors;
  LOOP
    FETCH reused_cursors INTO cursor_string;
    EXIT WHEN reused_cursors%notfound;   
    sys.dbms_shared_pool.keep(cursor_string, 'C');
  END LOOP;
  CLOSE reused_cursors;
 END;   
 BEGIN
  OPEN cached_sequences;
  LOOP
    FETCH cached_sequences INTO sequence_owner, sequence_name;
    EXIT WHEN cached_sequences%notfound;   
    sys.dbms_shared_pool.keep(sequence_owner || '.' || sequence_name, 'Q');
  END LOOP;
  CLOSE cached_sequences;
 END;   
 BEGIN
  OPEN candidate_objects;
  LOOP
    FETCH candidate_objects INTO object_name, object_type;
    EXIT WHEN candidate_objects%notfound;   
    sys.dbms_shared_pool.keep('SYS.' || object_name, object_type);
  END LOOP;
  CLOSE candidate_objects;
 END;   
 --
 -- end of Steve Adams section
 --
  cur:=DBMS_SQL.OPEN_CURSOR;
  sql_com:='ALTER SYSTEM FLUSH SHARED_POOL';
  DBMS_SQL.PARSE(cur,sql_com,dbms_sql.v7);
  row_proc:=DBMS_SQL.EXECUTE(cur);
  DBMS_SQL.CLOSE_CURSOR(cur);
  OPEN get_time;
  FETCH get_time INTO todays_date;
 CLOSE get_time;
  INSERT INTO dba_running_stats VALUES 
	(
	'Flush of Shared Pool',1,35,todays_date,0
	);
  COMMIT;
 END IF;
END flush_it;
/
