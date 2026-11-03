/*
===============================================================================
SCRIPT: bg_event_int.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _background_events_scripts/bg_event_int.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Comparar esperas não Idle de background entre snapshots AWR.

FUNCIONAMENTO DETALHADO
  Outer join por EVENT_ID com snapshots/DBID/instância parametrizados; calcula deltas, segundos e média em ms.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_BG_EVENT_SUMMARY

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Mesma inicialização é obrigatória para deltas válidos. Baseline ausente assume zero. Não representa DB Time de foreground; disponibilidade da view depende da versão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE pBgnSnap = 100
  DEFINE pEndSnap = 101
  DEFINE pDbId = 123456789
  DEFINE pInstNum = 1
  @bg_event_int.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Evento, esperas, timeouts, tempo em segundos, média ms e classe.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Terminador SQL adicionado; proteção DECODE original já evita média com zero esperas. 
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
select
     event "Event Name",
     waits "Waits",
     timeouts "Timeouts",
     time "Wait Time (s)",
     avgwait "Avg Wait (ms)",
     waitclass "Wait Class"
from
    (select e.event_name event
          , e.total_waits - nvl(b.total_waits,0)  waits
          , e.total_timeouts - nvl(b.total_timeouts,0) timeouts
          , (e.time_waited_micro - nvl(b.time_waited_micro,0))/1000000  time
          ,  decode ((e.total_waits - nvl(b.total_waits, 0)), 0, to_number(NULL),
            ((e.time_waited_micro - nvl(b.time_waited_micro,0))/1000) / (e.total_waits - nvl(b.total_waits,0)) ) avgwait
          , e.wait_class waitclass
     from
        dba_hist_bg_event_summary b ,
        dba_hist_bg_event_summary e
     where
                      b.snap_id(+)          = &pBgnSnap
                  and e.snap_id             = &pEndSnap
                  and b.dbid(+)             = &pDbId
                  and e.dbid                = &pDbId
                  and b.instance_number(+)  = &pInstNum
                  and e.instance_number     = &pInstNum
                  and b.event_id(+)         = e.event_id
                  and e.total_waits         > nvl(b.total_waits,0)
                  and e.wait_class          <> 'Idle' )
order by time desc, waits desc;
