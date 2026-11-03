/*
===============================================================================
SCRIPT: resource_waits.sql
CATEGORIA: Oracle / performance/ash
ORIGEM: Oracle Script Collection 2015 / _wait_event_scripts/resource_waits.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Agrupar por evento a expressão histórica de tempos amostrados em ASH.

FUNCIONAMENTO DETALHADO
  Filtra SAMPLE_TIME entre SYSDATE-60/2880 e SYSDATE, uma janela de 30 minutos; soma WAIT_TIME+TIME_WAITED por EVENT e ordena crescente.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  V$ACTIVE_SESSION_HISTORY

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Oracle 10g+. ASH é amostragem; WAIT_TIME descreve a espera anterior quando ON CPU e não deve ser somado como duração total. EVENT NULL pode representar CPU. Retenção pode ser menor que 30 minutos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @resource_waits.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  EVENT e TTL_WAIT_TIME. A soma é a expressão original, não tempo total confiável de espera nem AAS.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Sem mudança funcional: a métrica original foi preservada e explicitamente sinalizada como inadequada para medir tempo total; requer redefinição e homologação. 
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
   ash.event,
   sum(ash.wait_time +
   ash.time_waited) ttl_wait_time
from 
   v$active_session_history ash
where 
   ash.sample_time between sysdate - 60/2880 and sysdate
group by 
   ash.event
order by 2;
