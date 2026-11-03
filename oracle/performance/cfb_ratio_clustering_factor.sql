/*
===============================================================================
SCRIPT: cfb_ratio_clustering_factor.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / _table_scripts/cfb_ratio_clustering_factor.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Selecionar índices com CF/blocos alto e BLEVEL=1.

FUNCIONAMENTO DETALHADO
  Une tabelas/índices por table owner/name, aplica lista histórica de owners e razão com DECODE para bloco zero.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES, DBA_INDEXES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  BLOCKS não são dirty blocks. CF reflete padrão de visita de blocos ao percorrer índice; razão >100 não prova benefício de rebuild. Estatísticas precisam estar atuais; filtro BLEVEL=1 é específico.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @cfb_ratio_clustering_factor.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tabela, índice, linhas, blocos da estatística, CF, razão e BLEVEL.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Heading Dirty Blocks corrigido para Table Blocks; fórmula protegida original preservada. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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

-- comment: clustering factor to rows ratio
column table_name format a20 heading 'Table|Name'
column index_name format a20 heading 'Index|Name'
column dirty_blocks heading 'Table|Blocks'
column clustering_factor heading 'Clustering|Factor'
column cfb_ratio heading 'Clustering Factor|To Blocks Ratio' format 99,999.99
column owner format a15 heading 'Owner'
ttitle 'Clustering Factor to Block Ratio Report'
set lines 132 verify off pages 55 feedback off
break on owner on table_name 
spool cfb_ratio_clustering_factor.lst
select t.owner,t.table_name,i.index_name, t.num_rows, t.blocks dirty_blocks,i.clustering_factor,
i.clustering_factor/decode(t.blocks,0,decode(i.clustering_factor,0,1,i.clustering_factor),t.blocks) cfb_ratio, i.blevel
from dba_tables t, dba_indexes i
where t.owner=i.table_owner and t.table_name=i.table_name
and t.owner not in ('SYS','SYSTEM','DBAUTIL','OUTLN','DBSNMP','SPOTLIGHT','PERFSTAT','RMAN','IWATCH')
and i.clustering_factor/decode(t.blocks,0,decode(i.clustering_factor,0,1,i.clustering_factor),t.blocks)>100 and i.blevel=1
order by t.owner,i.clustering_factor/decode(t.blocks,0,decode(i.clustering_factor,0,1,i.clustering_factor),t.blocks) desc,t.table_name,i.index_name
/
spool off
set lines 80 pages 22 feedback on verify on
clear columns
ttitle off

