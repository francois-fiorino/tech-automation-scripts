/*
===============================================================================
SCRIPT: ind_pstor.sql
CATEGORIA: Oracle / objects/indexes
ORIGEM: Oracle Script Collection 2015 / _index_scripts/ind_pstor.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir armazenamento e estatísticas por partição de índice.

FUNCIONAMENTO DETALHADO
  Consulta DBA_IND_PARTITIONS, retornando owner, índice, tablespace, partição, parâmetros de extent/concorrência e estatísticas; ordena owner/índice.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_IND_PARTITIONS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  MAX_EXTENT é a coluna singular válida nesta view, diferente de MAX_EXTENTS em DBA_INDEXES. Valores globais de índices compostos podem não representar segmentos das subpartições. Dados de otimizador dependem da coleta.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @ind_pstor.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Identificação, PCT_FREE, INI_TRANS/MAX_TRANS, extents, DISTINCT_KEYS e CLUSTERING_FACTOR.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  SQL original preservado após conferência de MAX_EXTENT no Database Reference; nenhum rename indevido de coluna. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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

rem
rem NAME: ind_pstor.sql
rem FUNCTION: Provide data on partitioned index storage characteristics
rem 
COLUMN owner             FORMAT a6 HEADING 'Owner'
COLUMN index_name        FORMAT a14 HEADING 'Index'
COLUMN partition_name    FORMAT a9 HEADING 'Partition'
COLUMN tablespace_name   FORMAT a11 HEADING 'Tablespace'
COLUMN pct_free          FORMAT 9999 HEADING '%|Free'
COLUMN ini_trans         FORMAT 9999 HEADING 'Init|Tran'
COLUMN max_trans         FORMAT 9999 HEADING 'Max|Tran'
COLUMN initial_extent    FORMAT 9999999 HEADING 'Init|Extent'
COLUMN next_extent       FORMAT 9999999 HEADING 'Next|Extent'
COLUMN max_extent        HEADING 'Max|Extents'
COLUMN pct_increase      FORMAT 999 HEADING '%|Inc'
COLUMN distinct_keys     FORMAT 9999999 HEADING '#Keys'
COLUMN clustering_factor FORMAT 999999 HEADING 'Clus|Fact'
SET LINES 130
ttitle 'Index Partition File Storage'
BREAK ON index_owner on index_name
spool ind_pstor.lst
SELECT
   index_owner,
   index_name,
   tablespace_name,
   partition_name,
   pct_free,
   ini_trans,
   max_trans,
   initial_extent,
   next_extent,
   max_extent,
   pct_increase,
   distinct_keys,
   clustering_factor
FROM 
   sys.dba_ind_partitions
ORDER BY 
   index_owner,index_name;

SPOOL OFF