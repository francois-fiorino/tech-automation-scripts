/*
SCRIPT: datapump_tablespace_parameters.sql
CATEGORIA: Oracle / backup-recovery / Implementação nova
DATA: 2026-11-03

OBJETIVO
 Gerar parâmetros de exportação Data Pump por tablespace permanente.

FUNCIONAMENTO E DIFERENÇAS FUNCIONAIS
 Nova implementação usa modo TABLESPACES do Data Pump em vez de exp legado, staging e Shell com senha. Apenas gera texto por DBMS_OUTPUT: não cria DIRECTORY, não exporta, não escreve dump nem altera banco. Exige SELECT DBA_TABLESPACES; a execução futura de expdp exige READ/WRITE no DIRECTORY, espaço, autenticação externa/wallet aprovada e DATAPUMP_EXP_FULL_DATABASE quando aplicável. Configurar DIRECTORY e nomes únicos, revisar dependências/partições e consistência FLASHBACK_SCN/TIME para o caso concreto; não é backup físico ou garantia de exportação completa de schemas. Após salvar um único bloco em arquivo privado: expdp /@ALIAS_SEGURO parfile=arquivo.par (somente se autenticação externa/wallet foi configurada). Não há credencial no código. Permanece em revisão administrativa.

PRÉ-REQUISITOS, DEPENDÊNCIAS E PRIVILÉGIOS
 SQL*Plus ou SQLcl; sessão no container alvo; SELECT autorizado nas views:
 dba_tablespaces.
 Pacotes: conforme código; DBMS_OUTPUT escreve somente na saída do cliente.
 Não depende de AWR/ASH nesta implementação.

PARÂMETROS E EXECUÇÃO
 Binds utilizados: nenhum.
 Editar os valores do bloco de configuração abaixo em cópia local. Nomes de
 objetos são literais de binds, respeitando o case do dicionário; não SQL livre.
 p_days, quando presente, limita a janela de coleta; deve ser positivo.
 p_top, quando presente, deve ser inteiro positivo. Limiares não negativos.
 Exemplo: SQL> @datapump_tablespace_parameters.sql
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
 _tablespace_scripts/TBSP_EXP.SQL
 Não é mudança cosmética nem afirmação de equivalência byte a byte/funcional
 integral. Fontes originais com avisos restritivos continuam retidas; avisos
 e créditos originais permanecem no acervo privado e não foram relicenciados.
 Algoritmo novo, chaves explícitas, unidades e diferenças descritas acima.

REFERÊNCIAS
 https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/oracle-data-pump-export-utility.html
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

BEGIN
 FOR t IN (SELECT tablespace_name FROM dba_tablespaces
 WHERE contents='PERMANENT' AND tablespace_name NOT IN ('SYSTEM','SYSAUX')
 ORDER BY tablespace_name) LOOP
  IF NOT REGEXP_LIKE(t.tablespace_name,'^[A-Z][A-Z0-9_$#]{0,29}$','c') THEN
   DBMS_OUTPUT.PUT_LINE('# OMITIDO: nome exige revisão de quoting: '||t.tablespace_name);
  ELSE
   DBMS_OUTPUT.PUT_LINE('# Copiar as linhas seguintes para um parfile separado: '||t.tablespace_name);
   DBMS_OUTPUT.PUT_LINE('DIRECTORY=REVISAR_DIRECTORY');
   DBMS_OUTPUT.PUT_LINE('DUMPFILE=export_'||t.tablespace_name||'_%U.dmp');
   DBMS_OUTPUT.PUT_LINE('LOGFILE=export_'||t.tablespace_name||'.log');
   DBMS_OUTPUT.PUT_LINE('TABLESPACES='||t.tablespace_name);
   DBMS_OUTPUT.PUT_LINE('# fim do parfile; nao concatenar tablespaces diferentes neste arquivo');
  END IF;
 END LOOP;
END;
/
