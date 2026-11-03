/*
===============================================================================
SCRIPT: awr_high_scan_sql.sql
CATEGORIA: Oracle / Performance
ORIGEM: Coleção Oracle 2015

OBJETIVO E FUNCIONAMENTO
  Lista textos SQL com operações TABLE ACCESS FULL em segmentos maiores que 1 MB, agregando linhas de plano e multiplicando por EXECUTIONS. O produto é indicador aproximado, não contagem observada de scans.

PRÉ-REQUISITOS
  Acesso de leitura a SYS.V_$SQL_PLAN, SYS.DBA_SEGMENTS, SYS.V_$SQL.

EXECUÇÃO
  SQL> @awr_high_scan_sql.sql
  Executar somente após revisão integral e teste em ambiente controlado.

SAÍDA ESPERADA
  SQL_TEXT, TOTAL_LARGE_SCANS, EXECUTIONS, SUM_LARGE_SCANS.

RISCOS E LIMITAÇÕES
  Consulta somente leitura; junção por HASH_VALUE e agrupamento por texto podem distorcer valores.
  Compatibilidade não homologada; análise estática, sem execução em banco.

AVISO DE RESPONSABILIDADE
  Fornecido AS IS, sem garantias. Uso por conta e risco do executor.
  Os mantenedores não assumem responsabilidade por danos ou perdas
  decorrentes do uso, nos limites permitidos pela legislação aplicável.

PRESERVAÇÃO
  SQL original reproduzido abaixo sem alterações funcionais.
===============================================================================
*/

/*  */
select
     sql_text, 
     total_large_scans, 
       executions, 
       executions * total_large_scans sum_large_scans 
from 
(select 
       sql_text, 
       count(*) total_large_scans, 
       executions 
 from 
       sys.v_$sql_plan a, 
       sys.dba_segments b, 
       sys.v_$sql c 
 where
       a.object_owner (+) = b.owner 
   and
       a.object_name (+) = b.segment_name 
   and
       b.segment_type IN ('TABLE', 'TABLE PARTITION') 
   and
       a.operation LIKE '%TABLE%' 
   and
       a.options = 'FULL' 
   and
       c.hash_value = a.hash_value 
   and
       b.bytes / 1024 > 1024 
   group by 
      sql_text, executions) 
order by
   4 desc
;
