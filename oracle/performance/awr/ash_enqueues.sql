/*
===============================================================================
SCRIPT: ash_enqueues.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _ash_scripts/ash_enqueues.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar contadores históricos de enqueues com tempo de espera positivo.

FUNCIONAMENTO DETALHADO
  Relaciona estatísticas de enqueue e snapshots por DBID, SNAP_ID e INSTANCE_NUMBER; ordena início/tempo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_ENQUEUE_STAT, DBA_HIST_SNAPSHOT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Contadores de snapshot são acumulados, não deltas. Requer colunas históricas disponíveis na versão. O nome ash não significa que a consulta usa amostras ASH.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @ash_enqueues.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Intervalo, tipo/motivo, requisições, sucesso/falha e CUM_WAIT_TIME.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NATURAL JOIN substituído por chaves explícitas, evitando dependência de colunas comuns futuras. 
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



column begin_interval_time format a10
column req_reason          format a25
column cum_wait_time       head CUM|WAIT|TIME
column total_req#          head TOTAL|REQ#
column total_wait#         head TOTAL|WAIT#
column failed_req#         head FAILED|REQ#

select
   begin_interval_time,
   eq_type,
   req_reason,
   total_req#,
   total_wait#,
   succ_req#,
   failed_req#,
   cum_wait_time
from
   dba_hist_enqueue_stat e
 join dba_hist_snapshot sn on sn.dbid=e.dbid
 and sn.snap_id=e.snap_id and sn.instance_number=e.instance_number
where
   cum_wait_time > 0
order by
    begin_interval_time,
    cum_wait_time
;
