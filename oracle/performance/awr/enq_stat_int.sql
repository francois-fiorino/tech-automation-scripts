/*
===============================================================================
SCRIPT: enq_stat_int.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/enq_stat_int.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Apresentar deltas de enqueues entre dois snapshots.

FUNCIONAMENTO DETALHADO
  Pareia ENQUEUE_STAT por tipo/motivo, DBID e instância, enriquece com LOCK_TYPE e filtra aumento de esperas.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_ENQUEUE_STAT, V$LOCK_TYPE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Definir pBgnSnap, pEndSnap, pDbId e pInstNum com snapshots crescentes da mesma instância, DBID e STARTUP_TIME. Reinício ou baseline ausente pode invalidar deltas. Validar CON_ID e unicidade das linhas na versão; modelo histórico 10g. Baseline ausente é tratado como zero, podendo superestimar intervalo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE pBgnSnap = 100
  DEFINE pEndSnap = 101
  DEFINE pDbId = 123456789
  DEFINE pInstNum = 1
  @enq_stat_int.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tipo/motivo, requests, gets/falhas, esperas, segundos acumulados e média em ms.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Aspas tipográficas do alias corrigidas e terminador SQL adicionado. Não é relatório de buffer pools, apesar de uma cópia ter esse nome. 
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
  ety "Enqueue",
  reqs "Requests",
  sreq "Successful Gets",
  freq "Failed Gets",
  waits "Waits",
  wttm "Wait Time (s)",
  awttm "Average Wait Time(ms)"
from (
select /*+ ordered */
         e.eq_type || '-' || to_char(nvl(l.name,' '))
      || decode( upper(e.req_reason)
               , 'CONTENTION', null
               , '-',          null
               , ' ('||e.req_reason||')')                ety
     , e.total_req#    - nvl(b.total_req#,0)            reqs
     , e.succ_req#     - nvl(b.succ_req#,0)             sreq
     , e.failed_req#   - nvl(b.failed_req#,0)           freq
     , e.total_wait#   - nvl(b.total_wait#,0)           waits
     , (e.cum_wait_time - nvl(b.cum_wait_time,0))/1000  wttm
     , decode(  (e.total_wait#   - nvl(b.total_wait#,0))
               , 0, to_number(NULL)
               , (  (e.cum_wait_time - nvl(b.cum_wait_time,0))
                  / (e.total_wait#   - nvl(b.total_wait#,0))
                 )
             )                                          awttm
  from dba_hist_enqueue_stat e
     , dba_hist_enqueue_stat b
     , v$lock_type              l
where b.snap_id(+)         = &pBgnSnap
   and e.snap_id            = &pEndSnap
   and b.dbid(+)            = &pDbId
   and e.dbid               = &pDbId
   and b.dbid(+)            = e.dbid
   and b.instance_number(+) = &pInstNum
   and e.instance_number    = &pInstNum
   and b.instance_number(+) = e.instance_number
   and b.eq_type(+)         = e.eq_type
   and b.req_reason(+)      = e.req_reason
   and e.total_wait# - nvl(b.total_wait#,0) > 0
   and l.type(+)            = e.eq_type
 order by wttm desc, waits desc);
