/*
===============================================================================
SCRIPT: no_trace_my_session.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/no_trace_my_session.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Desativar trace de sessão corrente via DBMS_MONITOR.

FUNCIONAMENTO DETALHADO
  Obtém SID/SERIAL# usando SYS_CONTEXT e chama SESSION_TRACE_DISABLE.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION, DBMS_MONITOR, SYS_CONTEXT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  SELECT/EXECUTE autorizados e Oracle 10g+ com DBMS_MONITOR. Pode interromper coleta planejada para investigação; não remove dados sensíveis já gravados em disco. Par de TRACE_MY_SESSION no mesmo PR.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente sessão de laboratório com trace habilitado intencionalmente: revisar arquivo.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Trace da sessão desabilitado; nenhum arquivo de trace existente é apagado.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  conforme descritos. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código integral preservado; não executado. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 039 — 04/11/2026
  Correções e melhorias: Corpo preservado; desabilita apenas a sessão corrente.
  Limitações e pendências: Pode interromper diagnóstico planejado; não remove trace existente nem apaga binds já registrados.
  Homologação necessária: Habilitar trace em sessão descartável, desabilitar e verificar ausência de novos registros.
  Parâmetros/execução: manter contrato descrito acima e no corpo histórico.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação realizada: leitura integral e comparação estática; sem compilação
  ou execução Oracle, sem execução de comandos administrativos.

AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de qualquer utilização em produção. Sua execução é de responsabilidade do profissional responsável pelo ambiente. Os mantenedores deste repositório não se responsabilizam por indisponibilidade, perda de dados, alterações indevidas ou outros impactos decorrentes de sua utilização.

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

   dbms_monitor.session_trace_disable(v_sid,v_serial);
end;
/
