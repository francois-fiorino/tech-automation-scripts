/*
===============================================================================
SCRIPT: sys_time_model_int_10g.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _ash_scripts/sys_time_model_int_10g.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Comparar contadores do time model e sua razão frente ao DB time entre snapshots.

FUNCIONAMENTO DETALHADO
  Subtrai VALUE inicial/final por STAT_ID; converte microssegundos a segundos e divide pelo delta de DB time.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_SYS_TIME_MODEL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Escolher mesma inicialização/DBID/instância. Estatísticas se sobrepõem e componentes background não são partes aditivas do DB time; percentuais podem superar 100.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE pBgnSnap = 100
  DEFINE pEndSnap = 101
  DEFINE pDbId = 123456789
  DEFINE pInst_Num = 1
  @sys_time_model_int_10g.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Statistic Name, Time (s), Percent of Total DB Time.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Denominador DB time protegido por NULLIF; fallback -1 para valor desconhecido removido para preservar NULL. 
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
column "Statistic Name" format A40
column "Time (s)" format 999,999
column "Percent of Total DB Time" format 999,999

select e.stat_name "Statistic Name"
     , (e.value - b.value)/1000000        "Time (s)"
     , decode( e.stat_name,'DB time'
             , to_number(null)
             , 100*(e.value - b.value)
             )/
     nullif(( select (e1.value - b1.value)
     from dba_hist_sys_time_model  e1
        , dba_hist_sys_time_model  b1
     where b1.snap_id              = b.snap_id
     and e1.snap_id                = e.snap_id
     and b1.dbid                   = b.dbid
     and e1.dbid                   = e.dbid
     and b1.instance_number        = b.instance_number
     and e1.instance_number        = e.instance_number
     and b1.stat_name             = 'DB time'
     and b1.stat_id                = e1.stat_id
),0)        
     "Percent of Total DB Time"
  from dba_hist_sys_time_model e
     , dba_hist_sys_time_model b
 where b.snap_id                = &pBgnSnap
   and e.snap_id                = &pEndSnap
   and b.dbid                   = &pDbId
   and e.dbid                   = &pDbId
   and b.instance_number        = &pInst_Num
   and e.instance_number        = &pInst_Num
   and b.stat_id                = e.stat_id
   and e.value - b.value > 0
 order by 2 desc;
