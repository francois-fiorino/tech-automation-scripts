/*
===============================================================================
SCRIPT: high_sql_buf_gets.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/high_sql_buf_gets.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Classificar SQL por delta de leituras lógicas entre snapshots.

FUNCIONAMENTO DETALHADO
  Outer join SQLSTAT por SQL_ID/plano/DBID/instância, liga texto por SQL_ID/DBID e compara gets com delta de session logical reads.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_SQLSTAT, DBA_HIST_SQLTEXT, DBA_HIST_SYSSTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Snapshots devem ser crescentes e do mesmo STARTUP_TIME; baseline ausente assume zero. AWR não captura todos os SQL; percentual pode não fechar 100. Validar chaves CON_ID/CON_DBID em multitenant.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE pBgnSnap = 100
  DEFINE pEndSnap = 101
  DEFINE pDBId = 123456789
  DEFINE pInstNum = 1
  @high_sql_buf_gets.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  SQL_ID, gets, execuções, gets/exec, participação nos logical reads, CPU/elapsed em segundos, módulo e texto.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  @pBgnSnap corrigido para &; PLAN_HASH_VALUE no pareamento; texto associado ao fim por DBID; denominador usa parâmetros para baseline mesmo sem SQL anterior e NULLIF; terminador adicionado. 
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

/*  */
 select
                sql_id
              , buffer_gets_total "Buffer Gets"
              , executions_total "Executions"
              , buffer_gets_total/executions_total "Gets / Exec"
              , pct*100 "% Total"
              , cpu_time_total/1000000 "CPU Time (s)"
              , elapsed_time_total/1000000 "Elapsed Time (s)"
              , module "SQL Module"
              , stmt  "SQL Statement"
from
(select
                e.sql_id sql_id
              , e.buffer_gets_total - nvl(b.buffer_gets_total,0) buffer_gets_total
              , e.executions_total - nvl(b.executions_total,0) executions_total
              , (e.buffer_gets_total - nvl(b.buffer_gets_total,0))/
                nullif((  select e1.value - nvl(b1.value,0)
                   from dba_hist_sysstat b1 , dba_hist_sysstat e1
                        where b1.snap_id(+)          = &pBgnSnap
                          and e1.snap_id             = e.snap_id
                          and b1.dbid(+)             = e.dbid
                          and e1.dbid                = e.dbid
                          and b1.instance_number(+)  = e.instance_number
                          and e1.instance_number     = e.instance_number
                          and b1.stat_id             = e1.stat_id
                          and e1.stat_name           = 'session logical reads'

),0) pct
              , e.elapsed_time_total - nvl(b.elapsed_time_total,0) elapsed_time_total
              , e.cpu_time_total - nvl(b.cpu_time_total,0) cpu_time_total
              , e.module
              , t.sql_text  stmt
       from dba_hist_sqlstat  e
          , dba_hist_sqlstat  b
          , dba_hist_sqltext  t
      where b.snap_id(+)         = &pBgnSnap
        and b.dbid(+)            = e.dbid
        and b.instance_number(+) = e.instance_number
        and b.sql_id(+)          = e.sql_id
        and b.plan_hash_value(+) = e.plan_hash_value
        and e.snap_id            = &pEndSnap
        and e.dbid               = &pDBId
        and e.instance_number    = &pInstNum
        and (e.executions_total - nvl(b.executions_total,0)) > 0
        and t.sql_id             = e.sql_id
        and t.dbid = e.dbid
)
     order by 2 desc;
