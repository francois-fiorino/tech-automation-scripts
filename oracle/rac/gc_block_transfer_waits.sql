/*
===============================================================================
SCRIPT: gc_block_transfer_waits.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/gc_block_transfer_waits.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Agregar esperas de transferência de blocos gc com eventos terminados em -way.

FUNCIONAMENTO DETALHADO
  Filtra GV$SYSTEM_EVENT por gc%block%-way, soma esperas/tempos por evento e calcula média ponderada como tempo total dividido por esperas totais.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$SYSTEM_EVENT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Contadores acumulados; agregação não preserva desequilíbrio entre instâncias e não mede só latência da rede. Confirmar nomes/unidades na versão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @gc_block_transfer_waits.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  EVENT, TOTAL_WAITS, TIME_WAITED e AVG_WAIT; tempos em centésimos de segundo conforme view.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  AVG(AVERAGE_WAIT), média não ponderada entre instâncias, substituída por SUM(TIME_WAITED)/NULLIF(SUM(TOTAL_WAITS),0), arredondada a duas casas. 
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
   event like 'gc%block%-way'
group by 
   event
order by 
   event;