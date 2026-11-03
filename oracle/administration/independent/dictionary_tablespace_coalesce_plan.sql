/*
SCRIPT: dictionary_tablespace_coalesce_plan.sql
CATEGORIA: Oracle / administration / Implementação nova
DATA: 2026-11-03

OBJETIVO
 Gerar plano de coalescência somente para tablespaces DMT.

FUNCIONAMENTO E DIFERENÇAS FUNCIONAIS
 Gera DDL documentado, sem eventos internos e sem executar saída. Contar extents livres não prova adjacência nem benefício de coalescer; DMT pode não existir em ambientes atuais. Não faz shrink/rebuild/defrag físico. Exige SELECT nas views e EXECUTE DBMS_ASSERT; aplicação futura exige ALTER TABLESPACE e autorização específica. Apenas planeja, não declara portabilidade do evento Oracle7.

PRÉ-REQUISITOS, DEPENDÊNCIAS E PRIVILÉGIOS
 SQL*Plus ou SQLcl; sessão no container alvo; SELECT autorizado nas views:
 dba_free_space, dba_tablespaces.
 Pacotes: conforme código; DBMS_OUTPUT escreve somente na saída do cliente.
 Não depende de AWR/ASH nesta implementação.

PARÂMETROS E EXECUÇÃO
 Binds utilizados: nenhum.
 Editar os valores do bloco de configuração abaixo em cópia local. Nomes de
 objetos são literais de binds, respeitando o case do dicionário; não SQL livre.
 p_days, quando presente, limita a janela de coleta; deve ser positivo.
 p_top, quando presente, deve ser inteiro positivo. Limiares não negativos.
 Exemplo: SQL> @dictionary_tablespace_coalesce_plan.sql
 Executar individualmente; não há instalador nem execução em lote do acervo.

RISCOS E IMPACTOS
 Gera plano administrativo; executar a saída é uma operação separada de alto risco.
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
 misc_scripts/DEFRAG7.SQL
 Não é mudança cosmética nem afirmação de equivalência byte a byte/funcional
 integral. Fontes originais com avisos restritivos continuam retidas; avisos
 e créditos originais permanecem no acervo privado e não foram relicenciados.
 Algoritmo novo, chaves explícitas, unidades e diferenças descritas acima.

REFERÊNCIAS
 https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/ALTER-TABLESPACE.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_ASSERT.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_FREE_SPACE.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_TABLESPACES.html

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

SELECT t.tablespace_name,COUNT(*) free_extents,SUM(f.bytes) free_bytes,
 'ALTER TABLESPACE '||DBMS_ASSERT.ENQUOTE_NAME(t.tablespace_name,FALSE)||' COALESCE;' proposed_ddl
FROM dba_tablespaces t JOIN dba_free_space f ON f.tablespace_name=t.tablespace_name
WHERE t.extent_management='DICTIONARY' AND t.contents='PERMANENT'
 AND t.status='ONLINE' AND t.tablespace_name NOT IN ('SYSTEM','SYSAUX')
GROUP BY t.tablespace_name HAVING COUNT(*)>1 ORDER BY t.tablespace_name;
