/*
SCRIPT: segment_assm_block_buckets.sql
CATEGORIA: Oracle / storage / Implementação nova
DATA: 2026-11-03

OBJETIVO
 Relatar classes de ocupação de blocos em segmentos ASSM.

FUNCIONAMENTO E DIFERENÇAS FUNCIONAIS
 Substitui função/consumidor históricos por bloco anônimo completo, sem DROP/CREATE TYPE/FUNCTION. Exige EXECUTE DBMS_SPACE e ANALYZE no objeto, SELECT nas views. FS1 a FS4 representam faixas de espaço livre (0–25,25–50,50–75,75–100%); não bytes recuperáveis. LOBs e MSSM excluídos explicitamente; erros por segmento aparecem na saída. Custo proporcional ao número de segmentos. Duas fontes mapeadas ao mesmo relatório.

PRÉ-REQUISITOS, DEPENDÊNCIAS E PRIVILÉGIOS
 SQL*Plus ou SQLcl; sessão no container alvo; SELECT autorizado nas views:
 dba_segments, dba_tablespaces.
 Pacotes: conforme código; DBMS_OUTPUT escreve somente na saída do cliente.
 Não depende de AWR/ASH nesta implementação.

PARÂMETROS E EXECUÇÃO
 Binds utilizados: p_owner.
 Editar os valores do bloco de configuração abaixo em cópia local. Nomes de
 objetos são literais de binds, respeitando o case do dicionário; não SQL livre.
 p_days, quando presente, limita a janela de coleta; deve ser positivo.
 p_top, quando presente, deve ser inteiro positivo. Limiares não negativos.
 Exemplo: SQL> @segment_assm_block_buckets.sql
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
 _awr_scripts/awr_large_scan_count.sql; _awr_scripts/awr_physrds.sql
 Não é mudança cosmética nem afirmação de equivalência byte a byte/funcional
 integral. Fontes originais com avisos restritivos continuam retidas; avisos
 e créditos originais permanecem no acervo privado e não foram relicenciados.
 Algoritmo novo, chaves explícitas, unidades e diferenças descritas acima.

REFERÊNCIAS
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_SEGMENTS.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_TABLESPACES.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_SPACE.html

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
variable p_owner varchar2(128)
begin
 :p_owner:=SYS_CONTEXT('USERENV','CURRENT_SCHEMA');
end;
/

DECLARE
 unformatted_blocks NUMBER;unformatted_bytes NUMBER;
 b1 NUMBER;y1 NUMBER;b2 NUMBER;y2 NUMBER;b3 NUMBER;y3 NUMBER;b4 NUMBER;y4 NUMBER;
 full_blocks NUMBER;full_bytes NUMBER;
BEGIN
 DBMS_OUTPUT.PUT_LINE('OWNER|SEGMENT|TYPE|PARTITION|UNFORMATTED|FS1|FS2|FS3|FS4|FULL|STATUS');
 FOR r IN (SELECT s.owner,s.segment_name,s.segment_type,s.partition_name
 FROM dba_segments s JOIN dba_tablespaces t ON t.tablespace_name=s.tablespace_name
 WHERE s.owner=:p_owner AND t.segment_space_management='AUTO'
 AND s.segment_type IN ('TABLE','TABLE PARTITION','TABLE SUBPARTITION','INDEX','INDEX PARTITION','INDEX SUBPARTITION')
 ORDER BY s.owner,s.segment_name,s.partition_name) LOOP
  BEGIN
   DBMS_SPACE.SPACE_USAGE(segment_owner=>r.owner,segment_name=>r.segment_name,
    segment_type=>r.segment_type,partition_name=>r.partition_name,
    unformatted_blocks=>unformatted_blocks,unformatted_bytes=>unformatted_bytes,
    fs1_blocks=>b1,fs1_bytes=>y1,fs2_blocks=>b2,fs2_bytes=>y2,
    fs3_blocks=>b3,fs3_bytes=>y3,fs4_blocks=>b4,fs4_bytes=>y4,
    full_blocks=>full_blocks,full_bytes=>full_bytes);
   DBMS_OUTPUT.PUT_LINE(r.owner||'|'||r.segment_name||'|'||r.segment_type||'|'||r.partition_name||'|'||
    unformatted_blocks||'|'||b1||'|'||b2||'|'||b3||'|'||b4||'|'||full_blocks||'|OK');
  EXCEPTION WHEN OTHERS THEN
   DBMS_OUTPUT.PUT_LINE(r.owner||'|'||r.segment_name||'|'||r.segment_type||'|'||r.partition_name||'|||||||ERROR '||SQLCODE||' '||SQLERRM);
  END;
 END LOOP;
END;
/
