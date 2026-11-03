/*
===============================================================================
SCRIPT: dba_hist_seg_stat_usage.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _segment_scripts/dba_hist_seg_stat_usage.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relacionar deltas históricos de espaço a segmentos atuais de um proprietário.

FUNCIONAMENTO DETALHADO
  Soma SPACE_USED_DELTA após DAYS_BACK, une snapshots por DBID/instância e associa OBJ#/DATAOBJ# aos objetos e partições atuais. Restringe ao DBID atual.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_SNAPSHOT, DBA_HIST_SEG_STAT, DBA_OBJECTS, DBA_SEGMENTS, V$DATABASE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  AWR só captura segmentos elegíveis/top; não é inventário completo de crescimento. Objetos removidos/movidos podem faltar e DBID de PDB/AWR multitenant precisa de revisão. Deltas podem ser negativos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE days_back = 7
  DEFINE owner = HR
  @dba_hist_seg_stat_usage.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tablespace, segmento, tipo e Growth (MB) em MiB.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Nome solto inicial comentado, aspas/travessão tipográficos corrigidos; junções incluem DBID/instância/DATAOBJ# e partição, evitando multiplicação. Owner XXXX parametrizado. 
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

-- dba_hist_seg_stat_usage.sql

-- ****************************************************
-- This tablespace growth report requires AWR license
-- ****************************************************

set feedback on
select * from (select c.tablespace_name,c.segment_name "object name",b.object_type,
sum(space_used_delta) / 1024 / 1024 "Growth (MB)"
from 
   dba_hist_snapshot sn,
   dba_hist_seg_stat a,
   dba_objects b,
   dba_segments c
where 
   begin_interval_time > trunc(sysdate) - &days_back
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
and nvl(b.subobject_name,'~')=nvl(c.partition_name,'~')
and 
   c.owner ='&&owner'
group by 
   c.tablespace_name,
   c.segment_name,
   b.object_type)
order by 3 asc;

 
