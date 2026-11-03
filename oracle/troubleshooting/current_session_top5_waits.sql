/*
===============================================================================
SCRIPT: current_session_top5_waits.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/current_session_top5_waits.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Mostrar cinco eventos de maior tempo acumulado na sessão atual.

FUNCIONAMENTO DETALHADO
  Filtra V$SESSION_EVENT pelo SID da sessão conectada, ordena TIME_WAITED decrescente na subconsulta e limita cinco por ROWNUM.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION_EVENT, SYS_CONTEXT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não filtra Idle e pode destacar esperas ociosas da própria sessão; acumulado desde sua criação. Limite e ordenação estão no padrão top-N anterior a FETCH FIRST.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @current_session_top5_waits.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  EVENT, TOTAL_WAITS e TIME_WAITED, em centésimos de segundo nas versões documentadas.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada. 
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

column event format a30

select
   *
from 
(select
   event,
   total_waits,
   time_waited
from
   v$session_event
where
   sid=SYS_CONTEXT('USERENV','SID')
order by
   time_waited desc)
where
   rownum <=5;
