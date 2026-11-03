/*
SCRIPT: system_stat_hour_deltas.sql
CATEGORIA: Oracle / monitoring / Implementação nova
DATA: 2026-11-03

OBJETIVO
 Resumir deltas não negativos de estatística por período.

FUNCIONAMENTO E DIFERENÇAS FUNCIONAIS
 Substitui média de contadores acumulados por soma/média de deltas entre pontos observados. Só usar para estatística cumulativa crescente; gauges não são suportados como delta. Intervalos podem ter durações diferentes; média não é taxa por segundo. Descarta primeiro ponto e reset.

PRÉ-REQUISITOS, DEPENDÊNCIAS E PRIVILÉGIOS
 SQL*Plus ou SQLcl; sessão no container alvo; SELECT autorizado nas views:
 dba_hist_snapshot, dba_hist_sysstat, v$database.
 Pacotes: conforme código; DBMS_OUTPUT escreve somente na saída do cliente.
 Verificar direito de uso do Diagnostics Pack/AWR/ASH antes de consultar.

PARÂMETROS E EXECUÇÃO
 Binds utilizados: p_days, p_stat_name.
 Editar os valores do bloco de configuração abaixo em cópia local. Nomes de
 objetos são literais de binds, respeitando o case do dicionário; não SQL livre.
 p_days, quando presente, limita a janela de coleta; deve ser positivo.
 p_top, quando presente, deve ser inteiro positivo. Limiares não negativos.
 Exemplo: SQL> @system_stat_hour_deltas.sql
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
 _sga_internals_scripts/rpt_sysstat_hr_10g.sql
 Não é mudança cosmética nem afirmação de equivalência byte a byte/funcional
 integral. Fontes originais com avisos restritivos continuam retidas; avisos
 e créditos originais permanecem no acervo privado e não foram relicenciados.
 Algoritmo novo, chaves explícitas, unidades e diferenças descritas acima.

REFERÊNCIAS
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SNAPSHOT.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSSTAT.html
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
variable p_stat_name varchar2(128)
begin
 :p_days:=7;
 :p_stat_name:='physical reads';
end;
/

WITH points AS (
 SELECT h.instance_number,h.con_id,h.stat_name,n.end_interval_time,h.value,
 LAG(h.value) OVER(PARTITION BY h.dbid,h.instance_number,h.con_id,h.stat_id,n.startup_time ORDER BY h.snap_id) prev_value
 FROM dba_hist_sysstat h JOIN dba_hist_snapshot n
 ON n.dbid=h.dbid AND n.instance_number=h.instance_number AND n.snap_id=h.snap_id
 WHERE h.dbid=(SELECT dbid FROM v$database)
 AND h.con_id=TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
 AND h.stat_name=:p_stat_name
 AND n.end_interval_time>=SYSTIMESTAMP-NUMTODSINTERVAL(:p_days,'DAY')
)
SELECT instance_number,con_id,stat_name,TO_NUMBER(TO_CHAR(end_interval_time,'HH24')) period_key,
 COUNT(*) observed_intervals,SUM(value-prev_value) total_delta,AVG(value-prev_value) mean_interval_delta
FROM points WHERE value>=prev_value
GROUP BY instance_number,con_id,stat_name,TO_NUMBER(TO_CHAR(end_interval_time,'HH24')) ORDER BY period_key,instance_number;
