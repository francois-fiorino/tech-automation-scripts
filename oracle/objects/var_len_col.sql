/*
===============================================================================
SCRIPT: var_len_col.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/var_len_col.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar colunas VARCHAR2/NUMBER de um proprietário.

FUNCIONAMENTO DETALHADO
  Filtra DBA_TAB_COLUMNS por owner e dois tipos, ordena OWNER/TABLE/COLUMN_ID.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TAB_COLUMNS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DATA_LENGTH é limite em bytes, não média real dos valores. Não lista todos os tipos variáveis, como NVARCHAR2/RAW/LOB. Precisão/escala NUMBER não são mostradas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE owner = HR
  @var_len_col.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, tabela, coluna, tipo e DATA_LENGTH.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Heading Column Nmae corrigido; SQL preservado. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col owner format a10 heading 'Owner'
col table_name format a30 heading 'Table Name'
col column_name format a25 heading 'Column Name'
col data_type format a10 heading 'Data Type'
col data_length heading 'Data Length'
set lines 132 pages 47
ttitle 'Variable Length Columns'
spool var_len_col.lst
select owner, table_name, column_name, data_type, data_length from dba_tab_columns
where owner=upper('&owner') and data_type in ('VARCHAR2','NUMBER')
order by 1,2,column_id
/
spool off
clear columns
ttitle off

