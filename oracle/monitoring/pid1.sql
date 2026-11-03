/*
===============================================================================
SCRIPT: pid1.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / misc_scripts/PID1.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relacionar SID/SERIAL# a processo Oracle e identificador do SO.

FUNCIONAMENTO DETALHADO
  Une SESSION/PROCESS por PADDR/ADDR e apresenta PID interno, SPID textual e metadados.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION, V$PROCESS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Servidor compartilhado/threaded muda relação sessão/processo; identificador textual pode conter caracteres ou componentes. Não executar kill baseado apenas nesta saída.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @pid1.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Username, PID Oracle, SID, terminal/programa, SPID SO, OSUSER e SERIAL#.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Conversão hexadecimal por função HEXTOINTEGER ausente removida em favor de SPID textual original; evita interpretar PID decimal como hexadecimal. 
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
rem  Name:     pid1.sql
rem
rem  FUNCTION: Generate a list of current oracle sids/pids
rem
column username format a15 heading 'User Name'
column program format a15 heading 'Executing|Program'
column pid format 9999
column sid format 9999
column osuser heading Operating|system|User
set lines 130
break on username 
compute count of pid on username
set pages 58
ttitle "Oracle Processes"
spool cur_proc
select 
	NVL(a.username,'Null') username,
	b.pid,
	a.sid,
	decode(a.terminal,'?','Detached',a.terminal) terminal,
	b.program,
	b.spid spid,
	a.osuser,
	a.serial#
 from 
	v$session a, 
	v$process b
where 
	a.PADDR = b.ADDR
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
