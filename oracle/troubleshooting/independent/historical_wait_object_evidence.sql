/*
SCRIPT: historical_wait_object_evidence.sql
CATEGORIA: Oracle / troubleshooting / Implementação nova
DATA: 2026-11-03

OBJETIVO
 Relatar evidência ASH de objetos/arquivos associados a esperas históricas.

FUNCIONAMENTO E DIFERENÇAS FUNCIONAIS
 Duas fontes equivalentes apontam ao mesmo novo relatório. Remove junção sem relação causal de WAITSTAT com ASH; número de arquivo é evidência da amostra, não atribuição de todo WAITSTAT ao objeto. Sem duração exata: conta amostras. Objetos removidos/recriados podem não resolver; CURRENT_OBJ# pode ser desconhecido.

PRÉ-REQUISITOS, DEPENDÊNCIAS E PRIVILÉGIOS
 SQL*Plus ou SQLcl; sessão no container alvo; SELECT autorizado nas views:
 dba_hist_active_sess_history, dba_objects, v$database.
 Pacotes: conforme código; DBMS_OUTPUT escreve somente na saída do cliente.
 Verificar direito de uso do Diagnostics Pack/AWR/ASH antes de consultar.

PARÂMETROS E EXECUÇÃO
 Binds utilizados: p_days, p_threshold.
 Editar os valores do bloco de configuração abaixo em cópia local. Nomes de
 objetos são literais de binds, respeitando o case do dicionário; não SQL livre.
 p_days, quando presente, limita a janela de coleta; deve ser positivo.
 p_top, quando presente, deve ser inteiro positivo. Limiares não negativos.
 Exemplo: SQL> @historical_wait_object_evidence.sql
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
 _wait_event_scripts/wait_time_detail.sql; _wait_event_scripts/wait_time_detail_10g.sql
 Não é mudança cosmética nem afirmação de equivalência byte a byte/funcional
 integral. Fontes originais com avisos restritivos continuam retidas; avisos
 e créditos originais permanecem no acervo privado e não foram relicenciados.
 Algoritmo novo, chaves explícitas, unidades e diferenças descritas acima.

REFERÊNCIAS
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_ACTIVE_SESS_HISTORY.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_OBJECTS.html
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
variable p_threshold number
begin
 :p_days:=7;
 :p_threshold:=0;
end;
/

WITH evidence AS (
 SELECT instance_number,con_id,TRUNC(CAST(sample_time AS DATE),'HH24') sample_hour,
 current_obj#,current_file#,event,COUNT(*) sampled_waits
 FROM dba_hist_active_sess_history
 WHERE dbid=(SELECT dbid FROM v$database)
 AND con_id=TO_NUMBER(SYS_CONTEXT('USERENV','CON_ID'))
 AND sample_time>=SYSTIMESTAMP-NUMTODSINTERVAL(:p_days,'DAY')
 AND session_state='WAITING' AND wait_class<>'Idle'
 GROUP BY instance_number,con_id,TRUNC(CAST(sample_time AS DATE),'HH24'),current_obj#,current_file#,event
)
SELECT e.instance_number,e.con_id,e.sample_hour,e.current_obj#,e.current_file#,
 o.owner,o.object_name,o.subobject_name,o.object_type,e.event,e.sampled_waits
FROM evidence e LEFT JOIN dba_objects o ON o.object_id=e.current_obj#
WHERE e.sampled_waits>:p_threshold
ORDER BY e.sample_hour,e.instance_number,e.sampled_waits DESC;
