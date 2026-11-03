/*
===============================================================================
SCRIPT: hr_by_user.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/hr_by_user.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar razão acumulada de cache por sessão com contexto de processo.

FUNCIONAMENTO DETALHADO
  Une SESSION/SESS_IO/PROCESS, calcula 100*(gets-physical_reads)/gets e mostra estado, login, lockwait e LAST_CALL_ET.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$SESSION, SYS.V_$SESS_IO, SYS.V_$PROCESS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  LAST_CALL_ET é duração da chamada quando ACTIVE e tempo desde mudança quando INACTIVE; alias Seconds Idle é histórico. Razão isolada não mede saúde e pode ser negativa com leituras diretas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @hr_by_user.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Usuário/SID/máquina/SPID/status, login, lockwait, HIT_RATIO e SECONDS_IDLE.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF substitui denominador artificial 1 para gets zero; máscara HH24 não inclui PM. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col username format a15
column machine format a24
column program format a36
column sid format 999
column hit_ratio format 999.99 heading 'Hit|Ratio'
column seconds_idle heading 'Seconds|Idle'
column login format a22 heading 'Login'
column lockwait format a4 heading 'Lock|Wait'
ttitle 'Hit Ratio by User'
set lines 200 pages 50
spool hr_by_user.lst
SELECT A.USERNAME, 
  A.sid, 
  A.MACHINE, 
  C.spid OS_ID, 
  status,
  TO_CHAR(logon_time,'DD-MON-YY HH24:MI:SS') login,
  DECODE(A.LOCKWAIT,NULL,'No','Yes') Lockwait,
  round(100 * (consistent_gets + block_gets - physical_reads) /
  nullif(consistent_gets + block_gets,0),2) HIT_RATIO ,
  LAST_CALL_ET SECONDS_IDLE,
  A.PROGRAM
FROM sys.V_$SESSION A, 
     sys.V_$SESS_IO B,
     sys.v_$process C
WHERE (A.SID = B.SID ) and 
      (( A.username is not null) and (A.paddr = C.addr )) 
order by A.username;
spool off
set lines 80 pages 22
