/*
===============================================================================
SCRIPT: in_siz.sql
CATEGORIA: Oracle / objects/indexes
ORIGEM: Oracle Script Collection 2015 / _index_scripts/IN_SIZ.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir atributos históricos de armazenamento e concorrência dos índices.

FUNCIONAMENTO DETALHADO
  Lê DBA_INDEXES, exclui owners SYS/SYSTEM e ordena owner, tablespace e índice; mostra extents, PCTFREE, INITRANS e MAXTRANS.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_INDEXES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Atributos podem ser nulos ou pouco relevantes em LMT/ASSM; NEXT_EXTENT/PCT_INCREASE/MAX_TRANS não devem orientar tuning atual sem contexto. Não calcula tamanho efetivo do índice.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @in_siz.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OWNER, INDEX_NAME, TABLESPACE_NAME e atributos de extent/concorrência; tamanhos de extent em bytes quando preenchidos.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta e créditos MRA preservados. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Wrapper externo de título substituído por TTITLE local.
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
rem
rem in_siz.sql
rem
rem FUNCTION: Report on default sizing for indexes
rem
rem MRA 9/18/96
rem
column index_name format a20 heading Index
column owner format a10 heading Owner
column tablespace_name format a10 heading Tablespace
column initial_extent heading "Init|Ext"
column next_extent heading "Next|Ext"
column pct_increase format 9990 heading "%|Incr"
column pct_free format 9999 heading "%|Free"
column ini_trans format 9999 heading "Init|Trans"
column max_trans format 9999 heading "Max|Trans"
column min_extents format 9999 heading "Min|Ext"
column max_extents format 9999 heading "Max|Ext"
break on owner on tablespace_name
set lines 132 pages 57 feedback off
ttitle "Index Sizing Data"
spool in_siz.lst
select 
	owner,
	index_name,
	tablespace_name,
	initial_extent, 
	next_extent,
	pct_increase,
	pct_free,
	ini_trans,
	max_trans,
	min_extents,
	max_extents 
from 
	dba_indexes
where
	owner not in ('SYS','SYSTEM')
order by
	owner,
	tablespace_name,
	index_name
/
spool off
