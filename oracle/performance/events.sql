/*
===============================================================================
SCRIPT: events.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/EVENTS.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Agregar esperas acumuladas de sessões por usuário e evento.

FUNCIONAMENTO DETALHADO
  Une SESSION_EVENT a SESSION por SID; exclui padrões históricos de eventos e soma esperas, timeouts e centésimos de segundo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$SESSION_EVENT, SYS.V_$SESSION

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Sessões têm tempos de vida distintos; não é intervalo de medição nem espera atual. Filtros textuais não equivalem à classe Idle.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @events.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Usuário, evento, esperas/timeouts, tempo total e média ponderada em centésimos de segundo.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  AVG de médias substituído por SUM(TIME_WAITED)/NULLIF(SUM(TOTAL_WAITS),0); NULL username identificado sem atribuição a SYS. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Título externo convertido em TTITLE nativo.
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

-- comment:  Generate a report on session events by user
rem
rem events.sql 
rem
column sid            heading Sid
column event          heading Event            format a40
column total_waits    heading Total|Waits
column total_timeouts heading Total|Timeouts
column time_waited    heading Time|Waited
column average_wait   heading Average|Wait
column username       heading User
break on username
ttitle "Session Events By User"
spool events.lst
set lines 132 pages 59
select 
	nvl(username,'[SEM USERNAME]') username, event, sum(total_waits) total_waits, 
        sum(total_timeouts) total_timeouts,
	sum(time_waited) time_waited, sum(time_waited)/nullif(sum(total_waits),0) average_wait 
from 
	sys.v_$session_event a, sys.v_$session b
where 
	a.sid= b.sid
and event not like 'SQL*Net%'
	and event not like 'smon%'
	and event not like 'pmon%'
	and event not like 'rdbms%'
	and event not like '%control%'
	and event not like 'LGWR%'
        and event not like 'PX%'
group by nvl(username,'[SEM USERNAME]'),event
order by 1,5 desc; 
spool off
pause Press enter to continue
clear columns
clear breaks
set lines 80 pages 22
ttitle off
