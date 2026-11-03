/*
===============================================================================
SCRIPT: lib_cach_latch.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/lib_cach_latch.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar esperas de sessões locais após exclusões textuais de eventos ociosos.

FUNCIONAMENTO DETALHADO
  Consulta V$SESSION_WAIT, exclui nomes contendo SQL*Net e três eventos específicos; mostra estado, parâmetros, WAIT_TIME e SECONDS_IN_WAIT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION_WAIT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Apesar do nome, não restringe a library cache/latches. Sem STATE=WAITING, inclui última espera; exclusões textuais não equivalem a WAIT_CLASS<>Idle. WAIT_TIME tem valores especiais conforme estado e versão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @lib_cach_latch.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  SID, evento truncado a 25 caracteres, STATE, P1/P2, WAIT e SECONDS.

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

/*  */
set linesize 100
 select
 sid,
 substr(event,1,25) "event",
 state,
 p1,
 p2,
 wait_time Wait,
 seconds_in_wait seconds
 from v$session_wait
 where event not like '%SQL*Net%' and
       event not in ('pmon timer', 'smon timer', 'rdbms ipc message')
/
