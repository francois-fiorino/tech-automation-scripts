/*
===============================================================================
SCRIPT: segment_tablespace_growth_report.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _tablespace_scripts/segment_tablespace_growth_report.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relacionar deltas diários amostrados de uso de segmento com seu tamanho alocado atual.

FUNCIONAMENTO DETALHADO
  Dois exemplos para nomes S_PARTY/s_party unem snapshots, SEG_STAT, OBJECTS e SEGMENTS, agrupando por owner/partição/tipo e dia.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_SNAPSHOT, DBA_HIST_SEG_STAT, DBA_OBJECTS, DBA_SEGMENTS, V$DATABASE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  AWR coleta segmentos selecionados, não todos. Objetos removidos/recriados podem faltar e tamanho atual não é tamanho histórico. Multitenant exige validação de CON_ID/CON_DBID; operar em escopo com IDs inequívocos. Delta pode ser negativo. Dois exemplos preservam case-sensitive names.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @segment_tablespace_growth_report.sql
  -- Revisar nomes de segmento nos dois exemplos.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Deltas MiB no dia, tamanho alocado atual MiB e porcentagem delta/tamanho atual por segmento.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Linha de filename comentada; Unicode SQL normalizado; joins DBID/instância/DATAOBJ#/partição/tipo completos; denominador AVG de bytes atuais substitui SUM repetido por snapshot e NULLIF evita zero. Fonte: docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SEG_STAT.html. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

AVISO DE RESPONSABILIDADE
Os scripts são disponibilizados para fins técnicos, educacionais e administrativos.
Antes da utilização, analise integralmente o código, compreenda seu funcionamento
e realize testes em ambiente controlado, preferencialmente desenvolvimento ou
homologação. Conteúdo fornecido no estado em que se encontra (AS IS), sem garantias
de funcionamento, compatibilidade, desempenho ou adequação a ambientes específicos.
A utilização ocorre por conta e risco de quem executa. Os mantenedores não assumem
responsabilidade por danos, perdas de dados, indisponibilidade ou outros impactos
decorrentes do uso, nos limites permitidos pela legislação aplicável.
===============================================================================
*/



-- segment_tablespace_growth_report.sql

-- ****************************************************
-- This tablespace growth report requires AWR license
-- ****************************************************

column "Percent of Total Disk Usage" justify right format 999.99
column "Space Used (MB)" justify right format 9,999,999.99
column "Total Object Size (MB)" justify right format 9,999,999.99

set linesize 150
set pages 80
set feedback off
set line 5000
column "SEGMENT_NAME" justify left format A30
column "TABLESPACE_NAME" justify left format A30

select * from (select c.owner,c.partition_name,c.segment_type,c.tablespace_name,c.segment_name,to_char(end_interval_time, 'MM/DD/YY') mydate, sum(space_used_delta) / 1024 / 1024 "Space used (MB)", avg(c.bytes) / 1024 / 1024 "Total Object Size (MB)",
round(sum(space_used_delta) / nullif(avg(c.bytes),0) * 100, 2) "Percent of Total Disk Usage"
from
   dba_hist_snapshot sn,
   dba_hist_seg_stat a,
   dba_objects b,
   dba_segments c
where 
   begin_interval_time > trunc(sysdate) - 10
and 
   sn.snap_id = a.snap_id
and sn.dbid=a.dbid and sn.instance_number=a.instance_number
and a.dbid=(select dbid from v$database)
and 
   b.object_id = a.obj# and b.data_object_id=a.dataobj#
and 
   b.owner = c.owner
and 
   b.object_name = c.segment_name
and nvl(b.subobject_name,'-')=nvl(c.partition_name,'-')
and b.object_type=c.segment_type
and 
   c.segment_name = 'S_PARTY'
group by 
   c.owner,c.partition_name,c.segment_type,c.tablespace_name,
   c.segment_name,
   to_char(end_interval_time, 'MM/DD/YY')
order by 
   c.tablespace_name,
   c.segment_name,
   to_date(to_char(end_interval_time,'MM/DD/YY'),'MM/DD/YY'));

 


--------------------------------------------------------------------------------

-- ****************************************************
-- This tablespace growth report requires AWR license
-- ****************************************************

column "percent of total disk usage" justify right format 999.99
column "space used (mb)" justify right format 9,999,999.99
column "total object size (mb)" justify right format 9,999,999.99
column "segment_name" justify left format a30
column "tablespace_name" justify left format a30

set linesize 150
set pages 80
set feedback off
set line 5000

select * from (select c.owner,c.partition_name,c.segment_type,c.tablespace_name,c.segment_name,to_char(end_interval_time, 'mm/dd/yy') mydate, sum(space_used_delta) / 1024 / 1024 "space used (mb)", avg(c.bytes) / 1024 / 1024 "total object size (mb)",
round(sum(space_used_delta) / nullif(avg(c.bytes),0) * 100, 2) "percent of total disk usage"
from
   dba_hist_snapshot sn,
   dba_hist_seg_stat a,
   dba_objects b,
   dba_segments c
where 
   begin_interval_time > trunc(sysdate) - 10
and 
   sn.snap_id = a.snap_id
and sn.dbid=a.dbid and sn.instance_number=a.instance_number
and a.dbid=(select dbid from v$database)
and 
   b.object_id = a.obj# and b.data_object_id=a.dataobj#
and 
   b.owner = c.owner
and 
   b.object_name = c.segment_name
and nvl(b.subobject_name,'-')=nvl(c.partition_name,'-')
and b.object_type=c.segment_type
and 
   c.segment_name = 's_party'
group by 
   c.owner,c.partition_name,c.segment_type,c.tablespace_name,
   c.segment_name,
   to_char(end_interval_time, 'mm/dd/yy')
order by 
   c.tablespace_name,
   c.segment_name,
   to_date(to_char(end_interval_time,'mm/dd/yy'),'mm/dd/yy'));

