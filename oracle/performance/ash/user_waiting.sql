/*
===============================================================================
SCRIPT: user_waiting.sql
CATEGORIA: Oracle / performance/ash
ORIGEM: Oracle Script Collection 2015 / _wait_event_scripts/user_waiting.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relacionar amostras ASH das últimas 24 horas com sessões ainda existentes.

FUNCIONAMENTO DETALHADO
  Relaciona ASH a V$SESSION por SID e SERIAL#, agrupa por SID/USERNAME e soma a expressão original WAIT_TIME+TIME_WAITED.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  V$ACTIVE_SESSION_HISTORY, V$SESSION

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Oracle 10g+. Retenção em memória pode ser menor que um dia; sessões encerradas não aparecem. Soma histórica de WAIT_TIME/TIME_WAITED não mede duração total; requer revisão de metodologia.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @user_waiting.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  SID, USERNAME e WAIT_TIME agregado, ordenado crescente. Não representa tempo total de espera.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Adicionada igualdade SESSION_SERIAL#=SERIAL# para impedir associação de SID reutilizado a outra sessão. Métrica original mantida com ressalva. 
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
   sess.sid,
   sess.username,
   sum(ash.wait_time + ash.time_waited) wait_time
from 
   v$active_session_history ash,
   v$session sess
where 
   ash.sample_time > sysdate-1
and 
   ash.session_id = sess.sid
and ash.session_serial# = sess.serial#
group by 
   sess.sid, 
   sess.username
order by 3;
