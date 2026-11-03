/*
SCRIPT: buffer_hit_weekday_deltas.sql
CATEGORIA: Oracle / memory / Implementação nova
DATA: 2026-11-03

OBJETIVO
 Calcular hit ratio ponderado por deltas do buffer cache.

FUNCIONAMENTO E DIFERENÇAS FUNCIONAIS
 Usa razão de somas de deltas em vez de média de razões cumulativas; NULL em ausência de leituras lógicas. Reinícios/reset são excluídos. Resultado negativo não é truncado artificialmente. LIB_CACHE_INT da fonte era relatório de buffer cache, não library cache. Métrica isolada não decide expansão/rebuild.

PRÉ-REQUISITOS, DEPENDÊNCIAS E PRIVILÉGIOS
 SQL*Plus ou SQLcl; sessão no container alvo; SELECT autorizado nas views:
 dba_hist_buffer_pool_stat, dba_hist_snapshot, v$database.
 Pacotes: conforme código; DBMS_OUTPUT escreve somente na saída do cliente.
 Verificar direito de uso do Diagnostics Pack/AWR/ASH antes de consultar.

PARÂMETROS E EXECUÇÃO
 Binds utilizados: p_days.
 Editar os valores do bloco de configuração abaixo em cópia local. Nomes de
 objetos são literais de binds, respeitando o case do dicionário; não SQL livre.
 p_days, quando presente, limita a janela de coleta; deve ser positivo.
 p_top, quando presente, deve ser inteiro positivo. Limiares não negativos.
 Exemplo: SQL> @buffer_hit_weekday_deltas.sql
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
 _awr_scripts/rpt_bhr_awr_dy.sql; _sga_internals_scripts/lib_cache_int.sql
 Não é mudança cosmética nem afirmação de equivalência byte a byte/funcional
 integral. Fontes originais com avisos restritivos continuam retidas; avisos
 e créditos originais permanecem no acervo privado e não foram relicenciados.
 Algoritmo novo, chaves explícitas, unidades e diferenças descritas acima.

REFERÊNCIAS
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_BUFFER_POOL_STAT.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SNAPSHOT.html
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
begin
 :p_days:=7;
end;
/

WITH counters AS (
 SELECT b.dbid,b.instance_number,b.con_id,b.id,b.block_size,b.name,n.startup_time,n.end_interval_time,n.snap_id,
 b.consistent_gets+b.db_block_gets logical_reads,b.physical_reads,
 LAG(b.consistent_gets+b.db_block_gets) OVER(PARTITION BY b.dbid,b.instance_number,b.con_id,b.id,b.block_size,n.startup_time ORDER BY n.snap_id) prev_logical,
 LAG(b.physical_reads) OVER(PARTITION BY b.dbid,b.instance_number,b.con_id,b.id,b.block_size,n.startup_time ORDER BY n.snap_id) prev_physical
 FROM dba_hist_buffer_pool_stat b JOIN dba_hist_snapshot n
 ON n.dbid=b.dbid AND n.instance_number=b.instance_number AND n.snap_id=b.snap_id
 WHERE b.dbid=(SELECT dbid FROM v$database)
 AND b.con_id=TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
 AND n.end_interval_time>=SYSTIMESTAMP-NUMTODSINTERVAL(:p_days,'DAY')
), deltas AS (
 SELECT c.*,logical_reads-prev_logical logical_delta,physical_reads-prev_physical physical_delta
 FROM counters c WHERE logical_reads>=prev_logical AND physical_reads>=prev_physical
)
SELECT instance_number,con_id,name,block_size,TRUNC(CAST(end_interval_time AS DATE))-TRUNC(CAST(end_interval_time AS DATE),'IW')+1 period_key,
 SUM(logical_delta) logical_reads,SUM(physical_delta) physical_reads,
 ROUND(100*(1-SUM(physical_delta)/NULLIF(SUM(logical_delta),0)),4) hit_pct
FROM deltas GROUP BY instance_number,con_id,name,block_size,TRUNC(CAST(end_interval_time AS DATE))-TRUNC(CAST(end_interval_time AS DATE),'IW')+1
ORDER BY period_key,instance_number,name,block_size;
