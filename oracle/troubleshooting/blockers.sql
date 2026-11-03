/*
===============================================================================
SCRIPT: blockers.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/BLOCKERS.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar locks associados a sessões reportadas como bloqueadoras.

FUNCIONAMENTO DETALHADO
  Une DBA_BLOCKERS a SESSION e DBA_LOCK pelo SID do holder; captura timestamp para spool.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$SESSION, SYS.DBA_BLOCKERS, SYS.DBA_LOCK, DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não comprova deadlock apesar do comentário histórico e não mostra todos os waiters ou cadeia RAC. Inclui locks do holder que podem não ser a causa específica. Timestamp do arquivo tem precisão de minuto.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @blockers.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  SID, username, tipo/modos e IDs dos locks do holder.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta preservada e spool temporal local. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem NAME: blockers.sql
rem FUNCTION: Show all processes causing a dead lock
rem HISTORY: MRA 1/15/96 Created
rem
COLUMN username 		FORMAT a10 	HEADING 'Holding|User'
COLUMN session_id 				HEADING 'SID'
COLUMN mode_held 		FORMAT a20 	HEADING 'Mode|Held'
COLUMN mode_requested 	FORMAT a20 	HEADING 'Mode|Requested'
COLUMN lock_id1 		FORMAT a20 	HEADING 'Lock|ID1'
COLUMN lock_id2 		FORMAT a20 	HEADING 'Lock|ID2'
COLUMN type 					HEADING 'Lock|Type'
COLUMN program			FORMAT a15	HEADING 'Executing|Program'
COLUMN date_now new_value now noprint
SET LINES 132 PAGES 59 FEEDBACK OFF ECHO OFF
SELECT to_char(sysdate,'ddmonyyyyhh24mi') date_now from dual;
ttitle 'Sessions Blocking Other Sessions Report'
spool blockers_&&now..lst
SELECT 
	a.session_id, 
	username, 
	type, 
	mode_held, 
	mode_requested,
	lock_id1, 
	lock_id2 
FROM
	sys.v_$session b, 
	sys.dba_blockers c, 
	sys.dba_lock a
WHERE
	c.holding_session=a.session_id and
	c.holding_session=b.sid
/
SPOOL OFF
PAUSE press enter/return to continue
CLEAR COLUMNS
SET LINES 80 PAGES 22 FEEDBACK ON 
ttitle off



