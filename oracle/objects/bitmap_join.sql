/*
===============================================================================
SCRIPT: bitmap_join.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/bitmap_join.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar mapeamento de colunas de bitmap join indexes por owner.

FUNCIONAMENTO DETALHADO
  Consulta DBA_JOIN_IND_COLUMNS com filtro exato UPPER de owner do índice e mostra colunas inner/outer.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_JOIN_IND_COLUMNS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  View requer versão/recurso que exponha bitmap join indexes (exemplo 9i+). Não cria índices, valida cardinalidade ou comprova benefício de plano. Widths podem truncar nomes longos; não é JOIN de aplicação executado.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE owner = HR
  @bitmap_join.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Index owner/name, inner table owner/name/column e outer table owner/name/column.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Heading repetido Index Owner corrigido para Index Name; consulta integral preservada. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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

-- comment:  Bitmap Join Indexes report

col index_owner format a11 heading 'Index|Owner'
col index_name format a10 heading 'Index|Name'
col inner_table_owner format a11 heading 'Inner|Table Owner'
col inner_table_name format a11 heading 'Inner|Table Name'
col inner_table_column format a13 heading 'Inner|Table Column'
col outer_table_owner format a12 heading 'Outer|Table Owner'
col outer_table_name format a11 heading 'Outer|Table Name'
col outer_table_column format a13 heading 'Outer|Table Column'
set lines 132
ttitle 'Bitmap Join Indexes'
spool bitmap_join.lst
select 
      index_owner, index_name, 
      inner_table_owner, inner_table_name,inner_table_column,
      outer_table_owner,outer_table_name,outer_table_column
from 
      dba_join_ind_columns
where 
      index_owner = UPPER('&owner');
spool off
clear columns
ttitle off
set lines 80
