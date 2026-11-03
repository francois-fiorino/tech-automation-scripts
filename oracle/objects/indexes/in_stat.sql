/*
===============================================================================
SCRIPT: in_stat.sql
CATEGORIA: Oracle / objects/indexes
ORIGEM: Oracle Script Collection 2015 / _index_scripts/IN_STAT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar estatísticas de índices por padrões de schema e nome.

FUNCIONAMENTO DETALHADO
  Define IOWNER/INAME a partir de OWNER/INDEX; filtra DBA_INDEXES usando LIKE UPPER e LEAF_BLOCKS>0; apresenta estrutura e clustering factor.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_INDEXES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Padrões LIKE aceitam % e _. Estatísticas podem estar antigas; LEAF_BLOCKS>0 exclui índices sem estatísticas e vazios. BLEVEL é nível de ramificação; não implica quantidade exata de blocos de toda a árvore.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE OWNER = HR
  DEFINE INDEX = %
  @in_stat.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, índice, status, BLEVEL, folhas, chaves distintas, médias por chave e CLUSTERING_FACTOR.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada; limpeza final de variável NAME ajustada para INDEX, usada na entrada. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Wrapper externo de título substituído por TTITLE local.
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
rem  NAME: IN_STAT.sql     
rem
rem  FUNCTION: Report on index statistics
rem  INPUTS:    1 = Index owner    2 = Index name
rem
def iowner = '&OWNER'
def iname  = '&INDEX'
set pages 56 lines 130 verify off feedback off termout on
column owner                   format a10            heading "Owner"
column index_name              format a21            heading "Index"
column status                  format a7             heading "Status"
column blevel                  format 9,999,999      heading "Tree Level"
column leaf_blocks             format 999,999,999    heading "Leaf Blk"
column distinct_keys           format 99,999,999,999 heading "# Keys"
column avg_leaf_blocks_per_key format 999,999,999    heading "Avg. LB/Key"
column avg_data_blocks_per_key format 999,999,999    heading "Avg. DB/Key"
column clustering_factor       format 99,999,999,999 heading "Clstr Factor"
rem
ttitle "Index Statistics Report"
spool in_stat.lst
rem
select owner, index_name, status, blevel, leaf_blocks,
	distinct_keys, avg_leaf_blocks_per_key,
	avg_data_blocks_per_key, clustering_factor
from dba_indexes
where
owner like upper('&&iowner') and index_name like upper('&&iname')
and leaf_blocks>0
order by 1,2;
rem
spool off
set pages 22 lines 80 verify on feedback on termout on
clear columns
undef iowner
undef iname
undef owner
undef index
ttitle off
