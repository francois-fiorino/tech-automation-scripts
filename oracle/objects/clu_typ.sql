/*
===============================================================================
SCRIPT: clu_typ.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/CLU_TYP.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar configuração de clusters de tabelas Oracle.

FUNCIONAMENTO DETALHADO
  Consulta DBA_CLUSTERS com AVG_BLOCKS_PER_KEY, tipo, função hash e HASHKEYS.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_CLUSTERS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não se refere a RAC/Clusterware. Métricas podem depender de estatísticas; não lista tabelas ou mede contenção. Máscaras/widths antigos podem truncar nomes.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @clu_typ.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner/cluster/tablespace, blocos por chave, tipo, função e número de hash keys.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Título convertido em TTITLE local.
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
rem Name		:	clu_typ.sql
rem Purpose		:	Report on new DBA_CLUSTER columns
rem Use		:	From an account that accesses DBA_ views
rem
column owner 			format a10 	heading "Owner"
column cluster_name 		format a15 	heading "Cluster"
column tablespace_name 	format a10 	heading "Tablespace"
column avg_blocks_per_key 	format 999999 	heading "Blocks per Key"
column cluster_type 		format a8 	Heading "Type"
column function 		format 999999 	heading "Function"
column hashkeys 		format 99999 	heading "# of Keys" 
set pages 56 lines 131 feedback off
ttitle "Cluster Type Report"
spool clu_typ.lst
select 
	owner,
	cluster_name,
	tablespace_name,
	avg_blocks_per_key, 
	cluster_type, 
	function,
	hashkeys
from 
	dba_clusters
order by 2
/
spool off
set pages 22 lines 80 feedback on
clear columns
ttitle off

