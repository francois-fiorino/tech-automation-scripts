/*
===============================================================================
SCRIPT: chk_tab.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/chk_tab.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar CHECK_TABLES de contagem real versus estatística com ANALYZE condicional.

FUNCIONAMENTO DETALHADO
  Cursor DBA_TABLES chama DBA_UTILITIES.GET_COUNT, compara razões usando piso um e executa ANALYZE COMPUTE quando limiar excedido.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme limitações de cada arquivo. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES, DBA_UTILITIES.GET_COUNT, DBMS_SQL, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Preservados algoritmo, piso um, limiar e dependência DBA_UTILITIES.GET_COUNT. O helper recebe UPPER(owner.table) e ainda não trata nomes quoted mistos; sem sua fonte/contrato não se declara suporte. ANALYZE pode alterar planos/bloquear; grants diretos exigidos. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório com pacote GET_COUNT revisado e schema pequeno.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Rotina criada; chamadas contam e podem atualizar estatísticas.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  conforme descritos. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 036 (2026-11-03): Identificadores do ANALYZE citados por DBMS_ASSERT; buffer de tabela ancorado e instrução ampliada; limiar negativo/NULL rejeitado; cleanup antes do RAISE e cursor inicializado. Casos de homologação: Nomes longos; owner/tabela quoted no gerador versus helper; pacote ausente; erro no PARSE; limiar negativo; zero linhas e redução de cardinalidade. Comentários/créditos históricos preservados. Não aprovado para implantação.

REFERÊNCIAS TÉCNICAS DA REVISÃO 036
 https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_ASSERT.html
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
CREATE OR REPLACE PROCEDURE check_tables (owner_name in varchar2, pchng IN INTEGER) AS
--
CURSOR get_tab_count (own varchar2) IS
        SELECT table_name, nvl(num_rows,1) 
        FROM dba_tables
        WHERE owner = upper(own);
--
tab_name dba_tables.table_name%TYPE;
rows integer;
string varchar2(1000);
cur integer:=NULL;
ret integer;
row_count integer;
com_string varchar2(1000);
--
BEGIN
IF pchng IS NULL OR pchng<0 THEN RAISE_APPLICATION_ERROR(-20017,'Limiar deve ser nao negativo.'); END IF;
OPEN get_tab_count (owner_name);
LOOP
        FETCH get_tab_count INTO tab_name, rows;
        if rows=0 then 
        rows:=1;
        end if;
EXIT WHEN get_tab_count%NOTFOUND;
dbms_output.put_line('Table name: '||tab_name||' rows: '||to_char(rows));
dba_utilities.get_count(upper(owner_name||'.'||tab_name),row_count);
   IF row_count=0 THEN
        row_count:=1;
   END IF;
dbms_output.put_line('Row count for '||tab_name||': '||to_char(row_count));
dbms_output.put_line('Ratio: '||to_char(row_count/rows));
        IF (row_count/rows)*100>100+pchng OR (rows/row_count)*100>100+pchng THEN
           string :=
                   'analyze table '||DBMS_ASSERT.ENQUOTE_NAME(UPPER(owner_name),FALSE)||'.'||DBMS_ASSERT.ENQUOTE_NAME(tab_name,FALSE)||' compute statistics';
           cur := dbms_sql.open_cursor;
           dbms_sql.parse(cur,string,dbms_sql.native);
           ret := dbms_sql.execute(cur)  ;
           dbms_sql.close_cursor(cur); cur:=NULL;
           dbms_output.put_line(' Table: '||tab_name||' had to be analyzed.');
        END IF;
END LOOP;
CLOSE get_tab_count;
--
EXCEPTION
   WHEN OTHERS THEN
      BEGIN
        IF cur IS NOT NULL AND dbms_sql.is_open(cur) THEN dbms_sql.close_cursor(cur); cur:=NULL; END IF;
        IF get_tab_count%ISOPEN THEN CLOSE get_tab_count; END IF;
      EXCEPTION WHEN OTHERS THEN NULL;
      END;
      raise_application_error(-20002,'Error in analyze: '||to_char(sqlcode)||' on '||tab_name,TRUE);
END;
/

