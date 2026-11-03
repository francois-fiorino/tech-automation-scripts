/*
SCRIPT: time_model_interval_deltas.sql
CATEGORIA: Oracle / performance/awr / Implementação nova
DATA: 2026-11-03

OBJETIVO
 Exibir variações do time model histórico por estatística.

FUNCIONAMENTO E DIFERENÇAS FUNCIONAIS
 Deltas em microssegundos convertidos para segundos, isolando reinícios. Estatísticas pai/filho não devem ser somadas indiscriminadamente; primeira amostra não gera delta.

PRÉ-REQUISITOS, DEPENDÊNCIAS E PRIVILÉGIOS
 SQL*Plus ou SQLcl; sessão no container alvo; SELECT autorizado nas views:
 dba_hist_snapshot, dba_hist_sys_time_model, v$database.
 Pacotes: conforme código; DBMS_OUTPUT escreve somente na saída do cliente.
 Verificar direito de uso do Diagnostics Pack/AWR/ASH antes de consultar.

PARÂMETROS E EXECUÇÃO
 Binds utilizados: p_days, p_pattern.
 Editar os valores do bloco de configuração abaixo em cópia local. Nomes de
 objetos são literais de binds, respeitando o case do dicionário; não SQL livre.
 p_days, quando presente, limita a janela de coleta; deve ser positivo.
 p_top, quando presente, deve ser inteiro positivo. Limiares não negativos.
 Exemplo: SQL> @time_model_interval_deltas.sql
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
 _ash_scripts/ash_trend.sql
 Não é mudança cosmética nem afirmação de equivalência byte a byte/funcional
 integral. Fontes originais com avisos restritivos continuam retidas; avisos
 e créditos originais permanecem no acervo privado e não foram relicenciados.
 Algoritmo novo, chaves explícitas, unidades e diferenças descritas acima.

REFERÊNCIAS
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SNAPSHOT.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYS_TIME_MODEL.html
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
variable p_pattern varchar2(128)
begin
 :p_days:=7;
 :p_pattern:=NULL;
end;
/

WITH points AS (
 SELECT t.dbid,t.instance_number,t.con_id,t.stat_id,t.stat_name,n.startup_time,
 n.end_interval_time,n.snap_id,t.value,
 LAG(t.value) OVER(PARTITION BY t.dbid,t.instance_number,t.con_id,t.stat_id,n.startup_time ORDER BY n.snap_id) prior_value
 FROM dba_hist_sys_time_model t JOIN dba_hist_snapshot n
 ON n.dbid=t.dbid AND n.instance_number=t.instance_number AND n.snap_id=t.snap_id
 WHERE t.dbid=(SELECT dbid FROM v$database)
 AND t.con_id=TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
 AND n.end_interval_time >= SYSTIMESTAMP-NUMTODSINTERVAL(:p_days,'DAY')
 AND (:p_pattern IS NULL OR INSTR(t.stat_name,:p_pattern)>0)
)
SELECT instance_number,con_id,snap_id,end_interval_time,stat_name,
 (value-prior_value)/1000000 delta_seconds
FROM points WHERE value>=prior_value ORDER BY end_interval_time,instance_number,stat_name;
