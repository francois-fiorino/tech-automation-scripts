/*
===============================================================================
SCRIPT: gc_blocks_lost_events.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/gc_blocks_lost.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar eventos de blocos gc perdidos e contador correspondente por instância.

FUNCIONAMENTO DETALHADO
  Primeiro SELECT filtra dois eventos lost em GV$SYSTEM_EVENT; segundo une STATNAME/SYSSTAT e filtra gc blocks lost.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$SYSTEM_EVENT, GV$STATNAME, GV$SYSSTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não é o script homônimo de razão global-cache já publicado. Contadores acumulados; não prova perda de pacotes física nem inclui todo tipo de corrupção.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @gc_blocks_lost_events.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Dois conjuntos: evento/esperas/tempo em centésimos de segundo e contador por instância.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Destino gc_blocks_lost_events.sql evita sobrescrever o homônimo existente; ambos os SELECTs preservados. 
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

select
   inst_id,
   event,
   total_waits,
   time_waited
from
   gv$system_event
where
   event in ('gc current block lost',
             'gc cr block lost')
order by
   event,
   inst_id;

select
   sn.inst_id,
   sn.name,
   ss.value
from
   gv$statname sn,
   gv$sysstat ss
where
   sn.inst_id = ss.inst_id
   and
   sn.statistic# = ss.statistic#
   and
   sn.name = 'gc blocks lost'
order by
   sn.inst_id;
