/*
===============================================================================
SCRIPT: v$_display_avg_microseconds_waits.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _wait_event_scripts/V$_display_avg_microseconds_waits.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Medir espera média por evento entre snapshots adjacentes da instância 1.

FUNCIONAMENTO DETALHADO
  Subtrai TOTAL_WAITS e TIME_WAITED_MICRO de snapshots consecutivos; exibe apenas intervalos com mais de 50.000 esperas. WAITNAME é substituído pelo cliente.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_SYSTEM_EVENT, DBA_HIST_SNAPSHOT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Oracle 10g+ com AWR; restringe instância 1 e exige SNAP_ID consecutivo. Intervalos ausentes não são interpolados; igualdade de STARTUP_TIME elimina reinícios.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE WAITNAME = "db file sequential read"
  @v$_display_avg_microseconds_waits.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  C1: fim do intervalo; C2: novas esperas; C3: microssegundos por espera; nome do evento.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Adicionada vírgula ausente após C3; texto livre final convertido em comentários; vínculos por DBID/EVENT_ID e mesma inicialização impedem cruzamentos indevidos. 
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

-- display average wait microseconds script

col c1 heading "end Interval|time"
col c2 heading "number of|waits"
col c3 heading "average|microseconds"

select 
   sn.end_interval_time                       c1,
   (e.total_waits-b.total_waits)              c2,
   (e.time_waited_micro-b.time_waited_micro)/
      (e.total_waits-b.total_waits)           c3, 
   b.event_name "wait name"
from 
   dba_hist_system_event b, 
   dba_hist_system_event e,
   dba_hist_snapshot     sn
where 
   b.event_name='&WAITNAME' 
and
   e.event_name=b.event_name
and e.dbid=b.dbid
and e.event_id=b.event_id 
and
   e.snap_id=b.snap_id+1 
and
   e.instance_number=1 
and
   b.instance_number=e.instance_number 
and
   e.dbid=sn.dbid
and e.snap_id=sn.snap_id
and exists (select 1 from dba_hist_snapshot bs
            where bs.dbid=b.dbid and bs.instance_number=b.instance_number
              and bs.snap_id=b.snap_id and bs.startup_time=sn.startup_time) 
and
   e.instance_number=sn.instance_number 
and
   (e.total_waits-b.total_waits) > 50000
order by 
   e.snap_id;

-- You will be prompted
--  for one of these wait events:
-- 
-- WAITNAME 
-- class slave wait                     
-- control file parallel write        
-- control file sequential read   
-- db file parallel write               
-- db file scattered read            
-- db file sequential read          
-- direct path read temp            
-- direct path write temp           
-- latch free                               
-- latch: redo allocation             
-- log buffer space                    
-- log file parallel write              
-- log file switch completion      
-- log file sync                           
-- process startup                     
-- Queue Monitor Task Wait
