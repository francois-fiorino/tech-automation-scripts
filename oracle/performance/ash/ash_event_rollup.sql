/*
===============================================================================
SCRIPT: ash_event_rollup.sql
CATEGORIA: Oracle / performance/ash
ORIGEM: Oracle Script Collection 2015 / _ash_scripts/ash_event_rollup.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Agrupar amostras ASH por hora e evento após exclusões textuais.

FUNCIONAMENTO DETALHADO
  Agrupa SAMPLE_TIME formatado por hora e EVENT; exige COUNT(EVENT)>100 e soma TIME_WAITED.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  V$ACTIVE_SESSION_HISTORY

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Contagem não é número de esperas. Soma amostrada não garante duração total correta. Eventos CPU/NULL são excluídos pelos filtros; retenção em memória limita histórico.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @ash_event_rollup.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  MYDATE, EVENT, TOTAL_WAITS como contagem de amostras e TIME_WAITED somado.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  BREAK de coluna inexistente SNAP_TIME substituído por MYDATE; cálculo original preservado com ressalvas. 
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



ttitle 'High waits on events|Rollup by hour'


column mydate heading 'Yr.  Mo Dy Hr'     format a13;
column event                              format a30;
column total_waits    heading 'tot waits' format 999,999;
column time_waited    heading 'time wait' format 999,999;
column total_timeouts heading 'timeouts'  format 9,999;

break on mydate skip 1;
  select 
   to_char(e.sample_time,'yyyy-mm-dd HH24')   mydate,
   e.event,
   count(e.event)                               total_waits,
   sum(e.time_waited)                           time_waited
from 
   v$active_session_history e
where
   e.event not like '%timer' 
and 
   e.event not like '%message%'
and 
   e.event not like '%slave wait%'
having
   count(e.event) > 100
group by
   to_char(e.sample_time,'yyyy-mm-dd HH24'),
   e.event
order by 1     
;
