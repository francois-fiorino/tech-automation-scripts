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
  CREATE PROCEDURE, SELECT direto, ALTER SYSTEM e INSERT. View customizada ausente e contrato INSERT de cinco colunas deve ser validado. Purge pode provocar hard parses/indisponibilidade; razão não prova necessidade. Alternativas FLUSH_IT substituem mesmo objeto.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

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
  NULLIF no divisor, cursores estáticos fechados e terminador / adicionado; política de flush e COMMIT preservada para revisão. 
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
	cur 		INTEGER;
	sql_com 	VARCHAR2(60);
	row_proc 	NUMBER;
--
-- Procedure Body
--
BEGIN
 OPEN get_share;
 OPEN get_var;
 FETCH get_share INTO share_mem;
dbms_output.put_line('share_mem: '||to_char(share_mem));
 FETCH get_var INTO variable_mem;
dbms_output.put_line('variable_mem: '||to_char(variable_mem));
 close get_share;
 close get_var;
 mem_ratio:=share_mem/nullif(variable_mem,0);
dbms_output.put_line(to_char(mem_ratio));
 IF mem_ratio>(pct_full/100) THEN
  cur:=dbms_sql.open_cursor;
  sql_com:='ALTER SYSTEM FLUSH SHARED_POOL';
  dbms_sql.parse(cur,sql_com,dbms_sql.v7);
  row_proc:=dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);
  OPEN get_time;
  FETCH get_time INTO todays_date;
 CLOSE get_time;
  INSERT INTO dba_running_stats VALUES 
	(
	'Flush of Shared Pool',1,35,todays_date,0
	);
  COMMIT;
 END IF;
END;
/
