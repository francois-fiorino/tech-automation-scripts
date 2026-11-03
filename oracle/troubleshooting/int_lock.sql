/*
===============================================================================
SCRIPT: int_lock.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/INT_LOCK.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar locks internos de sessões com filtros de tipo e modo mantido.

FUNCIONAMENTO DETALHADO
  Une DBA_LOCK_INTERNAL a SESSION; aceita ALL ou fragmentos em LOCK_TYPE e MODE_HELD.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_LOCK_INTERNAL, SYS.V_$SESSION

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  View interna/legada pode não estar instalada; verificar catálogo. Não prova cadeia de bloqueio. Hint RULE histórico preservado.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @int_lock.sql
  -- Informar ALL/ALL ou fragmentos controlados.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Holder, SID, tipo, modo mantido/solicitado e IDs do lock.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Reagrupados os ORs para junção por SID ser sempre obrigatória e filtros independentes; NULL username não atribuído a SYS. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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

-- comment: Document current internal locks
rem
column username format a10 heading 'Lock|Holder'
column session_id heading 'User|SID'
column lock_type format a27 heading 'Lock Type'
column mode_held format a10 heading 'Mode|Held'
column mode_requested format a10 heading 'Mode|Requested'
column lock_id1 format a30 heading 'Lock/Cursor|ID1'
column lock_id2 format a10 heading 'Lock|ID2'
prompt 'ALL is all types or modes'
accept lock prompt 'Enter Desired Lock Type: '
accept mode prompt 'Enter Lock Mode: '
set lines 132 pages 59 feedback off echo off verify off
break on username
ttitle 'Report on Internal Locks Mode: &mode Type: &lock'
spool int_lock.lst
select /*+ rule */
	nvl(b.username,'[SEM USERNAME]') username, 
	session_id,lock_type,mode_held,
	mode_requested,lock_id1,lock_id2
from
	sys.dba_lock_internal a, sys.v_$session b
where
 a.session_id=b.sid
 and (upper('&mode')='ALL' or upper(a.mode_held) like upper('%&mode%'))
 and (upper('&lock')='ALL' or upper(a.lock_type) like upper('%&lock%'))
order by 1,2
/
spool off
pause press enter/return to continue
set lines 80 pages 22 feedback on echo on verify on
clear columns
clear breaks
undef lock
undef mode
