/*
===============================================================================
SCRIPT: sess_io_sessions_io.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/sess_io_sessions_io.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar contadores de leitura física e alteração de blocos de todas as sessões locais.

FUNCIONAMENTO DETALHADO
  Une V$SESSION e V$SESS_IO por SID, retorna identificadores de sessão e ordena PHYSICAL_READS decrescente.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION, V$SESS_IO

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Inclui sessões ativas e inativas; PROCESS é texto do cliente, não SPID do servidor. Contadores acumulados não medem IOPS ou consumo recente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @sess_io_sessions_io.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OSUSER, USERNAME, PID (PROCESS cliente), SID, SERIAL#, PHYSICAL_READS e BLOCK_CHANGES.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  COLUMN USERNAME FORMAT 10 inválido para texto substituído por A10. 
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

-- This v$sess_io script shows all sessions in the SGA (active and not active)
set lines 120
col osuser   format a10
col username format a10

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
order 
   by physical_reads desc;