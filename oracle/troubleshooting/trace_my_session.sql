/*
===============================================================================
SCRIPT: trace_my_session.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/trace_my_session.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Ativar trace de SQL da sessão corrente com waits e binds.

FUNCIONAMENTO DETALHADO
  Consulta SID/SERIAL# da sessão por SYS_CONTEXT e chama DBMS_MONITOR.SESSION_TRACE_ENABLE com TRUE/TRUE.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION, SYS_CONTEXT, DBMS_MONITOR

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  EXECUTE/SELECT autorizados. Captura binds pode revelar dados sensíveis/credenciais e aumenta CPU/I/O/disco; estabelecer janela e desabilitar depois. Não chamar para workload produtivo sem procedimento operacional.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente sessão de laboratório e dados fictícios: revisar @trace_my_session.sql.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Trace habilitado para a sessão; arquivo cresce quando há atividade.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código integral preservado; helper de desativação deve ser revisado em conjunto. 
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

declare
   v_sid    number;
   v_serial number;
begin
   select
      sid,
      serial#
   into
      v_sid,
      v_serial
   from
      v$session
   where
      sid=SYS_CONTEXT('USERENV','SID');

   dbms_monitor.session_trace_enable(v_sid,v_serial,TRUE,TRUE);
end;
/
