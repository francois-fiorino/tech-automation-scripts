/*
===============================================================================
SCRIPT: desc_non_dba_views.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/DESC_NON_DBA_VIEWS.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Documentar colunas de views SYS após extensa lista de exclusões históricas.

FUNCIONAMENTO DETALHADO
  Une TAB_COLUMNS/OBJECTS e outer join de comentários por chave completa; ordena tabela/COLUMN_ID.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TAB_COLUMNS, DBA_COL_COMMENTS, DBA_OBJECTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Lista de prefixos é histórica e pode excluir views úteis. Underscore nos LIKE é wildcard, não literal; nomes que o atendem são excluídos. Não é documentação completa do catálogo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @desc_non_dba_views.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  View, coluna, tipo, NOT NULL e comentário quando disponível.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Owner acrescentado ao join de comentários e (+) aplicado em toda chave para evitar comentários de outro schema e manter colunas sem comentário. 
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
set lines 130 pages 3000 heading on feedback off
COLUMN TABLE_NAME FORMAT A26 HEADING 'Table Name'
column column_name format a22 heading 'Column Name'
column comments format a30 heading 'Description' word_wrapped
column data_type format a9 heading 'Data Type'
break on table_name skip 1
spool desc_non_dba_views.doc
select a.table_name,a.column_name,a.data_type,
decode(a.nullable,'N','not null','') "Null?", b.comments
from dba_tab_columns a, dba_col_comments b, dba_objects c
where 
A.OWNER='SYS' AND
c.owner=a.owner and
a.table_name=c.object_name and
c.object_type='VIEW' and
(a.table_name NOT like 'DBA_%' AND
A.TABLE_NAME NOT LIKE 'ALL_%' AND
A.TABLE_NAME NOT LIKE 'USER_%' AND
A.TABLE_NAME NOT LIKE 'GV%' AND
A.TABLE_NAME NOT LIKE 'V$%' AND
A.TABLE_NAME NOT LIKE 'V_$%' AND
A.TABLE_NAME NOT LIKE '%$' and
a.table_name not like 'AQ%' and
a.table_name not like 'EXU%' and
a.table_name not like 'DEF%' and
a.table_name not like 'HS%' and
a.table_name not like 'IMP%' and
a.table_name not like 'ORA%' and
a.table_name not like 'LOADER%' and
a.table_name not like 'SM%' and
a.table_name not like 'SYS%' and
a.table_name not like 'TS%') AND
a.owner=b.owner(+) and
a.table_name=b.table_name(+) and
a.column_name=b.column_name(+)
order by a.table_name,a.column_id
/
spool off
