/*
===============================================================================
SCRIPT: update.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/update.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar rotina de atualização em lotes por ROWIDs coletados em staging.

FUNCIONAMENTO DETALHADO
  TRUNCATE TEMP_TAB, INSERT ROWNUM/ROWID de tabela dinâmica, percorre lotes, altera ENTRY_TS e faz COMMIT por lote.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  TEMP_TAB, DBMS_SQL, DBMS_OUTPUT, tabela alvo com ENTRY_TS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE/DDL/DML diretos. Nome concatenado sem validação é inseguro; data vira string NLS, ROWID fica obsoleto se linhas movem, ROWS<=0 pode impedir avanço. Sem cleanup em erro e buffers 100 limitam SQL. Exige redesenho homologado antes de deployment.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Revisão somente; não chamar contra dados reais.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Procedimento criado; chamada altera dados e staging com confirmações parciais.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Terminador / adicionado; algoritmo, lotes e commits preservados com pendências específicas. 
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
create or replace procedure update_it (rows IN NUMBER, tab_name IN VARCHAR2) AS
  cursor_name 	INTEGER;
  ret 		INTEGER;
  rowcount 	NUMBER:=1;
  maxrows 	NUMBER;
  temp_id	ROWID;
  i		INTEGER:=1;
  CURSOR proc_row(row NUMBER, maxr NUMBER) IS 
	SELECT idrow FROM temp_tab WHERE numrow BETWEEN row and maxr;
  sql_com 	VARCHAR2(100);
  new_date 	DATE;
  maxcount	NUMBER;
BEGIN
  --
  -- First clear out the temp_tab of old entries
  --
  sql_com:='TRUNCATE TABLE temp_tab';
  cursor_name:=DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(cursor_name,sql_com,dbms_sql.v7);
  ret:=DBMS_SQL.EXECUTE(cursor_name);
  DBMS_SQL.CLOSE_CURSOR(cursor_name);
  --
  -- Add the where clause for a specific retrieval at the end of the next command
  --
  sql_com:='INSERT INTO temp_tab SELECT rownum, rowid FROM '||tab_name;
  cursor_name:=DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(cursor_name,sql_com,dbms_sql.v7);
  ret:=DBMS_SQL.EXECUTE(cursor_name);
  DBMS_SQL.CLOSE_CURSOR(cursor_name);
  SELECT MAX(numrow) INTO maxcount FROM temp_tab;
  IF maxcount>0 THEN 
  maxrows:=rowcount+rows; 
  new_date:=sysdate+2;
  LOOP
	DBMS_OUTPUT.PUT_LINE('Rowcount:'||TO_CHAR(rowcount)||' Maxrows:'||TO_CHAR(maxrows));
	OPEN proc_row(rowcount,maxrows);
	FETCH proc_row into temp_id;
	LOOP
	EXIT WHEN proc_row%NOTFOUND;
		sql_com:='UPDATE '||tab_name||'
			SET entry_ts='||chr(39)||new_date||chr(39)||'
			WHERE rowid='||chr(39)||temp_id||chr(39);
		cursor_name:=DBMS_SQL.OPEN_CURSOR;
		DBMS_SQL.PARSE(cursor_name,sql_com,dbms_sql.v7);
		ret:=DBMS_SQL.EXECUTE(cursor_name);
		DBMS_SQL.CLOSE_CURSOR(cursor_name);
		rowcount:=rowcount+1;
		FETCH proc_row INTO TEMP_ID;
		DBMS_OUTPUT.PUT_LINE(to_char(rowcount));
	END LOOP;
	CLOSE proc_row;
	COMMIT;
 	maxrows:=rowcount+rows;
  	IF rowcount=maxcount+1 
	THEN 
		EXIT;
	END IF;
  END LOOP;
  END IF;
END;
/
