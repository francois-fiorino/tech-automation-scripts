/*
SCRIPT: library_cache_reload_deltas.sql
CATEGORIA: Oracle / memory / Implementação nova
DATA: 2026-11-03

OBJETIVO
 Calcular reloads por pins em intervalos históricos de library cache.

FUNCIONAMENTO E DIFERENÇAS FUNCIONAIS
 Pins não equivalem a execuções de SQL. Reload/pin não representa todos os tipos de miss; mantém namespace separado e evita deltas através de restart/reset.

PRÉ-REQUISITOS, DEPENDÊNCIAS E PRIVILÉGIOS
 SQL*Plus ou SQLcl; sessão no container alvo; SELECT autorizado nas views:
 dba_hist_librarycache, dba_hist_snapshot, v$database.
 Pacotes: conforme código; DBMS_OUTPUT escreve somente na saída do cliente.
 Verificar direito de uso do Diagnostics Pack/AWR/ASH antes de consultar.

PARÂMETROS E EXECUÇÃO
 Binds utilizados: p_days.
 Editar os valores do bloco de configuração abaixo em cópia local. Nomes de
 objetos são literais de binds, respeitando o case do dicionário; não SQL livre.
 p_days, quando presente, limita a janela de coleta; deve ser positivo.
 p_top, quando presente, deve ser inteiro positivo. Limiares não negativos.
 Exemplo: SQL> @library_cache_reload_deltas.sql
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
 _sga_internals_scripts/rpt_10g_lib_miss.sql
 Não é mudança cosmética nem afirmação de equivalência byte a byte/funcional
 integral. Fontes originais com avisos restritivos continuam retidas; avisos
 e créditos originais permanecem no acervo privado e não foram relicenciados.
 Algoritmo novo, chaves explícitas, unidades e diferenças descritas acima.

REFERÊNCIAS
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_LIBRARYCACHE.html
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

WITH points AS (
 SELECT h.instance_number,h.con_id,h.namespace,n.end_interval_time,h.pins,h.reloads,
 LAG(h.pins) OVER(PARTITION BY h.dbid,h.instance_number,h.con_id,h.namespace,n.startup_time ORDER BY h.snap_id) prev_pins,
 LAG(h.reloads) OVER(PARTITION BY h.dbid,h.instance_number,h.con_id,h.namespace,n.startup_time ORDER BY h.snap_id) prev_reloads
 FROM dba_hist_librarycache h JOIN dba_hist_snapshot n
 ON n.dbid=h.dbid AND n.instance_number=h.instance_number AND n.snap_id=h.snap_id
 WHERE h.dbid=(SELECT dbid FROM v$database)
 AND h.con_id=TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
 AND n.end_interval_time>=SYSTIMESTAMP-NUMTODSINTERVAL(:p_days,'DAY')
)
SELECT instance_number,con_id,namespace,end_interval_time,pins-prev_pins pins_delta,
 reloads-prev_reloads reload_delta,
 (reloads-prev_reloads)/NULLIF(pins-prev_pins,0) reload_per_pin
FROM points WHERE pins>=prev_pins AND reloads>=prev_reloads
ORDER BY end_interval_time,instance_number,namespace;
