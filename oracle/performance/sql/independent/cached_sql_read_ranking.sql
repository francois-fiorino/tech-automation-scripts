/*
SCRIPT: cached_sql_read_ranking.sql
CATEGORIA: Oracle / performance/sql / Implementação nova
DATA: 2026-11-03

OBJETIVO
 Classificar SQLs em cache por leituras por execução.

FUNCIONAMENTO E DIFERENÇAS FUNCIONAIS
 Consulta cache atual local, não AWR. Usa NULLIF e exclui execuções zero; leituras por execução calculadas sobre contadores da vida do cursor, sem afirmar janela temporal ou hit ratio de buffer cache.

PRÉ-REQUISITOS, DEPENDÊNCIAS E PRIVILÉGIOS
 SQL*Plus ou SQLcl; sessão no container alvo; SELECT autorizado nas views:
 all_users, v$sqlarea.
 Pacotes: conforme código; DBMS_OUTPUT escreve somente na saída do cliente.
 Não depende de AWR/ASH nesta implementação.

PARÂMETROS E EXECUÇÃO
 Binds utilizados: p_top.
 Editar os valores do bloco de configuração abaixo em cópia local. Nomes de
 objetos são literais de binds, respeitando o case do dicionário; não SQL livre.
 p_days, quando presente, limita a janela de coleta; deve ser positivo.
 p_top, quando presente, deve ser inteiro positivo. Limiares não negativos.
 Exemplo: SQL> @cached_sql_read_ranking.sql
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
 _awr_scripts/awr_high_cost_sql.sql
 Não é mudança cosmética nem afirmação de equivalência byte a byte/funcional
 integral. Fontes originais com avisos restritivos continuam retidas; avisos
 e créditos originais permanecem no acervo privado e não foram relicenciados.
 Algoritmo novo, chaves explícitas, unidades e diferenças descritas acima.

REFERÊNCIAS
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/ALL_USERS.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-SQLAREA.html

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
variable p_top number
begin
 :p_top:=20;
end;
/

SELECT * FROM (
 SELECT c.sql_id,u.username,c.executions,c.disk_reads,c.buffer_gets,
 ROUND(c.disk_reads/NULLIF(c.executions,0),3) reads_per_execution,
 c.cpu_time/1000000 cpu_seconds,c.elapsed_time/1000000 elapsed_seconds,
 c.parse_calls,c.sorts,c.rows_processed,c.sharable_mem,c.persistent_mem,c.runtime_mem,
 c.first_load_time,c.sql_text
 FROM v$sqlarea c LEFT JOIN all_users u ON u.user_id=c.parsing_user_id
 WHERE c.executions>0 AND c.parsing_schema_name NOT IN ('SYS','SYSTEM')
 ORDER BY reads_per_execution DESC,c.sql_id
) WHERE ROWNUM<=:p_top;
