/*
===============================================================================
SCRIPT: in_rep.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _index_scripts/IN_REP.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar colunas e unicidade dos índices selecionados por owner/tabela.

FUNCIONAMENTO DETALHADO
  Une INDEXES/IND_COLUMNS por owner/nome do índice e ordena coluna pela posição.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_INDEXES, DBA_IND_COLUMNS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não mostra expressões de function-based indexes nem descendência ou status de partições. OWNER do filtro é owner do índice, não necessariamente TABLE_OWNER.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @in_rep.sql
  -- Informar owner e tabela com % se necessário.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Table owner/tipo/nome, índice, unicidade, coluna e partitioned.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Join qualificado com aliases I/IC para clareza; todas as colunas preservadas. 
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
rem  **************************************************************************
rem  NAME:     in_rep.sql 
rem  FUNCTION: Generate report on Indexes.
rem  INPUTS:
rem          1 = Oracle Account
rem          2 = Table name
rem  **************************************************************************
SET HEADING OFF VERIFY OFF PAUSE OFF
PROMPT **  Index Column Report  **
PROMPT 
PROMPT Percent signs are wild
ACCEPT OWNER CHAR PROMPT 'Enter Oracle account to report on (or wild): ';
ACCEPT TABLE_NAME CHAR PROMPT 'Enter table name to report on (or wild): ';	
PROMPT 
PROMPT Report file name is  INDEXES.LIS
SET HEADING ON
SET LINESIZE 130 PAGESIZE 56 NEWPAGE 0 SPACE 1 TAB OFF 
SET TERMOUT OFF 
BREAK ON TABLE_OWNER SKIP PAGE ON TABLE_TYPE ON TABLE_NAME ON UNIQUENESS ON INDEX_NAME SKIP 1 
COLUMN TABLE_OWNER     	FORMAT A25	HEADING 'Object Owner'    
COLUMN TABLE_TYPE     	FORMAT A6 	HEADING 'Type'    
COLUMN TABLE_NAME		FORMAT A30	HEADING 'Object Name'    
COLUMN INDEX_NAME		FORMAT A25	HEADING 'Index Name'    
COLUMN UNIQUENESS		FORMAT A1	HEADING 'U|N|I|Q|U|E'    
COLUMN COLUMN_NAME	FORMAT A30	HEADING 'Column Name'    
ttitle "Index Columns by Owner and Table Name"
SPOOL  rep_out\&db\indexes.LIS                      
SELECT   I.TABLE_OWNER
       , DECODE(TABLE_TYPE,'CLUSTER','CLUSTR','TABLE') TABLE_TYPE
       , I.TABLE_NAME, I.INDEX_NAME                                       
       , SUBSTR(UNIQUENESS,1,1) UNIQUENESS, IC.COLUMN_NAME, partitioned                     
    FROM DBA_INDEXES I, DBA_IND_COLUMNS IC
   WHERE I.INDEX_NAME = IC.INDEX_NAME
     AND I.OWNER = IC.INDEX_OWNER  
     AND I.OWNER LIKE upper('&OWNER')
     AND I.TABLE_NAME LIKE upper('&TABLE_NAME')
ORDER BY 
     1,2,3,5 DESC,4,COLUMN_POSITION;                                                                              
SPOOL OFF
SET HEADING ON VERIFY ON PAUSE OFF TERMOUT ON
SET LINESIZE 80 PAGESIZE 22 TAB ON 
clear columns
clear breaks
undef owner
undef table_name
