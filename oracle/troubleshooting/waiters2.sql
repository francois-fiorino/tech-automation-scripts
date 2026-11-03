/*
===============================================================================
SCRIPT: waiters2.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _wait_event_scripts/waiters2.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Mostrar pares de sessões locais em espera por locks sem wrapper de títulos.

FUNCIONAMENTO DETALHADO
  Consulta DBA_WAITERS e associa sessões bloqueadora e bloqueada a V_$SESSION; grava waiters.lst e aguarda ENTER.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$SESSION, SYS.DBA_WAITERS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Versão alternativa histórica de WAITERS.SQL; preservada como arquivo distinto, sem dependência de title132. Não fornece cadeia RAC completa.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @waiters2.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  SIDs, usuários, tipo, modos e identificadores do lock.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  SQL original preservado. 
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
rem FUNCTION: Report on sessions waiting for locks
rem
column busername format a10 heading 'Holding|User'
column wusername format a10 Heading 'Waiting|User'
column bsession_id heading 'Holding|SID'
column wsession_id heading 'Waiting|SID'
column mode_held format a20 heading 'Mode|Held'
column mode_requested format a20 heading 'Mode|Requested'
column lock_id1 format a20 heading 'Lock|ID1'
column lock_id2 format a20 heading 'Lock|ID2'
column type heading 'Lock|Type'
set lines 132 pages 59 feedback off echo off
ttitle 'Processes Waiting on Locks Report'
spool waiters
select 
	holding_session bsession_id, 
	waiting_session wsession_id, 
	b.username busername, 
	a.username wusername, 
	c.lock_type type, 
	mode_held, mode_requested,
	lock_id1, lock_id2 
from
sys.v_$session b, sys.dba_waiters c, sys.v_$session a 
where
c.holding_session=b.sid and
c.waiting_session=a.sid
/
spool off
pause press enter/return to continue
clear columns
set lines 80 pages 22 feedback on echo on
ttitle off
