/*
SCRIPT: file_io_between_snapshots.sql
CATEGORIA: Oracle / storage / Implementação nova
DATA: 2026-11-03

OBJETIVO
 Comparar I/O de arquivos entre dois snapshots explícitos.

FUNCIONAMENTO E DIFERENÇAS FUNCIONAIS
 Exige dois snapshots informados, ordenados e do mesmo startup/arquivo. Arquivos criados/removidos entre endpoints são omitidos (somente pares); resets são excluídos, não tratados como zero. Percentual DATA+TEMP por instância/container.

PRÉ-REQUISITOS, DEPENDÊNCIAS E PRIVILÉGIOS
 SQL*Plus ou SQLcl; sessão no container alvo; SELECT autorizado nas views:
 dba_hist_filestatxs, dba_hist_snapshot, dba_hist_tempstatxs, v$database.
 Pacotes: conforme código; DBMS_OUTPUT escreve somente na saída do cliente.
 Verificar direito de uso do Diagnostics Pack/AWR/ASH antes de consultar.

PARÂMETROS E EXECUÇÃO
 Binds utilizados: p_end_snap, p_start_snap.
 Editar os valores do bloco de configuração abaixo em cópia local. Nomes de
 objetos são literais de binds, respeitando o case do dicionário; não SQL livre.
 p_days, quando presente, limita a janela de coleta; deve ser positivo.
 p_top, quando presente, deve ser inteiro positivo. Limiares não negativos.
 Exemplo: SQL> @file_io_between_snapshots.sql
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
 _disk_file_scripts/snapdeltafileio_awr.sql
 Não é mudança cosmética nem afirmação de equivalência byte a byte/funcional
 integral. Fontes originais com avisos restritivos continuam retidas; avisos
 e créditos originais permanecem no acervo privado e não foram relicenciados.
 Algoritmo novo, chaves explícitas, unidades e diferenças descritas acima.

REFERÊNCIAS
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_FILESTATXS.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SNAPSHOT.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_TEMPSTATXS.html
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
variable p_start_snap number
variable p_end_snap number
begin
 :p_end_snap:=NULL;
 :p_start_snap:=NULL;
end;
/

WITH file_points AS (
 SELECT 'DATA' file_kind,dbid,instance_number,con_id,snap_id,file#,creation_change#,filename,phyrds,phywrts,phyblkrd,phyblkwrt FROM dba_hist_filestatxs
 UNION ALL
 SELECT 'TEMP',dbid,instance_number,con_id,snap_id,file#,creation_change#,filename,phyrds,phywrts,phyblkrd,phyblkwrt FROM dba_hist_tempstatxs
), points AS (
 SELECT f.*,n.startup_time,n.end_interval_time
 FROM file_points f JOIN dba_hist_snapshot n
 ON n.dbid=f.dbid AND n.instance_number=f.instance_number AND n.snap_id=f.snap_id
 WHERE f.dbid=(SELECT dbid FROM v$database)
 AND f.con_id=TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
), paired AS (
 SELECT b.file_kind,b.instance_number,b.con_id,b.file#,b.filename,
 b.phyrds-a.phyrds read_delta,b.phywrts-a.phywrts write_delta,
 b.phyblkrd-a.phyblkrd block_read_delta,b.phyblkwrt-a.phyblkwrt block_write_delta
 FROM points a JOIN points b ON b.dbid=a.dbid AND b.instance_number=a.instance_number
 AND b.con_id=a.con_id AND b.file_kind=a.file_kind AND b.file#=a.file#
 AND b.creation_change#=a.creation_change# AND b.startup_time=a.startup_time
 WHERE a.snap_id=:p_start_snap AND b.snap_id=:p_end_snap AND b.snap_id>a.snap_id
 AND b.phyrds>=a.phyrds AND b.phywrts>=a.phywrts
 AND b.phyblkrd>=a.phyblkrd AND b.phyblkwrt>=a.phyblkwrt
)
SELECT p.*,
 ROUND(100*(read_delta+write_delta)/NULLIF(SUM(read_delta+write_delta) OVER(PARTITION BY instance_number,con_id),0),3) pct_io,
 block_read_delta/NULLIF(read_delta,0) blocks_per_read,
 block_write_delta/NULLIF(write_delta,0) blocks_per_write
FROM paired p ORDER BY instance_number,file_kind,file#;
