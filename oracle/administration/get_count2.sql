/*
===============================================================================
SCRIPT: get_count2.sql
CATEGORIA: Administração Oracle / contagem de linhas
ORIGEM: Oracle Script Collection 2015 / misc_scripts/get_count2.sql
PUBLICAÇÃO INDIVIDUAL: 05/11/2026; corpo da revisão 043 preservado.

OBJETIVO E FUNCIONAMENTO
  Criar GET_COUNT(tab_name VARCHAR2) RETURN NUMBER AUTHID CURRENT_USER.
  Valida o nome com DBMS_ASSERT.SQL_OBJECT_NAME e executa SELECT COUNT(1)
  por DBMS_SQL; lê a única linha e fecha o cursor em sucesso ou exceção.
  Erros são propagados ao chamador. Não recebe cláusulas WHERE nem SQL livre.

PRÉ-REQUISITOS, DEPENDÊNCIAS E PRIVILÉGIOS
  SQL*Plus/SQLcl; schema de instalação previamente escolhido; CREATE PROCEDURE.
  Acesso de execução a SYS.DBMS_SQL e SYS.DBMS_ASSERT; grants diretos quando
  necessários para compilação. O invocador precisa de EXECUTE na função e
  acesso SELECT ao objeto informado. Não requer AWR/ASH ou Diagnostics Pack.
  Não requer os grants V_$MYSTAT/V_$STATNAME usados apenas pelo ensaio de cursores.
  Não instalar sobre procedimento/função GET_COUNT existente sem avaliar seus
  dependentes; a variante oracle/objects/get_count_proc.sql é incompatível.

PARÂMETRO E EXECUÇÃO
  TAB_NAME: nome de tabela/view acessível, opcionalmente qualificado por schema;
  preservar aspas duplas para identificadores case-sensitive. Entrada VARCHAR2;
  a validação de nome não substitui a autorização Oracle nem uma allowlist local.
  Instalação, no schema selecionado: @get_count2.sql
  Verificação: SHOW ERRORS FUNCTION GET_COUNT
  Exemplo com tabela pequena de laboratório já existente:
    SELECT GET_COUNT('ORACLE_SCRIPT_LAB.LAB_PRIV_FIXTURE') FROM dual;
  Nome quoted de exemplo: SELECT GET_COUNT('"Lab Count"') FROM dual;
  Saída: número de linhas (inclui linhas com colunas NULL); erro se alvo inválido
  ou inacessível. Chamadas refletem a consistência de leitura Oracle do SELECT.

RISCOS E IMPACTOS
  CREATE OR REPLACE altera o objeto e envolve commit implícito de DDL;
  executar a instalação em sessão sem transações de trabalho pendentes.
  COUNT exato pode fazer full scan e consumir I/O/CPU; views podem executar
  lógica adicional. Definir objetos autorizados, janela e limites de recursos.
  AUTHID CURRENT_USER usa os direitos do invocador, não empresta os do definidor.
  Não automatizar chamadas sobre objetos grandes ou desconhecidos.

COMPATIBILIDADE E EVIDÊNCIAS
  Compilação e casos executados pelo usuário em Oracle Database 19c Enterprise
  Edition 19.8.0.0.0, PDB1, schema ORACLE_SCRIPT_LAB; não executados pelo agente.
  Fonte testado: commit bc277eba3fb4a3c9b45705efd1f0969dc4e19b4b,
  blob e30dc6197607075008e3cd7ed6b46d8d265872b3.
  O corpo publicado permanece idêntico; somente este cabeçalho foi atualizado.
  Passaram: função VALID, AUTHID CURRENT_USER; oito casos básicos (vazio,
  NULL, nomes minúsculo/qualificado/quoted, entrada SQL inválida, recuperação
  após erro e DELETE); acesso negado sem SELECT, permitido com SELECT e negado
  após REVOKE; 1.000 entradas inválidas com cursores 5 antes/5 depois.
  Evidências: oracle/collection/tests/runtime/lote001/evidence.json e logs.
  DBMS_ASSERT é dependência; versões além de 19.8 não foram homologadas.

CORREÇÕES E HISTÓRICO TÉCNICO
  Revisões 03–04/11/2026: validação do nome, remoção de terminador do SQL
  dinâmico, FETCH_ROWS, buffer VARCHAR2(32767), cleanup com propagação do erro,
  AUTHID CURRENT_USER, DBMS_SQL.NATIVE, cursor inicializado e contagem NUMBER.
  Publicação 05/11/2026: documentação atualizada com evidências reais;
  nenhuma mudança no algoritmo já testado. Origem histórica preservada.

LIMITAÇÕES E PENDÊNCIAS
  Validação delimitada aos cenários e ambiente descritos, sem aprovação genérica
  de produção. Não testados: contagem acima de 2.147.483.647, desempenho,
  concorrência, outras versões, sinônimos/DB links e todos os caminhos de erro
  de parse/execute/fetch. O ensaio de cursores cobre rejeição pelo DBMS_ASSERT.
  NUMBER remove o limite de inteiro da variável de contagem; isso é análise
  estática e não comprova ensaio de grande volume.

AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de qualquer utilização em produção. Sua execução é de responsabilidade do profissional responsável pelo ambiente. Os mantenedores deste repositório não se responsabilizam por indisponibilidade, perda de dados, alterações indevidas ou outros impactos decorrentes de sua utilização.

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
create or replace function get_count (tab_name varchar2) return number AUTHID CURRENT_USER as
cur integer := NULL;
sql_text varchar2(32767);
rowcount NUMBER;
row_proc integer;
BEGIN
    cur:=dbms_sql.open_cursor;
    sql_text:='select count(1) rowcount from '||dbms_assert.sql_object_name(tab_name);
    dbms_sql.parse(cur,sql_text,dbms_sql.NATIVE);
    dbms_sql.define_column(cur,1,rowcount);
    row_proc:=dbms_sql.execute(cur);
    row_proc:=dbms_sql.fetch_rows(cur);
    dbms_sql.column_value(cur,1,rowcount);
    dbms_sql.close_cursor(cur);
    return rowcount;
exception
 when others then
  if cur is not null and dbms_sql.is_open(cur) then dbms_sql.close_cursor(cur); end if;
  raise;
end;
/
