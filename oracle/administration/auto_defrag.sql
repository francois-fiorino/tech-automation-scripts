/*
===============================================================================
SCRIPT: auto_defrag.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _tablespace_scripts/auto_defrag.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar coletor/coalescência automática legada e submeter job.

FUNCIONAMENTO DETALHADO
  CREATE FREE_SPACE e DBA_RUNNING_STATS, cria AUTO_DEFRAG que loga/COALESCE/COMMIT; DBMS_JOB.SUBMIT para meia-noite diariamente.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e privilégios administrativos conforme limitações de cada arquivo. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_FREE_SPACE, FREE_SPACE, DBA_RUNNING_STATS, DBMS_SQL, DBMS_JOB, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE VIEW/TABLE/PROCEDURE, ALTER TABLESPACE/EXECUTE e grants diretos. Job precisa COMMIT para persistir submissão; commits dentro da rotina confirmam dados. Métodos DMT legados, broad scope e cleanup em erros inadequado. Colisão de views/histórico pode destruir/substituir contrato esperado.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Revisão somente; não instalar job em produção.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Objetos criados e job submetido na transação; execução posterior pode alterar tablespaces.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: pode gerar ou executar DDL/DML, expor hashes/segredos
  do banco consultado ou alterar sessão conforme descrito acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Cursor GET_FRAGS fechado no término normal; agendamento/commits/política preservados e não executados. 
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
create or replace  view free_space (
	tablespace, 
	file_id, 
	pieces, 
	free_bytes, 
	free_blocks, 
	largest_bytes,
	largest_blks,
	fsfi) 
as
select 
	tablespace_name, 
	file_id, 
	count(*),
	sum(bytes), 
	sum(blocks),
	max(bytes), 
	max(blocks),
	sqrt(max(blocks)/sum(blocks))*(100/sqrt(sqrt(count(blocks)))) 
from 
	sys.dba_free_space
group by 
	tablespace_name, 
	file_id
/
create table dba_running_stats (
NAME VARCHAR2(64),
VALUE NUMBER,
REP_ORDER NUMBER,
MEAS_DATE DATE,
delta number)
storage(initial 1m next 1m pctincrease 0)
/
CREATE OR REPLACE PROCEDURE auto_defrag AS
CURSOR get_frags IS
	SELECT 
		tablespace,
		COUNT(tablespace), 
		SUM(pieces)
	FROM free_space
	GROUP BY tablespace;
pieces		NUMBER;
files		NUMBER;
tbname		VARCHAR2(64);
sql_stmt	VARCHAR2(255);
cur		INTEGER;
rows		INTEGER;
PROCEDURE write_out(
  par_name  IN VARCHAR2,
  par_value IN NUMBER, 
  rep_ord   IN NUMBER, 
  m_date    IN DATE,
  par_delta IN NUMBER) IS
 BEGIN
  INSERT INTO dba_running_stats VALUES(
   par_name,par_value,rep_ord,m_date,par_delta
  );
 END;
BEGIN
OPEN get_frags;
LOOP
	FETCH get_frags INTO tbname,files,pieces;
	EXIT WHEN get_frags%NOTFOUND;
	IF pieces>files 
	THEN
	  BEGIN
		write_out('defragmenting '||tbname,pieces,99,sysdate,0);
		dbms_output.put_line('defragmenting '||tbname||' pieces:'||to_char(pieces));
		cur:=dbms_sql.open_cursor;
		sql_stmt:='alter tablespace '||tbname||' coalesce';
		dbms_sql.parse(cur,sql_stmt,dbms_sql.v7);
		rows:=dbms_sql.execute(cur);
		dbms_sql.close_cursor(cur);
	  EXCEPTION
		WHEN OTHERS THEN
		write_out('error during defrag of '||tbname,pieces,99,sysdate,0);
		dbms_output.put_line('error defragmenting '||tbname||' error:'||to_char(sqlcode));
	  END;
	END IF;
	COMMIT;
END LOOP;
CLOSE get_frags;
END auto_defrag;
/
Declare
x number;
begin
dbms_job.submit(x,'begin auto_defrag; end;',trunc(sysdate)+1,'trunc(sysdate+1)');
end;
/
