/*
===============================================================================
SCRIPT: ssession_wait_details.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _wait_event_scripts/ssession_wait_details.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir sessões locais atualmente em espera e parâmetros do evento.

FUNCIONAMENTO DETALHADO
  Une V$SESSION_WAIT a V$SESSION por SID; exclui nomes SQL%, message, timer e pipe get; restringe STATE=WAITING e apresenta P1/P2/P3.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION_WAIT, V$SESSION

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Exclusões textuais não equivalem a WAIT_CLASS<>Idle. WAIT_TIME tende a zero durante WAITING; ordenação original por esse campo pouco distingue duração. Recomendações históricas REM não são prescrições universais.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @ssession_wait_details.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Usuário, SID, EVENT, SECONDS_IN_WAIT, WAIT_TIME, parâmetros e estado.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta e comentários históricos preservados; sugestões de checkpoints/undo exigem diagnóstico antes de aplicação. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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

-- comment:  session wait details

REM event                       cause                           action
REM --------------------------- -----------------------------   -----------------------------------------
REM free buffer waits           DBWR not writing frequently     inscrease number of checkpoints 
REM                             enough  
REM latch free                  contention for latches          dependent upon latch
REM buffer busy waits           I/O contention, Parallel        tune I/O and distribute data effectively
REM                             Server conntention for data
REM                             blocks
REM db file sequential read     I/O contention                  tune I/O and distribute data effectively
REM db file scattered read      too many table scans            tune I/O, distribute data effectively
REM                                                             improperly tuned SQL statements
REM db file parallel write      not checkpointing frequently    increase number of checkpoints
REM                             enough
REM undo segment extension      too much dynamic extenstion/    appropriatley size rollback segments
REM                             shrinking of rollback segments
REM undo segment tx slot`       not enough rollback segments    create the appropriate number of segments
REM
column event format a25
column username format a10
set lin 131 pages 50 
set pau off
ttitle 'Database Waits'
spool ssession_wait_details.lst
select username, V$SESSION_WAIT.sid, event, seconds_in_wait, wait_time, p1 , p2, p3, state
  from V$SESSION_WAIT, V$SESSION
where V$SESSION_WAIT.SID = V$SESSION.SID
  and NOT(event like 'SQL%') 
  and NOT(event like '%message%')
  and NOT(event like '%timer%')
  and NOT(event like '%pipe get%')
  and state = 'WAITING'
  order by wait_time desc, event
/
spool off

