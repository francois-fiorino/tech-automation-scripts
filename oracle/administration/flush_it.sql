/*
===============================================================================
SCRIPT: flush_it.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/flush_it.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar variante FLUSH_IT baseada em razão de SQL_SUMMARY/Variable SGA.

FUNCIONAMENTO DETALHADO
  Consulta memória compartilhável e V$SGA; se razão supera PCT_FULL, executa ALTER SYSTEM FLUSH SHARED_POOL e grava DBA_RUNNING_STATS com COMMIT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme LIMITAÇÕES; roles não
  bastam para compilar dependências de rotinas armazenadas. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SQL_SUMMARY (customizada), V$SGA, DUAL, DBMS_SQL, DBA_RUNNING_STATS, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  FLUSH pode causar hard parse e degradação global; definer rights/grants EXECUTE precisam de revisão. Categorias/SQL_SUMMARY/DBA_RUNNING_STATS e estruturas internas, quando presentes, ainda exigem contrato. ASMM/AMM pode tornar tamanho configurado inadequado, mesmo positivo. KEEPs podem ter efeito parcial antes de falha; não há rollback de estado de shared pool. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Revisão de rotina somente; não chamar em produção.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Procedimento criado; chamada pode purgar shared pool e confirmar dados.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados ou sessão descritos
  acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 037 (2026-11-03): Limiar validado antes da coleta; base de memória ausente/zero falha explicitamente antes de FLUSH/KEEP; NATIVE e cleanup de cursores em exceção com RAISE. Política/cursores/commits existentes preservados. Casos de homologação: NULL, negativo,0,0.5,1,100,>100; baseNULL/zero; pacote/view ausente; falha duranteKEEP/PARSE/INSERT; cursor fechado; medir impacto só em laboratório descartável. Comentários/créditos históricos preservados. Não aprovado para implantação.

REFERÊNCIAS TÉCNICAS DA REVISÃO 037
 https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_SQL.html

AVISO DE RESPONSABILIDADE
AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de
qualquer utilização em produção. Sua execução é de responsabilidade do
profissional responsável pelo ambiente. Os mantenedores deste repositório não
se responsabilizam por indisponibilidade, perda de dados, alterações indevidas
ou outros impactos decorrentes de sua utilização.

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
CREATE OR REPLACE PROCEDURE flush_it ( pct_full IN NUMBER) AS
--
-- Cursor definitions
--
CURSOR get_share IS
 SELECT SUM(sharable_mem) FROM
  sql_summary;
--
CURSOR get_var IS
 SELECT value FROM v$sga WHERE name LIKE 'Var%';
--
CURSOR get_time IS 
 SELECT sysdate FROM dual;
--
-- Variable definitions
--
	todays_date DATE;
	mem_ratio 	NUMBER;
	share_mem 	NUMBER;
	variable_mem NUMBER;
	cur INTEGER:=NULL;
	sql_com 	VARCHAR2(60);
	row_proc 	NUMBER;
--
-- Procedure Body
--
BEGIN
 IF pct_full IS NULL OR pct_full<0 OR pct_full>100 THEN RAISE_APPLICATION_ERROR(-20020,'Limiar deve estar entre 0 e 100.'); END IF;
 OPEN get_share;
 OPEN get_var;
 FETCH get_share INTO share_mem;
dbms_output.put_line('share_mem: '||to_char(share_mem));
 FETCH get_var INTO variable_mem;
dbms_output.put_line('variable_mem: '||to_char(variable_mem));
 close get_share;
 close get_var;
 IF variable_mem IS NULL OR variable_mem<=0 THEN RAISE_APPLICATION_ERROR(-20022,'Base de memoria ausente/zero; heuristica nao aplicavel.'); END IF;
 mem_ratio:=share_mem/nullif(variable_mem,0);
dbms_output.put_line(to_char(mem_ratio));
 IF mem_ratio>(pct_full/100) THEN
  cur:=dbms_sql.open_cursor;
  sql_com:='ALTER SYSTEM FLUSH SHARED_POOL';
  dbms_sql.parse(cur,sql_com,dbms_sql.native);
  row_proc:=dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur); cur:=NULL;
  OPEN get_time;
  FETCH get_time INTO todays_date;
 CLOSE get_time;
  INSERT INTO dba_running_stats VALUES 
	(
	'Flush of Shared Pool',1,35,todays_date,0
	);
  COMMIT;
 END IF;
EXCEPTION WHEN OTHERS THEN
 BEGIN
  IF cur IS NOT NULL AND DBMS_SQL.IS_OPEN(cur) THEN DBMS_SQL.CLOSE_CURSOR(cur); cur:=NULL; END IF;
  IF get_share%ISOPEN THEN CLOSE get_share; END IF;
  IF get_var%ISOPEN THEN CLOSE get_var; END IF;
  IF get_time%ISOPEN THEN CLOSE get_time; END IF;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
 RAISE;
END;
/
