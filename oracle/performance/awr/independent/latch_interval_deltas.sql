/*
SCRIPT: latch_interval_deltas.sql
CATEGORIA: Oracle / performance/awr / Implementação nova
DATA: 2026-11-03

OBJETIVO
 Medir deltas de latches entre snapshots observados.

FUNCIONAMENTO E DIFERENÇAS FUNCIONAIS
 LAG separado por DBID, instância, container, latch e startup; remove primeiro ponto e reset. Gaps abrangem snapshots observados, sem presumir SNAP_ID consecutivo.

PRÉ-REQUISITOS, DEPENDÊNCIAS E PRIVILÉGIOS
 SQL*Plus ou SQLcl; sessão no container alvo; SELECT autorizado nas views:
 dba_hist_latch, dba_hist_snapshot, v$database.
 Pacotes: conforme código; DBMS_OUTPUT escreve somente na saída do cliente.
 Verificar direito de uso do Diagnostics Pack/AWR/ASH antes de consultar.

PARÂMETROS E EXECUÇÃO
 Binds utilizados: p_days.
 Editar os valores do bloco de configuração abaixo em cópia local. Nomes de
 objetos são literais de binds, respeitando o case do dicionário; não SQL livre.
 p_days, quando presente, limita a janela de coleta; deve ser positivo.
 p_top, quando presente, deve ser inteiro positivo. Limiares não negativos.
 Exemplo: SQL> @latch_interval_deltas.sql
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
 _ash_scripts/ash_latch.sql
 Não é mudança cosmética nem afirmação de equivalência byte a byte/funcional
 integral. Fontes originais com avisos restritivos continuam retidas; avisos
 e créditos originais permanecem no acervo privado e não foram relicenciados.
 Algoritmo novo, chaves explícitas, unidades e diferenças descritas acima.

REFERÊNCIAS
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_LATCH.html
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
 SELECT h.dbid,h.instance_number,h.con_id,h.latch_hash,h.latch_name,
        n.snap_id,n.end_interval_time,n.startup_time,h.gets,h.misses,h.sleeps,
        LAG(h.gets) OVER(PARTITION BY h.dbid,h.instance_number,h.con_id,h.latch_hash,n.startup_time ORDER BY n.snap_id) prev_gets,
        LAG(h.misses) OVER(PARTITION BY h.dbid,h.instance_number,h.con_id,h.latch_hash,n.startup_time ORDER BY n.snap_id) prev_misses,
        LAG(h.sleeps) OVER(PARTITION BY h.dbid,h.instance_number,h.con_id,h.latch_hash,n.startup_time ORDER BY n.snap_id) prev_sleeps
 FROM dba_hist_latch h JOIN dba_hist_snapshot n
 ON n.dbid=h.dbid AND n.instance_number=h.instance_number AND n.snap_id=h.snap_id
 WHERE h.dbid=(SELECT dbid FROM v$database)
   AND h.con_id=TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
   AND n.end_interval_time >= SYSTIMESTAMP-NUMTODSINTERVAL(:p_days,'DAY')
)
SELECT instance_number,con_id,snap_id,end_interval_time,latch_name,
       gets-prev_gets gets_delta,misses-prev_misses misses_delta,sleeps-prev_sleeps sleeps_delta
FROM counters WHERE gets>=prev_gets AND misses>=prev_misses AND sleeps>=prev_sleeps
ORDER BY end_interval_time,instance_number,misses_delta DESC;
