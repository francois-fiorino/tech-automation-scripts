/*
===============================================================================
SCRIPT: os_stat_int_10g.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/os_stat_int_10g.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Comparar estatísticas de SO de snapshots AWR.

FUNCIONAMENTO DETALHADO
  Pareia OSSTAT por STAT_ID/DBID/instância; NUM_CPUS é valor final, demais usam delta; nomes com BYTES recebem taxa por duração válida.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_OSSTAT, DBA_HIST_SNAPSHOT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Snapshots crescentes com mesmo startup são obrigatórios; taxa pode ser NULL sem par válido. Outros gauges além de NUM_CPUS não devem ser tratados como contadores; unidades dependem da estatística/plataforma.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE pBgnSnap = 100
  DEFINE pEndSnap = 101
  DEFINE pDbId = 123456789
  DEFINE pInstNum = 1
  @os_stat_int_10g.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Nome, Total e Per Second para nomes com BYTES.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Terminador adicionado; lógica legada preservada e limitação de gauges registrada. 
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
select e.stat_name "Statistic Name"
     , decode(e.stat_name, 'NUM_CPUS', e.value, e.value - b.value) "Total"
     , decode( instrb(e.stat_name, 'BYTES'), 0, to_number(null)
             , round((e.value - b.value)/( select
       avg( extract( day from (e1.end_interval_time-b1.end_interval_time) )*24*60*60+
           extract( hour from (e1.end_interval_time-b1.end_interval_time) )*60*60+
           extract( minute from (e1.end_interval_time-b1.end_interval_time) )*60+
           extract( second from (e1.end_interval_time-b1.end_interval_time)) )     
      from dba_hist_snapshot  b1
          ,dba_hist_snapshot  e1
     where b1.snap_id         = b.snap_id
       and e1.snap_id         = e.snap_id
       and b1.dbid            = b.dbid
       and e1.dbid            = e.dbid
       and b1.instance_number = b.instance_number
       and e1.instance_number = e.instance_number
       and b1.startup_time    = e1.startup_time
       and b1.end_interval_time < e1.end_interval_time ),2)) "Per Second" 
 from  dba_hist_osstat  b
     , dba_hist_osstat  e
 where b.snap_id         = &pBgnSnap
   and e.snap_id         = &pEndSnap
   and b.dbid            = &pDbId
   and e.dbid            = &pDbId
   and b.instance_number = &pInstNum
   and e.instance_number = &pInstNum
   and b.stat_id         = e.stat_id
   and e.value          >= b.value
   and e.value          >  0
 order by 1 asc;
