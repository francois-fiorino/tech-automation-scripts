/*
===============================================================================
SCRIPT: awr_high_resource_sql.sql
CATEGORIA: Oracle / Performance
ORIGEM: Coleção Oracle 2015

OBJETIVO E FUNCIONAMENTO
  Conta linhas de plano com TABLE ACCESS FULL em segmentos maiores que 1 MB, agrupadas pelo usuário que fez o parse. A contagem não representa execuções; junções por HASH_VALUE podem associar cursores incorretamente.

PRÉ-REQUISITOS
  Acesso de leitura a SYS.V_$SQL_PLAN, SYS.DBA_SEGMENTS, SYS.DBA_USERS, SYS.V_$SQL.

EXECUÇÃO
  SQL> @awr_high_resource_sql.sql
  Executar somente após revisão integral e teste em ambiente controlado.

SAÍDA ESPERADA
  USERNAME e SCAN_COUNT.

RISCOS E LIMITAÇÕES
  Consulta somente leitura, potencial custo nas views; limite de 1 MB é fixo.
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
    c.username username,
    count(a.hash_value) scan_count 
from
    sys.v_$sql_plan a, 
    sys.dba_segments b, 
    sys.dba_users c, 
    sys.v_$sql d 
where
     a.object_owner (+) = b.owner 
and
     a.object_name (+) = b.segment_name 
and
     b.segment_type IN ('TABLE', 'TABLE PARTITION') 
and
     a.operation like '%TABLE%' 
and
     a.options = 'FULL' 
and
     c.user_id = d.parsing_user_id 
and
     d.hash_value = a.hash_value 
and
     b.bytes / 1024 > 1024 
group by
     c.username 
order by
     2 desc
;
