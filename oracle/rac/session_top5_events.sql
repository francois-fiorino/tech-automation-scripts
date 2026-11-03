/*
===============================================================================
SCRIPT: session_top5_events.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/session_top5_events.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Classificar cinco esperas não Idle acumuladas de uma sessão RAC.

FUNCIONAMENTO DETALHADO
  Filtra GV$SESSION_EVENT por instância/SID e exclui classe Idle via EVENT_NAME; calcula RATIO_TO_REPORT antes do top cinco.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$SESSION_EVENT, V$EVENT_NAME

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  SID pode ser reutilizado; consultar sessão correta. Contadores são acumulados desde conexão e podem refletir instrumentação desabilitada. WAIT% usa todos os eventos selecionados, não apenas cinco.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @session_top5_events.sql
  -- Informar instância e SID numéricos.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Evento, TIME_WAITED em centésimos de segundo e porcentagem do tempo não Idle da sessão.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Ordenação qualificada pelo valor numérico de origem para evitar alias TO_CHAR ordenar texto. 
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

set verify off
accept v_instid prompt 'Enter Instance Id: '
accept v_sid    prompt 'Enter SID: '
select
   *
from (
   select 
      event,
      to_char(time_waited,'999,999,999') as time_waited,
      to_char(round(ratio_to_report(time_waited) over ()*100,2),'990.00') as "WAIT%"
   from 
      gv$session_event se
   where 
      inst_id = &v_instid
      and
      sid = &v_sid
      and 
      event not in (select 
                       name 
                    from 
                       v$event_name
                    where 
                       wait_class='Idle')
   order by 
      se.time_waited desc)
where
   rownum <= 5;