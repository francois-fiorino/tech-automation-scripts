/*
===============================================================================
SCRIPT: latch_int_10g.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/latch_int_10g.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar solicitações, misses e sleeps de latches entre snapshots.

FUNCIONAMENTO DETALHADO
  Pareia LATCH_HASH/DBID/instância, subtrai contadores e usa DECODE para denominadores zero.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_LATCH

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Definir pBgnSnap, pEndSnap, pDbId e pInstNum com snapshots crescentes da mesma instância, DBID e STARTUP_TIME. Reinício ou baseline ausente pode invalidar deltas. Validar CON_ID e unicidade das linhas na versão; modelo histórico 10g. Somente latches com aumento de GETS aparecem; não mede mutexes genericamente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE pBgnSnap = 100
  DEFINE pEndSnap = 101
  DEFINE pDbId = 123456789
  DEFINE pInstNum = 1
  @latch_int_10g.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Gets, miss%, sleeps/miss, segundos de espera, pedidos no-wait e miss% no-wait.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Adicionado terminador SQL; proteções DECODE originais mantidas. 
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
select e.latch_name "Latch Name"
     , e.gets    - b.gets  "Get Requests"
     , to_number(decode(e.gets, b.gets, null,
       (e.misses - b.misses) * 100/(e.gets - b.gets)))   "Percent Get Misses"
     , to_number(decode(e.misses, b.misses, null,
       (e.sleeps - b.sleeps)/(e.misses - b.misses)))     "Avg Sleeps / Miss"
     , (e.wait_time - b.wait_time)/1000000 "Wait Time (s)"
     , e.immediate_gets - b.immediate_gets "No Wait Requests"
     , to_number(decode(e.immediate_gets,
			b.immediate_gets, null,
                     (e.immediate_misses - b.immediate_misses) * 100 /
	                (e.immediate_gets   - b.immediate_gets)))     "Percent No Wait Miss"
 from  dba_hist_latch  b
     , dba_hist_latch  e
 where b.snap_id         = &pBgnSnap
   and e.snap_id         = &pEndSnap
   and b.dbid            = &pDbId
   and e.dbid            = &pDbId
   and b.dbid            = e.dbid
   and b.instance_number = &pInstNum
   and e.instance_number = &pInstNum
   and b.instance_number = e.instance_number
   and b.latch_hash      = e.latch_hash
   and e.gets - b.gets   > 0
 order by 1, 4;
