/*
SCRIPT: buffer_cache_growth_advice.sql
CATEGORIA: Oracle / memory / Implementação nova
DATA: 2026-11-03

OBJETIVO
 Consultar estimativas do advisory para expansão do buffer cache.

FUNCIONAMENTO E DIFERENÇAS FUNCIONAIS
 Substitui estruturas X$ e parâmetros obsoletos por advisory documentado. Não altera SGA/cache nem ativa advisory. Estima leituras físicas, não reproduz a métrica histórica de hits perdidos/ganhos; ausência de linhas pode significar advisory inativo ou sem dados. Validar representatividade do workload.

PRÉ-REQUISITOS, DEPENDÊNCIAS E PRIVILÉGIOS
 SQL*Plus ou SQLcl; sessão no container alvo; SELECT autorizado nas views:
 v$db_cache_advice.
 Pacotes: conforme código; DBMS_OUTPUT escreve somente na saída do cliente.
 Não depende de AWR/ASH nesta implementação.

PARÂMETROS E EXECUÇÃO
 Binds utilizados: nenhum.
 Editar os valores do bloco de configuração abaixo em cópia local. Nomes de
 objetos são literais de binds, respeitando o case do dicionário; não SQL livre.
 p_days, quando presente, limita a janela de coleta; deve ser positivo.
 p_top, quando presente, deve ser inteiro positivo. Limiares não negativos.
 Exemplo: SQL> @buffer_cache_growth_advice.sql
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
 _sga_internals_scripts/SGA_INC.SQL
 Não é mudança cosmética nem afirmação de equivalência byte a byte/funcional
 integral. Fontes originais com avisos restritivos continuam retidas; avisos
 e créditos originais permanecem no acervo privado e não foram relicenciados.
 Algoritmo novo, chaves explícitas, unidades e diferenças descritas acima.

REFERÊNCIAS
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-DB_CACHE_ADVICE.html

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

SELECT con_id,name,block_size,advice_status,size_for_estimate,size_factor,
 buffers_for_estimate,estd_physical_reads,estd_physical_read_factor,estd_physical_read_time
FROM v$db_cache_advice
WHERE con_id IN (0,TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID')))
 AND size_factor>1 AND advice_status='ON'
ORDER BY name,block_size,size_factor;
