/*
===============================================================================
SCRIPT: locks.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/LOCKS.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar locks locais com sessão, modos e identificadores do recurso.

FUNCIONAMENTO DETALHADO
  Une V_$SESSION a DBA_LOCKS por SID/SESSION_ID e ordena pela sessão.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$SESSION, SYS.DBA_LOCKS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não forma cadeia global RAC ou prova de deadlock. OSUSER NULL é rotulado SYS historicamente, sem comprovar identidade; estado muda durante leitura.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @locks.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OSUSER, SESSION_ID, TYPE de lock, MODE_HELD/REQUESTED, LOCK_ID1/2.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  TYPE não qualificado lia tipo de sessão; corrigido para B.LOCK_TYPE com alias TYPE. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem FUNCTION: Report all DB locks
rem
column osuser format a15 heading 'User'
column session_id heading 'SID'
column mode_held format a20 heading 'Mode|Held'
column mode_requested format a20 heading 'Mode|Requested'
column lock_id1 format a10 heading 'Lock|ID1'
column lock_id2 format a10 heading 'Lock|ID2'
column type heading 'Type|Lock'
set feedback off echo off pages 59 lines 131
ttitle 'Report on All Locks'
spool locks.lst
select nvl(a.osuser,'SYS') osuser,b.session_id,b.lock_type type,
mode_held,mode_requested,
lock_id1,lock_id2
from sys.v_$session a, sys.dba_locks b
where
a.sid=b.session_id
order by 2
/
spool off
pause press enter/return to continue 
clear columns
set feedback on echo on pages 22 lines 80
