/*
===============================================================================
SCRIPT: statspack_alert.sql
CATEGORIA: Oracle / performance/statspack
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/statspack_alert.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Reproduzir alertas históricos sobre contadores acumulados do STATSPACK.

FUNCIONAMENTO DETALHADO
  Seis consultas por janela de dias analisam buffer ratio, sorts, file waits, buffer busy, redo requests e continued rows, com joins por snapshot/DBID/instância.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  PERFSTAT.STATS$SYSSTAT, PERFSTAT.STATS$SNAPSHOT, PERFSTAT.STATS$FILESTATXS, PERFSTAT.STATS$BUFFER_POOL_STATISTICS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  STATSPACK instalado, grants às tabelas e contrato de colunas compatível. Statistic#39/38/40/41 são fixos e podem representar outras métricas em versões diferentes. Prompts históricos sugerem parâmetros; não são recomendações atuais. AVG de acumulados não representa média de espera por operação.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @statspack_alert.sql 7
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Resultados que excedem limiares históricos; contadores acumulados/gauges agregados, não taxas horárias.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF nos divisores e chaves DBID/INSTANCE_NUMBER em todos os joins; seis blocos e prompts/créditos preservados. Não substitui análise por deltas homologada. 
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
--*********************************************************** 
-- 
-- STATSPACK alert report for the DBA 
-- 
-- comment:  alerts for out of bounds database conditions
-- 
-- This script accepts the "number of days back" as an imput parameter 
-- 
-- This script can be scheduled to run daily via cron or OEM 
-- and e-mail the results to the on-call DBA 
-- 
--*********************************************************** 
set pages 9999; 
set feedback off; 
set verify off; 
--*********************************************************** 
-- Alert when data buffer hit ratio is below threshold 
--*********************************************************** 
prompt 
prompt 
prompt *********************************************************** 
prompt When the data buffer hit ratio falls below 90%, you 
prompt should consider adding to the db_block_buffer init.ora parameter 
prompt 
prompt See p. 171 "High Performance Oracle8 Tuning" by Don Burleson 
prompt 
prompt *********************************************************** 
prompt 
prompt 
column logical_reads format 999,999,999 
column phys_reads format 999,999,999 
column phys_writes format 999,999,999 
column "BUFFER HIT RATIO" format 999 
select to_char(snap_time,'yyyy-mm-dd HH24'), 
-- 
a.value + b.value "logical_reads", 
-- 
c.value "phys_reads", 
-- 
d.value "phys_writes", 
round(100 * ((a.value+b.value)-c.value) / nullif(a.value+b.value,0)) "BUFFER HIT RATIO" 
from perfstat.stats$sysstat a, perfstat.stats$sysstat b, 
perfstat.stats$sysstat c, perfstat.stats$sysstat d, 
perfstat.stats$snapshot sn 
where (round(100 * ((a.value+b.value)-c.value) / nullif(a.value+b.value,0)) ) < 90 
and snap_time > sysdate-&1 
and a.snap_id = sn.snap_id and a.dbid=sn.dbid and a.instance_number=sn.instance_number 
and b.snap_id = sn.snap_id and b.dbid=sn.dbid and b.instance_number=sn.instance_number 
and c.snap_id = sn.snap_id and c.dbid=sn.dbid and c.instance_number=sn.instance_number 
and d.snap_id = sn.snap_id and d.dbid=sn.dbid and d.instance_number=sn.instance_number 
and a.statistic# = 39 
and b.statistic# = 38 
and c.statistic# = 40 
and d.statistic# = 41 ; 
--*********************************************************** 
-- Alert when total disk sorts are below threshold 
--*********************************************************** 
prompt 
prompt 
prompt *********************************************************** 
prompt When there are high disk sorts, you should investigate 
prompt increasing sort_area_size, or adding indexes to force index_full scans 
prompt 
prompt See p. 167 "High Performance Oracle8 Tuning" by Don Burleson 
prompt 
prompt *********************************************************** 
prompt 
prompt 
column sorts_memory format 999,999,999 
column sorts_disk format 999,999,999 
column ratio format .99999 
select to_char(snap_time,'yyyy-mm-dd HH24'), a.value sorts_memory, 
b.value sorts_disk, (b.value/nullif(a.value,0)) ratio 
from perfstat.stats$sysstat a, perfstat.stats$sysstat b, 
perfstat.stats$snapshot sn 
where 
-- Where there are more than 200 disk sorts per hour 
b.value > 200 and snap_time > sysdate-&1 
and a.snap_id = sn.snap_id and a.dbid=sn.dbid and a.instance_number=sn.instance_number 
and b.snap_id = sn.snap_id and b.dbid=sn.dbid and b.instance_number=sn.instance_number 
and a.name = 'sorts (memory)' 
and b.name = 'sorts (disk)' ; 
--*********************************************************** 
-- Alert when total I/O wait count is above threshold
--*********************************************************** 
prompt 
prompt 
prompt *********************************************************** 
prompt When there is high I/O waits, disk bottlenecks may exist 
prompt Run iostats to find the hot disk and shuffle files to 
prompt remove the contention 
prompt 
prompt See p. 191 "High Performance Oracle8 Tuning" by Don Burleson 
prompt 
prompt *********************************************************** 
prompt 
prompt 
break on snapdate skip 2 
column snapdate format a16 
column filename format a40 
select to_char(snap_time,'yyyy-mm-dd HH24') snapdate, filename, wait_count 
from perfstat.stats$filestatxs fs, perfstat.stats$snapshot sn 
where snap_time > sysdate-&1 and fs.snap_id = sn.snap_id and fs.dbid=sn.dbid and fs.instance_number=sn.instance_number and wait_count > 800 ; 
--*********************************************************** 
-- Alert when average buffer busy waits exceed threshold 
--*********************************************************** 
prompt 
prompt 
prompt *********************************************************** 
prompt Buffer Bury Waits may signal a high update table with too 
prompt few freelists. Find the offending table and add more freelists. 
prompt 
prompt See p. 134 "Oracle SAP Administration" by Don Burleson 
prompt 
prompt *********************************************************** 
prompt 
prompt 
column buffer_busy_wait format 999,999,999 
select to_char(snap_time,'yyyy-mm-dd HH24'), avg(buffer_busy_wait) buffer_busy_wait 
from perfstat.stats$buffer_pool_statistics fs, perfstat.stats$snapshot sn 
where snap_time > sysdate-&1 and fs.snap_id = sn.snap_id and fs.dbid=sn.dbid and fs.instance_number=sn.instance_number having avg(buffer_busy_wait) > 100 
group by to_char(snap_time,'yyyy-mm-dd HH24') ; 
--*********************************************************** 
-- Alert when total redo log space requests exceed threshold 
--*********************************************************** 
prompt 
prompt 
prompt *********************************************************** 
prompt High redo log space requests indicate a need to increase 
prompt the log_buffer parameter 
prompt 
prompt 
prompt *********************************************************** 
prompt 
prompt 
column redo_log_space_requests format 999,999,999 
select to_char(snap_time,'yyyy-mm-dd HH24') snap_date, a.value redo_log_space_requests 
from perfstat.stats$sysstat a, perfstat.stats$snapshot sn 
where snap_time > sysdate-&1 and a.value > 300 
and a.snap_id = sn.snap_id and a.dbid=sn.dbid and a.instance_number=sn.instance_number 
and a.name = 'redo log space requests' ; 
--*********************************************************** 
-- Alert when table_fetch_continued_row exceeds threshold 
--*********************************************************** 
prompt 
prompt 
prompt *********************************************************** 
prompt Table fetch continued row indicates chained rows, or fetches of 
prompt long datatypes (long raw, blob) 
prompt 
prompt Investigate increasing db_block_size or reorganizing tables 
prompt with chained rows. 
prompt 
prompt See p. 381 "High Performance Oracle8 Tuning" by Don Burleson 
prompt See p. 102 "Oracle SAP Administration" by Don Burleson 
prompt 
prompt *********************************************************** 
prompt 
prompt 
column table_fetch_continued_row format 999,999,999 
select to_char(snap_time,'yyyy-mm-dd HH24'), avg(a.value) table_fetch_continued_row 
from perfstat.stats$sysstat a, perfstat.stats$snapshot sn 
where snap_time > sysdate-&1 
and a.snap_id = sn.snap_id and a.dbid=sn.dbid and a.instance_number=sn.instance_number 
and a.name = 'table fetch continued row' 
having avg(a.value) > 100000 group by to_char(snap_time,'yyyy-mm-dd HH24') ;

