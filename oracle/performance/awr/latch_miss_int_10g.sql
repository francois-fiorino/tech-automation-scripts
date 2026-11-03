/*
===============================================================================
SCRIPT: latch_miss_int_10g.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/latch_miss_int_10g.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Comparar misses/sleeps de latch por localização interna entre snapshots.

FUNCIONAMENTO DETALHADO
  Outer join de DBA_HIST_LATCH_MISSES_SUMMARY por DBID/instância/parent_name/where_in_code; filtra crescimento de sleeps e subtrai contadores.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_LATCH_MISSES_SUMMARY

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Requer mesma inicialização para deltas válidos. Baseline ausente usa zero. Localizações internas e nomes são sensíveis à versão; não mede duração de espera.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE pBgnSnap = 100
  DEFINE pEndSnap = 101
  DEFINE pDbId = 123456789
  DEFINE pInstNum = 1
  @latch_miss_int_10g.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Latch Name, No Wait Misses, Sleeps e Waiter Sleeps.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Terminador SQL ausente adicionado. 
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
select   latchname "Latch Name",
         nwmisses "No Wait Misses",
         sleeps "Sleeps",
    		 waiter_sleeps "Waiter Sleeps"
From (
select e.parent_name||' '||e.where_in_code  latchname
     , e.nwfail_count - nvl(b.nwfail_count,0) nwmisses
     , e.sleep_count  - nvl(b.sleep_count,0)  sleeps
     , e.wtr_slp_count - nvl(b.wtr_slp_count,0)   waiter_sleeps	
  from dba_hist_latch_misses_summary  b
     , dba_hist_latch_misses_summary  e
 where b.snap_id(+)         = &pBgnSnap
   and e.snap_id            = &pEndSnap
   and b.dbid(+)            = &pDbId
   and e.dbid               = &pDbId
   and b.dbid(+)            = e.dbid
   and b.instance_number(+) = &pInstNum
   and e.instance_number    = &pInstNum
   and b.instance_number(+) = e.instance_number
   and b.parent_name(+)     = e.parent_name
   and b.where_in_code(+)   = e.where_in_code
   and e.sleep_count        > nvl(b.sleep_count,0)
)
 order by 1, 3 desc;
