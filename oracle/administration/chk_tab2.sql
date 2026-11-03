/*
===============================================================================
SCRIPT: chk_tab2.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/chk_tab2.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar variante CHECK_TABLES com amostra acima de limiar e histórico.

FUNCIONAMENTO DETALHADO
  Conta tabelas via GET_COUNT, escolhe COMPUTE ou ESTIMATE SAMPLE 30 PERCENT, grava DBA_RUNNING_STATS e COMMIT por iteração.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme limitações de cada arquivo. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES, GET_COUNT, DBA_RUNNING_STATS, DBMS_SESSION, DBMS_SQL, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Privilégios diretos de criação/consulta/análise/DML. SET_CLOSE_CACHED_OPEN_CURSORS é legado e precisa validar API; exceções externas são silenciadas, logging/cleanup após RAISE é inalcançável, nomes e parâmetros não validados. Não pronta para instalação.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: revisar também GET_COUNT procedimento e contrato do histórico.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Procedimento criado; chamada pode atualizar estatísticas, gravar/confirmar dados.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  conforme descritos. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Adicionado / final sem reescrever política de amostragem/commits ou remover funcionalidades. 
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
-- You may need to comment out the write_out procedue and subsequent
-- calls to it, I like to track what tables need analysis
-- pchng -- this is the percent change threshold for analysis, any table whose 
-- row count increases or decreases by this percent will be analyzed
-- lim_rows -- this sets the threshold for compute verses analyze, anything 
-- over lim_rows in size will be estimated at 30%.
--
CREATE OR REPLACE PROCEDURE check_tables (owner_name in varchar2, 
                                          pchng IN NUMBER,  
                                          lim_rows IN NUMBER) AS
--
CURSOR get_tab_count (own varchar2) IS
        SELECT table_name, nvl(num_rows,1) 
        FROM dba_tables
        WHERE owner = upper(own);
--
tab_name 	VARCHAR2(64);
rows 		NUMBER;
string 		VARCHAR2(255);
cur 		INTEGER;
ret 		INTEGER;
row_count 	NUMBER;
com_string 	VARCHAR2(255);
--
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
--
BEGIN
DBMS_SESSION.SET_CLOSE_CACHED_OPEN_CURSORS(TRUE);
OPEN get_tab_count (owner_name);
LOOP
BEGIN
        FETCH get_tab_count INTO tab_name, rows;
        tab_name:=owner_name||'.'||tab_name;
        IF rows=0 THEN 
        rows:=1;
        END IF;
EXIT WHEN get_tab_count%NOTFOUND;
DBMS_OUTPUT.PUT_LINE('Table name: '||tab_name||' rows: '||to_char(rows));
--
-- Need to have created the get_count procedure in the same schema
--
GET_COUNT(tab_name,row_count);
   IF row_count=0 THEN
        row_count:=1;
   END IF;
DBMS_OUTPUT.PUT_LINE('Row count for '||tab_name||': '||to_char(row_count));
DBMS_OUTPUT.PUT_LINE('Ratio: '||to_char(row_count/rows));
        IF (row_count/rows)>1+(pchng/100) OR (rows/row_count)>1+(pchng/100) THEN
               BEGIN
	IF (row_count<lim_rows) THEN
           		string :=
              		     'ANALYZE TABLE '||tab_name||' COMPUTE STATISTICS ';
	ELSE
		string :=
	 'ANALYZE TABLE '||tab_name||' ESTIMATE STATISTICS SAMPLE 30 PERCENT';
	END IF;
           cur := DBMS_SQL.OPEN_CURSOR;
DBMS_OUTPUT.PUT_LINE('Beginning analysis');
           DBMS_SQL.PARSE(cur,string,dbms_sql.native);
           ret := DBMS_SQL.EXECUTE(cur)  ;
           DBMS_SQL.CLOSE_CURSOR(cur);
           DBMS_OUTPUT.PUT_LINE(' Table: '||tab_name||' had to be analyzed.');
           write_out(' Table: '||tab_name||' had to be analyzed.', row_count/rows,33,sysdate,0);
           EXCEPTION
           WHEN OTHERS THEN
            raise_application_error(-20002,'Error in analyze: '||to_char(sqlcode)||' on '||tab_name,TRUE);
           write_out(' Table: '||tab_name||' error during analyze. '||to_char(sqlcode), row_count/rows,33,sysdate,0);
            IF dbms_sql.is_open(cur) THEN
                dbms_sql.close_cursor(cur);
              END IF;
           END;
        END IF;
EXCEPTION
WHEN others THEN
null;
END;
COMMIT;
END LOOP;
CLOSE get_tab_count;
END;
/
