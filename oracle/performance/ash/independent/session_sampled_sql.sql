/*
SCRIPT: session_sampled_sql.sql
CATEGORIA: Oracle / performance/ash / Implementação nova
DATA: 2026-11-03

OBJETIVO
 Relacionar SQLs amostrados de uma sessão histórica.

FUNCIONAMENTO E DIFERENÇAS FUNCIONAIS
 Mantém SERIAL#, instância e container; evita multiplicação por child cursors de V$SQL. Filtro de texto é substring literal opcional, não LIKE; trecho limitado a 1000 caracteres. O SID pode ter sido reutilizado, por isso os SERIAL# aparecem separados.

PRÉ-REQUISITOS, DEPENDÊNCIAS E PRIVILÉGIOS
 SQL*Plus ou SQLcl; sessão no container alvo; SELECT autorizado nas views:
 dba_hist_active_sess_history, dba_hist_sqltext, v$database.
 Pacotes: conforme código; DBMS_OUTPUT escreve somente na saída do cliente.
 Verificar direito de uso do Diagnostics Pack/AWR/ASH antes de consultar.

PARÂMETROS E EXECUÇÃO
 Binds utilizados: p_days, p_pattern, p_sid.
 Editar os valores do bloco de configuração abaixo em cópia local. Nomes de
 objetos são literais de binds, respeitando o case do dicionário; não SQL livre.
 p_days, quando presente, limita a janela de coleta; deve ser positivo.
 p_top, quando presente, deve ser inteiro positivo. Limiares não negativos.
 Exemplo: SQL> @session_sampled_sql.sql
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
 _ash_scripts/ash_sql.sql
 Não é mudança cosmética nem afirmação de equivalência byte a byte/funcional
 integral. Fontes originais com avisos restritivos continuam retidas; avisos
 e créditos originais permanecem no acervo privado e não foram relicenciados.
 Algoritmo novo, chaves explícitas, unidades e diferenças descritas acima.

REFERÊNCIAS
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_ACTIVE_SESS_HISTORY.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SQLTEXT.html
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
variable p_sid number
variable p_pattern varchar2(128)
begin
 :p_days:=7;
 :p_pattern:=NULL;
 :p_sid:=74;
end;
/

WITH observed AS (
 SELECT dbid,instance_number,con_id,session_id,session_serial#,sql_id,
        MIN(sample_time) first_sample,MAX(sample_time) last_sample,COUNT(*) samples
 FROM dba_hist_active_sess_history
 WHERE dbid=(SELECT dbid FROM v$database) AND session_id=:p_sid
   AND con_id=TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
   AND sample_time >= SYSTIMESTAMP-NUMTODSINTERVAL(:p_days,'DAY')
 GROUP BY dbid,instance_number,con_id,session_id,session_serial#,sql_id
)
SELECT x.*,DBMS_LOB.SUBSTR(t.sql_text,1000,1) sql_excerpt
FROM observed x LEFT JOIN dba_hist_sqltext t
 ON t.dbid=x.dbid AND t.sql_id=x.sql_id AND t.con_id=x.con_id
WHERE :p_pattern IS NULL OR DBMS_LOB.INSTR(t.sql_text,:p_pattern)>0
ORDER BY x.first_sample,x.instance_number,x.session_serial#;
