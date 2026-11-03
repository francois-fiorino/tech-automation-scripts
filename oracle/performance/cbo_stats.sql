/*
===============================================================================
SCRIPT: cbo_stats.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/cbo_stats.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Descrever estatísticas de tabela/colunas/índices e composição dos índices.

FUNCIONAMENTO DETALHADO
  Lista USER_TABLES, solicita owner/tabela e executa quatro relatórios DBA_TABLES/TAB_COLUMNS/INDEXES/IND_COLUMNS; formata tipos legados.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  USER_TABLES, DBA_TABLES, DBA_TAB_COLUMNS, DBA_INDEXES, DBA_IND_COLUMNS, DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Estatísticas podem ser antigas/NULL. Formatação de NUMBER sem precisão e comprimentos bytes não é DDL fiel; não mostra histogramas/partições/expressões ou estatísticas estendidas. Não coleta stats nem altera CBO.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @cbo_stats.sql
  -- Owner vazio usa USER; informar nome de tabela de teste.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Rows/blocks/avg length/chains, NDV/density, BLEVEL/leaves/CF e colunas do índice em posição.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Junção final adiciona TABLE_OWNER entre índice e tabela para não cruzar homônimos de outros schemas; todos os relatórios e campos mantidos. 
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
set echo off 
set scan on 
set lines 132 
set pages 66 
set verify off 
set feedback off 
set termout off 
set termout on 
column uservar new_value Table_Owner noprint 
column TABLE_NAME heading "Tables owned by &Table_Owner" format a30 
select user uservar from dual; 
select table_name from user_tables order by 1 
/ 
undefine table_name 
undefine owner 
prompt 
accept owner prompt 'Please enter Name of Table Owner (Null = &Table_Owner): ' 
accept table_name  prompt 'Please enter Table Name to show Statistics for: ' 
column TABLE_NAME heading "Table|Name" format a15 
column NUM_ROWS heading "Number|of Rows" format 9,999,990 
column BLOCKS heading "Blocks" format 999,990 
column EMPTY_BLOCKS heading "Empty|Blocks" format 999,990 
 
column AVG_SPACE heading "Average|Space" format 9,990 
column CHAIN_CNT heading "Chain|Count" format 990 
column AVG_ROW_LEN heading "Average|Row Len" format 990 
column COLUMN_NAME  heading "Column|Name" format a25 
column NULLABLE heading Null|able format a4 
column NUM_DISTINCT heading "Distinct|Values" format 9,999,990 
column DENSITY heading "Density" format 990 
column INDEX_NAME heading "Index|Name" format a15 
column UNIQUENESS heading "Unique" format a9 
column BLEV heading "B|Tree|Level" format 90 
column LEAF_BLOCKS heading "Leaf|Blks" format 9,999,990 
column DISTINCT_KEYS heading "Distinct|Keys" format 9,999,990 
column AVG_LEAF_BLOCKS_PER_KEY heading "Average|Leaf Blocks|Per Key" format 99,990 
column AVG_DATA_BLOCKS_PER_KEY heading "Average|Data Blocks|Per Key" format 99,990 
column CLUSTERING_FACTOR heading "Cluster|Factor" format 9,999,990 
column COLUMN_POSITION heading "Col|Pos" format 990 
column col heading "Column|Details" format a24 
column COLUMN_LENGTH heading "Col|Len" format 990 
 select TABLE_NAME, 
 NUM_ROWS, 
 BLOCKS, 
 EMPTY_BLOCKS, 
 AVG_SPACE, 
 CHAIN_CNT, 
 AVG_ROW_LEN 
from dba_tables 
where owner = upper(nvl('&&Owner',user)) 
and table_name = upper('&&Table_name') 
/ 
 select 
 COLUMN_NAME, 
decode(t.DATA_TYPE, 
'NUMBER',t.DATA_TYPE||'('|| 
         decode(t.DATA_PRECISION, 
                null,t.DATA_LENGTH||')', 
                t.DATA_PRECISION||','||t.DATA_SCALE||')'), 
'DATE',t.DATA_TYPE, 
'LONG',t.DATA_TYPE, 
'LONG RAW',t.DATA_TYPE, 
'ROWID',t.DATA_TYPE, 
'MLSLABEL',t.DATA_TYPE, 
t.DATA_TYPE||'('||t.DATA_LENGTH||')') ||' '|| 
       decode(t.nullable, 
              'N','NOT NULL', 
              'n','NOT NULL', 
              NULL) col, 
 NUM_DISTINCT, 
 DENSITY 
from dba_tab_columns t 
where table_name = upper('&Table_name') 
and owner = upper(nvl('&Owner',user)) 
/ 
 select INDEX_NAME, 
 UNIQUENESS, 
 BLEVEL BLev, 
 LEAF_BLOCKS, 
 DISTINCT_KEYS, 
 AVG_LEAF_BLOCKS_PER_KEY, 
 AVG_DATA_BLOCKS_PER_KEY, 
 CLUSTERING_FACTOR 
from dba_indexes 
where table_name = upper('&Table_name') 
and table_owner = upper(nvl('&Owner',user)) 
/ 
break on index_name 
select 
i.INDEX_NAME, 
i.COLUMN_NAME, 
i.COLUMN_POSITION, 
decode(t.DATA_TYPE, 
'NUMBER',t.DATA_TYPE||'('|| 
         decode(t.DATA_PRECISION, 
                null,t.DATA_LENGTH||')', 
                t.DATA_PRECISION||','||t.DATA_SCALE||')'), 
'DATE',t.DATA_TYPE, 
'LONG',t.DATA_TYPE, 
'LONG RAW',t.DATA_TYPE, 
'ROWID',t.DATA_TYPE, 
'MLSLABEL',t.DATA_TYPE, 
t.DATA_TYPE||'('||t.DATA_LENGTH||')') ||' '|| 
       decode(t.nullable, 
              'N','NOT NULL', 
              'n','NOT NULL', 
              NULL) col 
from dba_ind_columns i,dba_tab_columns t 
where i.table_name = upper('&Table_name') 
and owner = upper(nvl('&Owner',user)) 
and i.table_name = t.table_name
and i.table_owner=t.owner 
and t.column_name = i.column_name 
order by index_name,column_position 
/ 
clear breaks 
set echo on 
