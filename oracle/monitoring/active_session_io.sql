/*
===============================================================================
SCRIPT: active_session_io.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/active_session_io.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar sessões de usuários ativas com seus contadores acumulados de I/O.

FUNCIONAMENTO DETALHADO
  Une V$SESSION e V$SESS_IO por SID, filtra USERNAME não NULL e STATUS=ACTIVE e ordena PHYSICAL_READS decrescente.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION, V$SESS_IO

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  ACTIVE descreve estado no momento da consulta; contadores podem ter sido acumulados durante toda a sessão. PROCESS pode conter texto/identificador composto, não PID numérico do servidor.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @active_session_io.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Usuários, PROCESS cliente, SID/SERIAL#, PHYSICAL_READS e BLOCK_CHANGES.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Formato numérico da coluna PID trocado por A20 para aceitar PROCESS textual. 
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

set lines 120

col osuser   format a10
col username format a15
col pid      format a20

prompt sessions by physical disk reads

select
   osuser,
   username,
   process pid,
   ses.sid sid,
   serial#,
   physical_reads,
   block_changes
 from    
   v$session ses,
   v$sess_io sio
where      
   ses.sid = sio.sid
and 
   username is not null
and 
   status='ACTIVE'
order by 
   physical_reads desc;