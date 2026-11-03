/*
===============================================================================
SCRIPT: sys_event_int_10g.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/sys_event_int_10g.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Calcular esperas não Idle entre snapshots de sistema.

FUNCIONAMENTO DETALHADO
  Outer join por EVENT_ID com DBID/instância parametrizados; subtrai contadores e converte TIME_WAITED_MICRO para segundos/média ms.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_SYSTEM_EVENT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Definir pBgnSnap, pEndSnap, pDbId e pInstNum com snapshots crescentes da mesma instância, DBID e STARTUP_TIME. Reinício ou baseline ausente pode invalidar deltas. Validar CON_ID e unicidade das linhas na versão; modelo histórico 10g. Ausência de baseline vira zero; dados abrangem estatísticas da view, não somente uma sessão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE pBgnSnap = 100
  DEFINE pEndSnap = 101
  DEFINE pDbId = 123456789
  DEFINE pInstNum = 1
  @sys_event_int_10g.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Evento, waits/timeouts, segundos, média em ms e classe.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Adicionado terminador SQL; DECODE original preservado. 
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
        dba_hist_system_event b ,
        dba_hist_system_event e
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
