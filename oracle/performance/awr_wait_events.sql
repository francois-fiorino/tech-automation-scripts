/*
===============================================================================
SCRIPT: awr_wait_events.sql
CATEGORIA: Oracle / Performance
ORIGEM: Coleção Oracle 2015

OBJETIVO E FUNCIONAMENTO
  Calcula tempo médio em milissegundos para db file sequential read usando deltas de TIME_WAITED_MICRO e TOTAL_WAITS entre snapshots AWR adjacentes da instância 1.

PRÉ-REQUISITOS
  Acesso de leitura a DBA_HIST_SYSTEM_EVENT, DBA_HIST_SNAPSHOT; verificar licenciamento Diagnostics Pack.

EXECUÇÃO
  SQL> @awr_wait_events.sql
  Executar somente após revisão integral e teste em ambiente controlado.

SAÍDA ESPERADA
  END_INTERVAL_TIME, AVE READ MILLISECONDS, NUMBER OF READS, EVENT_NAME.

RISCOS E LIMITAÇÕES
  Consulta somente leitura; divisão por zero quando não há novas esperas; SNAP_ID + 1 não garante intervalo adequado e falta correspondência explícita por DBID.
  Compatibilidade não homologada; análise estática, sem execução em banco.

AVISO DE RESPONSABILIDADE
  Fornecido AS IS, sem garantias. Uso por conta e risco do executor.
  Os mantenedores não assumem responsabilidade por danos ou perdas
  decorrentes do uso, nos limites permitidos pela legislação aplicável.

PRESERVAÇÃO
  SQL original reproduzido abaixo sem alterações funcionais.
===============================================================================
*/

-- Historical single block read wait time script

select 
   sn.end_interval_time,
   trunc((e.time_waited_micro-b.time_waited_micro)/
   (1000*(e.total_waits-b.total_waits))) 
   "ave read milliseconds",
(e.total_waits-b.total_waits) "number of reads",
   b.event_name
from 
   dba_hist_system_event b, 
   dba_hist_system_event e,
   dba_hist_snapshot     sn
where 
   b.event_name='db file sequential read' 
and
   e.event_name=b.event_name 
and
   e.snap_id=b.snap_id+1 
and
   e.instance_number=1 
and
   b.instance_number=e.instance_number 
and
   e.snap_id=sn.snap_id 
and
   e.instance_number=sn.instance_number
order by 
   e.snap_id;
