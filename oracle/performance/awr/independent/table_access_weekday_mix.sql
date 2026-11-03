/*
SCRIPT: table_access_weekday_mix.sql
CATEGORIA: Oracle / performance/awr / Implementação nova
DATA: 2026-11-03

OBJETIVO
 Comparar presença de acessos FULL e ROWID nos planos observados.

FUNCIONAMENTO E DIFERENÇAS FUNCIONAIS
 Contagem de SQL/plano/snapshot ou execuções de SQL associado a plano não equivale a execuções de operadores. AWR é amostragem seletiva, não captura todo SQL. Chaves DBID/instância/snapshot e plano/container são explícitas; deltas de SQL não são atribuídos como I/O físico exclusivo de cada objeto. Agregação condicional preserva períodos com uma só categoria; um plano pode conter ambas. ROWID é categoria explícita, não todo acesso a índice.

PRÉ-REQUISITOS, DEPENDÊNCIAS E PRIVILÉGIOS
 SQL*Plus ou SQLcl; sessão no container alvo; SELECT autorizado nas views:
 dba_hist_snapshot, dba_hist_sql_plan, dba_hist_sqlstat, v$database.
 Pacotes: conforme código; DBMS_OUTPUT escreve somente na saída do cliente.
 Verificar direito de uso do Diagnostics Pack/AWR/ASH antes de consultar.

PARÂMETROS E EXECUÇÃO
 Binds utilizados: p_days, p_sql_id.
 Editar os valores do bloco de configuração abaixo em cópia local. Nomes de
 objetos são literais de binds, respeitando o case do dicionário; não SQL livre.
 p_days, quando presente, limita a janela de coleta; deve ser positivo.
 p_top, quando presente, deve ser inteiro positivo. Limiares não negativos.
 Exemplo: SQL> @table_access_weekday_mix.sql
 Executar individualmente; não há instalador nem execução em lote do acervo.

RISCOS E IMPACTOS
 Consulta/relatório; não executa DDL nem DML de aplicação.
 Leituras podem consumir CPU/I/O e revelar metadados/texto SQL. Janela e
 privilégios devem ser limitados. Não grava SPOOL automaticamente. SET e binds
 alteram o estado do cliente. Para histórico, DBID é local e container é o da
 sessão, sem misturar PDBs; dados de instâncias permanecem identificados.

COMPATIBILIDADE, VALIDAÇÃO E HOMOLOGAÇÃO
 Alvo documental: Oracle 19c, pelas views/pacotes oficiais referenciados.
 Somente revisão estática; não compilado nem executado em Oracle.
 Não há garantia de compatibilidade 11g–23ai. Validar colunas, grants, escopo
 CDB/PDB, retenção, cardinalidade, custo e resultado em laboratório alvo.
 Uma saída vazia não comprova ausência de atividade ou problema.

PROVENIÊNCIA E MELHORIAS
 Implementação nova do projeto para o requisito funcional descrito acima.
 Correspondência histórica (rastreabilidade, sem republicar a fonte):
 _awr_scripts/awr_sql_full_scans.sql
 Não é mudança cosmética nem afirmação de equivalência byte a byte/funcional
 integral. Fontes originais com avisos restritivos continuam retidas; avisos
 e créditos originais permanecem no acervo privado e não foram relicenciados.
 Algoritmo novo, chaves explícitas, unidades e diferenças descritas acima.

REFERÊNCIAS
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SNAPSHOT.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SQL_PLAN.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SQLSTAT.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-DATABASE.html

AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de
qualquer utilização em produção. Sua execução é de responsabilidade do
profissional responsável pelo ambiente. Os mantenedores deste repositório não
se responsabilizam por indisponibilidade, perda de dados, alterações indevidas
ou outros impactos decorrentes de sua utilização.
*/

set define off
set verify off
set pagesize 100
set linesize 220
set serveroutput on size unlimited
variable p_days number
variable p_sql_id varchar2(13)
begin
 :p_days:=7;
 :p_sql_id:=NULL;
end;
/

WITH workload AS (
 SELECT q.dbid,q.instance_number,q.con_id,q.snap_id,q.sql_id,q.plan_hash_value,
        n.begin_interval_time,n.end_interval_time,
        SUM(q.executions_delta) executions_delta,SUM(q.disk_reads_delta) disk_reads_delta,
        SUM(q.buffer_gets_delta) buffer_gets_delta,SUM(q.rows_processed_delta) rows_processed_delta,
        SUM(q.cpu_time_delta)/1000000 cpu_seconds,
        SUM(q.elapsed_time_delta)/1000000 elapsed_seconds,
        SUM(q.iowait_delta)/1000000 io_wait_seconds,
        SUM(q.apwait_delta)/1000000 application_wait_seconds,
        SUM(q.ccwait_delta)/1000000 concurrency_wait_seconds
 FROM dba_hist_sqlstat q JOIN dba_hist_snapshot n
 ON n.dbid=q.dbid AND n.instance_number=q.instance_number AND n.snap_id=q.snap_id
 WHERE q.dbid=(SELECT dbid FROM v$database)
 AND q.con_id=TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
 AND n.end_interval_time>=SYSTIMESTAMP-NUMTODSINTERVAL(:p_days,'DAY')
 AND (:p_sql_id IS NULL OR q.sql_id=:p_sql_id)
 GROUP BY q.dbid,q.instance_number,q.con_id,q.snap_id,q.sql_id,q.plan_hash_value,
          n.begin_interval_time,n.end_interval_time
)
SELECT instance_number,con_id,TRUNC(CAST(begin_interval_time AS DATE))-TRUNC(CAST(begin_interval_time AS DATE),'IW')+1 period_key,
 SUM(CASE WHEN EXISTS (SELECT 1 FROM dba_hist_sql_plan p WHERE p.dbid=w.dbid AND p.sql_id=w.sql_id AND p.plan_hash_value=w.plan_hash_value AND p.con_id=w.con_id AND p.operation='TABLE ACCESS' AND p.options='FULL') THEN 1 ELSE 0 END) full_plan_observations,
 SUM(CASE WHEN EXISTS (SELECT 1 FROM dba_hist_sql_plan p WHERE p.dbid=w.dbid AND p.sql_id=w.sql_id AND p.plan_hash_value=w.plan_hash_value AND p.con_id=w.con_id AND p.operation='TABLE ACCESS' AND p.options LIKE '%ROWID%') THEN 1 ELSE 0 END) rowid_plan_observations
FROM workload w GROUP BY instance_number,con_id,TRUNC(CAST(begin_interval_time AS DATE))-TRUNC(CAST(begin_interval_time AS DATE),'IW')+1
ORDER BY period_key,instance_number;
