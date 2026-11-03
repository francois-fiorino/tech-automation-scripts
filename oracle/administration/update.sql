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
  TEMP_TAB ainda é compartilhada e truncada, com COMMIT por lote e possível confirmação do trabalho do chamador; proibir concorrência. ROWID pode ficar obsoleto por movimento de linha. SQL_OBJECT_NAME não verifica autorização de negócio nem fixa identidade do objeto. Somente tabela heap/ROWID físico e ENTRY_TS compatível; não homologado para IOT/UROWID/remote. Falha deixa lotes anteriores confirmados. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

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
  Revisão complementar 036 (2026-11-03): Validação de lote inteiro positivo antes de TRUNCATE; nome alvo validado por SQL_OBJECT_NAME; DATE e ROWID passam por bind; buffer ampliado, NATIVE e cleanup em erro. Limite inclusivo BETWEEN corrigido para rowcount+rows-1, respeitando tamanho solicitado. Parâmetros internos do cursor renomeados para evitar ROW reservado no SQL, sem alterar a interface pública. Casos de homologação: NULL/zero/negativo/fracionário; lote1/exato/resíduo; alvo vazio; nome malicioso/inexistente; NLS de data; movimento de linha; erro no lote2; concorrência proibida. Comentários/créditos históricos preservados. Não aprovado para implantação.

REFERÊNCIAS TÉCNICAS DA REVISÃO 036
 https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_SQL.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_ASSERT.html

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
create or replace procedure update_it (rows IN NUMBER, tab_name IN VARCHAR2) AS
  cursor_name 	INTEGER:=NULL;
  ret 		INTEGER;
  rowcount 	NUMBER:=1;
  maxrows 	NUMBER;
  temp_id	ROWID;
  i		INTEGER:=1;
  CURSOR proc_row(p_first_row NUMBER, p_last_row NUMBER) IS 
	SELECT idrow FROM temp_tab WHERE numrow BETWEEN p_first_row and p_last_row;
  sql_com 	VARCHAR2(32767);
  safe_table VARCHAR2(1000);
  new_date 	DATE;
  maxcount	NUMBER;
BEGIN
  IF rows IS NULL OR rows<=0 OR rows<>TRUNC(rows) THEN
    RAISE_APPLICATION_ERROR(-20018,'Tamanho do lote deve ser inteiro positivo.');
  END IF;
  safe_table:=DBMS_ASSERT.SQL_OBJECT_NAME(tab_name);
  --
  -- First clear out the temp_tab of old entries
  --
  sql_com:='TRUNCATE TABLE temp_tab';
  cursor_name:=DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(cursor_name,sql_com,dbms_sql.native);
  ret:=DBMS_SQL.EXECUTE(cursor_name);
  DBMS_SQL.CLOSE_CURSOR(cursor_name); cursor_name:=NULL;
  --
  -- Add the where clause for a specific retrieval at the end of the next command
  --
  sql_com:='INSERT INTO temp_tab SELECT rownum, rowid FROM '||safe_table;
  cursor_name:=DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(cursor_name,sql_com,dbms_sql.native);
  ret:=DBMS_SQL.EXECUTE(cursor_name);
  DBMS_SQL.CLOSE_CURSOR(cursor_name); cursor_name:=NULL;
  SELECT MAX(numrow) INTO maxcount FROM temp_tab;
  IF maxcount>0 THEN 
  maxrows:=rowcount+rows-1; 
  new_date:=sysdate+2;
  LOOP
	DBMS_OUTPUT.PUT_LINE('Rowcount:'||TO_CHAR(rowcount)||' Maxrows:'||TO_CHAR(maxrows));
	OPEN proc_row(rowcount,maxrows);
	FETCH proc_row into temp_id;
	LOOP
	EXIT WHEN proc_row%NOTFOUND;
		sql_com:='UPDATE '||safe_table||' SET entry_ts=:entry_value WHERE rowid=:target_rowid';
		cursor_name:=DBMS_SQL.OPEN_CURSOR;
		DBMS_SQL.PARSE(cursor_name,sql_com,dbms_sql.native);
		DBMS_SQL.BIND_VARIABLE(cursor_name,':entry_value',new_date);
		DBMS_SQL.BIND_VARIABLE_ROWID(cursor_name,':target_rowid',temp_id);
		ret:=DBMS_SQL.EXECUTE(cursor_name);
		DBMS_SQL.CLOSE_CURSOR(cursor_name); cursor_name:=NULL;
		rowcount:=rowcount+1;
		FETCH proc_row INTO TEMP_ID;
		DBMS_OUTPUT.PUT_LINE(to_char(rowcount));
	END LOOP;
	CLOSE proc_row;
	COMMIT;
 	maxrows:=rowcount+rows-1;
  	IF rowcount=maxcount+1 
	THEN 
		EXIT;
	END IF;
  END LOOP;
  END IF;
EXCEPTION WHEN OTHERS THEN
  BEGIN
    IF cursor_name IS NOT NULL AND DBMS_SQL.IS_OPEN(cursor_name) THEN DBMS_SQL.CLOSE_CURSOR(cursor_name); cursor_name:=NULL; END IF;
    IF proc_row%ISOPEN THEN CLOSE proc_row; END IF;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  RAISE;
END;
/
