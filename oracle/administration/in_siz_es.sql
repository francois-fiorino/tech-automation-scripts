/*
===============================================================================
SCRIPT: in_siz_es.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _index_scripts/in_siz_es.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar e executar estimativa de bytes por entrada de índice proposto.

FUNCIONAMENTO DETALHADO
  Constrói SELECT de somas VSIZE das colunas informadas por UNION e START do arquivo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TAB_COLUMNS, V$DATABASE, DUAL, tabela informada

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Ainda usa substituição textual e execução automática do script gerado. A lista deve usar nomes na forma do dicionário; SQLCASE do cliente e quoted mixed exigem teste. Sem função/LOB/compressão e sem fidelidade de storage; coluna inexistente pode deixar geração incompleta. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Somente tabela pequena de laboratório; revisar CLIST e arquivo gerado antes de execução.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Count e bytes médios com overhead fixo 11.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 038 (2026-11-04): Lista de colunas passa a IN (&clist), removendo UPPER aplicado a múltiplos argumentos (inválido para exemplo com duas colunas). Entradas devem ser literais normalizados confiáveis, sem SQL arbitrário. Casos de homologação: Lista de uma/duas colunas uppercase; coluna desconhecida; schema/tabela quoted; entrada não confiável proibida; tabela vazia; SQLCASE e NLS; verificar saída antes de executar. Comentários/créditos históricos preservados. Não aprovado para implantação.

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
rem  ******************************************************
rem  NAME:  IN_ES_SZ.sql     
rem  HISTORY:
rem  Date           Who                    What
rem  --------       -------------------    ---------------
rem  01/20/93       Michael Brouillette    Creation
rem  09/22/01       Michael Ault           Upgraded to 9i
rem  FUNCTION:  Compute the space used by an entry for an 
rem   existing index.
rem  NOTES:  Currently requires DBA.
rem  INPUTS:
rem         tname  = Name of table.
rem         towner = Name of owner of table.
rem         clist  = List of columns enclosed in quotes.
rem                  i.e., 'ename', 'empno'
rem         cfile  = Name of output SQL Script file
rem  ******************************************************
COLUMN name      NEW_VALUE     db NOPRINT
COLUMN dum1      NOPRINT
COLUMN isize     FORMAT 99,999.99
COLUMN rcount    FORMAT 999,999,999 NEWLINE 
ACCEPT tname  PROMPT 'Enter table name: '
ACCEPT towner PROMPT 'Enter table owner name: '
ACCEPT clist  PROMPT 'Enter column list: '
ACCEPT cfile  PROMPT 'Enter name for output SQL file: '
SET HEADING OFF VERIFY OFF TERMOUT OFF PAGES 0 EMBEDDED ON
SET FEEDBACK OFF SQLCASE UPPER TRIMSPOOL ON SQLBL OFF
SET NEWPAGE 3
SELECT name FROM v$database;
SPOOL rep_out/&db/&cfile..sql
SELECT -1 dum1,
       'SELECT ''Proposed Index on table ''||' 
FROM dual
UNION
SELECT 0,
       '''&towner..&tname'||' has '',COUNT(*) rcount,
       '' entries of '', ('  
FROM dual 
UNION
SELECT column_id,
      'SUM(NVL(vsize('||column_name||'),0)) + 1 +'
FROM dba_tab_columns 
WHERE table_name = '&tname' 
   AND owner = '&towner'
   AND column_name IN (&clist)
   AND column_id <> (SELECT MAX(column_id)
                     FROM dba_tab_columns
                      WHERE table_name = UPPER('&tname') 
                        AND owner = UPPER('&towner')
                        AND column_name IN (&clist)) 
UNION
SELECT column_id,
      'SUM(NVL(VSIZE('||column_name||'),0)) + 1)'
 FROM dba_tab_columns 
 WHERE table_name = upper('&tname')
   AND owner = upper('&towner') AND column_name IN (&clist)
   AND column_id = (SELECT MAX(column_id)
                    FROM dba_tab_columns
                     WHERE table_name = upper('&tname')  
                      AND owner = upper('&towner')
                      AND column_name IN (&clist)) 
UNION 
SELECT 997, '/ NULLIF(COUNT(*),0) + 11 isize, '' bytes each.''' 
FROM dual 
UNION 
SELECT 999,
       'FROM &towner..&tname.;'  FROM dual order by 1;
SPOOL OFF
SET TERMOUT ON FEEDBACK 15 PAGESIZE 20 SQLCASE MIXED 
SET NEWPAGE 1
START rep_out/&db/&cfile
CLEAR COLUMNS
