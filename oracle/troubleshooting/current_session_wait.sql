/*
===============================================================================
SCRIPT: current_session_wait.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/current_session_wait.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Inspecionar evento e parâmetros de espera da própria sessão conectada.

FUNCIONAMENTO DETALHADO
  Filtra V$SESSION_WAIT pelo SID retornado por SYS_CONTEXT(USERENV,SID); retorna EVENT e P1/P2/P3.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION_WAIT, SYS_CONTEXT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não inspeciona outra sessão. Sem STATE/WAIT_TIME na saída, não distingue por si só espera atual de última espera; a consulta também altera a atividade observada.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @current_session_wait.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Evento e parâmetros da sessão que executa a consulta. Unidades e significado de P1/P2/P3 dependem do evento.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada; caracteres CR isolados normalizados para quebras de linha. 
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
   p1,
   p2,
   p3 
from 
   v$session_wait 
where 
   sid=SYS_CONTEXT('USERENV','SID');
