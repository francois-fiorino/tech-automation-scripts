/*
===============================================================================
SCRIPT: pid.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / misc_scripts/PID.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relacionar sessões/processos com estatística de commits da sessão.

FUNCIONAMENTO DETALHADO
  Une SESSION/PROCESS por endereço e SESSTAT/STATNAME por SID/statistic#, com timestamp do arquivo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION, V$PROCESS, V$SESSTAT, V$STATNAME, DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Filtro NAME LIKE %commits pode retornar mais de uma estatística; não identifica nome na saída. Contador não é taxa; PID interno difere do identificador SO e SID. Shared server exige interpretação.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @pid.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Username, PID Oracle, SID, terminal/programa, commits, SPID, OSUSER e SERIAL#.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Join b.pid=c.sid corrigido para a.sid=c.sid; spool temporal local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem
rem  Name:     pid.sql
rem
rem  FUNCTION: Generate a list of current oracle sids/pids
rem
column username format a12 heading 'User Name'
column program format a15 heading 'Executing|Program'
column pid format 9999
column sid format 9999
column osuser heading Operating|system|User
column terminal format a10
column g_date new_value f_date noprint
select to_char(sysdate,'ddmmyyyyhh24mi') g_date from dual; 
set lines 130
break on username 
compute count of pid on username
set pages 58
ttitle "Oracle Processes"
spool pid_&&f_date..lst
select 
	NVL(a.username,'Null') username,
	b.pid,
	a.sid,
	decode(a.terminal,'?','Detached',a.terminal) terminal,
	b.program,
	c.value commits, 
        spid,
	a.osuser,
	a.serial#
 from 
	v$session a, 
	v$process b,
        v$sesstat c,
        v$statname d
where 
	a.PADDR = b.ADDR
    and a.sid=c.sid
    and c.statistic#=d.statistic#
    and d.name like '%commits'
order by 
	a.username,
	b.pid
/
spool off
clear breaks
clear columns
set pages 22
ttitle off
pause Press enter to continue
