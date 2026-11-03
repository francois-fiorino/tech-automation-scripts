/*
===============================================================================
SCRIPT: px_cluster_interconnect_waits.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/px_cluster_interconnect_waits.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Agregar esperas de crédito PX por buffer e envio bloqueado.

FUNCIONAMENTO DETALHADO
  Filtra os eventos PX Deq Credit: need buffer e PX Deq Credit: send blkd em GV$SYSTEM_EVENT e soma tempos/esperas, usando média ponderada.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$SYSTEM_EVENT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Pode refletir fluxo entre produtores/consumidores e não comprova gargalo de rede. Valores acumulados entre instâncias; médias não mostram cauda de latência.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @px_cluster_interconnect_waits.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  EVENT, TOTAL_WAITS, TIME_WAITED e AVG_WAIT na unidade centésimos de segundo da view.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  AVG(AVERAGE_WAIT) substituído por razão ponderada SUM(TIME_WAITED)/NULLIF(SUM(TOTAL_WAITS),0). 
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
   event,
   sum(total_waits) as total_waits,
   sum(time_waited) as time_waited,
   round(sum(time_waited)/nullif(sum(total_waits),0),2) as avg_wait
from 
   gv$system_event
where 
   event in ('PX Deq Credit: need buffer',
             'PX Deq Credit: send blkd')
group by 
   event
order by 
   event;