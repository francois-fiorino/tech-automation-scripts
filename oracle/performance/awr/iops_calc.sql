/*
===============================================================================
SCRIPT: iops_calc.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _i_o_scripts/iops_calc.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Somar deltas históricos de leituras/escritas físicas por hora da instância corrente.

FUNCIONAMENTO DETALHADO
  Mantém quatro aliases de SYSSTAT e três de SNAPSHOT; encontra snapshot anterior, subtrai contadores e usa valor novo após reinício. Agrupa pela hora final.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_SYSSTAT, DBA_HIST_SNAPSHOT, DBMS_UTILITY.CURRENT_INSTANCE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não divide por duração e physical reads/writes não são necessariamente requisições de storage. Lacunas e reinícios exigem análise. Hora agrupa snapshots de durações distintas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @iops_calc.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  THE_DATE, READS, WRITES e TOTAL por hora; contadores de estatísticas físicas, não IOPS.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Texto introdutório convertido em comentário; DBID adicionado a todas as relações/correlações de snapshots para impedir cruzamento de bancos. Estrutura original mantida. 
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

-- This script will calculate Oracle I/O throughput in I/O per second (IOPS):

select
   to_char(sn.end_interval_time,'yyyymmddhh24') the_date,
   sum(decode(sn2.startup_time,sn3.startup_time,(newreads.value-oldreads.value),newreads.value)) reads,
   sum(decode(sn2.startup_time,sn3.startup_time,(newwrites.value-oldwrites.value),newwrites.value)) writes,
   (sum(decode(sn2.startup_time,sn3.startup_time,(newreads.value-oldreads.value),newreads.value)))+
   (sum(decode(sn2.startup_time,sn3.startup_time,(newwrites.value-oldwrites.value),newwrites.value)))
total
from
   dba_hist_sysstat  oldreads,
   dba_hist_sysstat  newreads,
   dba_hist_sysstat  oldwrites,
   dba_hist_sysstat  newwrites,
   dba_hist_snapshot sn,
   dba_hist_snapshot sn2,
   dba_hist_snapshot sn3
where 
   sn.instance_number=dbms_utility.current_instance
and sn.dbid=newreads.dbid and newreads.dbid=newwrites.dbid
and oldreads.dbid=newreads.dbid and oldwrites.dbid=newwrites.dbid
and sn2.dbid=oldreads.dbid and sn3.dbid=newreads.dbid
and 
   sn.instance_number=sn2.instance_number
and 
   sn2.instance_number=sn3.instance_number
and 
   oldreads.instance_number=sn3.instance_number
and 
   newreads.instance_number=oldreads.instance_number
and 
   oldreads.instance_number=oldwrites.instance_number
and 
   oldwrites.instance_number=newwrites.instance_number
and 
   newreads.snap_id=sn.snap_id
and 
   newwrites.snap_id=newreads.snap_id
and 
   sn.instance_number=oldreads.instance_number
and 
   oldreads.instance_number=newreads.instance_number
and 
   sn.instance_number=oldwrites.instance_number
and 
   oldwrites.instance_number=newwrites.instance_number
and 
   oldreads.snap_id = 
   (select 
      max(sn.snap_id) 
    from 
      dba_hist_snapshot sn
    where 
      sn.snap_id<newreads.snap_id and sn.dbid=newreads.dbid 
    and
      sn.instance_number=newreads.instance_number 
    and
      newreads.instance_number=oldreads.instance_number)
    and 
     oldreads.snap_id=sn2.snap_id
    and 
     newreads.snap_id=sn3.snap_id
    and 
     oldwrites.snap_id = (
       select 
         max(sn.snap_id) 
       from 
         dba_hist_snapshot sn
       where 
         sn.snap_id<newwrites.snap_id and sn.dbid=newwrites.dbid 
       and
         sn.instance_number=newwrites.instance_number 
       and
         newwrites.instance_number=oldwrites.instance_number)
    and 
      oldreads.stat_name = 'physical reads'
   and 
      newreads.stat_name = 'physical reads'
   and 
      oldwrites.stat_name = 'physical writes'
   and 
      newwrites.stat_name = 'physical writes'
group by 
      to_char(sn.end_interval_time,'yyyymmddhh24')
order by 
      to_char(sn.end_interval_time,'yyyymmddhh24')
;
