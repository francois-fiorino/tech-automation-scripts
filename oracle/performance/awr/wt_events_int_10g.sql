/*
===============================================================================
SCRIPT: wt_events_int_10g.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _wait_event_scripts/wt_events_int_10g.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Comparar eventos não Idle entre snapshots e sua participação no tempo de espera.

FUNCIONAMENTO DETALHADO
  Faz outer join do fim com início por EVENT_ID e calcula deltas de esperas e microssegundos; converte tempo para segundos e calcula percentual no total não Idle.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_SYSTEM_EVENT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Oracle 10g+. Selecionar snapshots da mesma inicialização. Se um evento não existe no início, numerador usa zero, mas subconsulta correlacionada pelo alias b pode produzir percentual NULL; preservado para validação. Reinícios tornam deltas inválidos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE pBgnSnap = 100
  DEFINE pEndSnap = 101
  DEFINE pDbId = 123456789
  DEFINE pInstNum = 1
  @wt_events_int_10g.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Event, Waits, Wait Time (s), Percent of Total e Wait Class. Percentual é de esperas não Idle, não de DB Time.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF na soma denominadora evita ORA-01476; adicionado terminador SQL. Outer joins legados e baseline preservados. 
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
select event
     , waits "Waits"
     , time "Wait Time (s)"
     , pct*100 "Percent of Total"
     , waitclass "Wait Class"
from (select e.event_name event
                     , e.total_waits - nvl(b.total_waits,0)  waits
                     , (e.time_waited_micro - nvl(b.time_waited_micro,0))/1000000  time
                     , (e.time_waited_micro - nvl(b.time_waited_micro,0))/
                       nullif((select sum(e1.time_waited_micro - nvl(b1.time_waited_micro,0)) from dba_hist_system_event b1 , dba_hist_system_event e1
                        where b1.snap_id(+)          = b.snap_id
                          and e1.snap_id             = e.snap_id
                          and b1.dbid(+)             = b.dbid
                          and e1.dbid                = e.dbid
                          and b1.instance_number(+)  = b.instance_number
                          and e1.instance_number     = e.instance_number
                          and b1.event_id(+)         = e1.event_id
                          and e1.total_waits         > nvl(b1.total_waits,0)
                          and e1.wait_class          <> 'Idle'
  ),0)  pct
                     , e.wait_class waitclass
                 from
                   dba_hist_system_event b ,
                   dba_hist_system_event e
                where b.snap_id(+)          = &pBgnSnap
                  and e.snap_id             = &pEndSnap
                  and b.dbid(+)             = &pDbId
                  and e.dbid                = &pDbId
                  and b.instance_number(+)  = &pInstNum
                  and e.instance_number     = &pInstNum
                  and b.event_id(+)         = e.event_id
                  and e.total_waits         > nvl(b.total_waits,0)
                  and e.wait_class          <> 'Idle'
         order by time desc, waits desc
       );
