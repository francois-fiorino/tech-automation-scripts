/*
===============================================================================
SCRIPT: locks2.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/locks2.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar participantes de recursos com pedido de lock pendente.

FUNCIONAMENTO DETALHADO
  Filtra V$LOCK por recurso TYPE/ID1/ID2 com REQUEST>0, associa sessão/acessos e fragmentos SQL.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$LOCK, V$SESSION, V$ACCESS, V$SQLTEXT, V$SQLAREA

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  V$ACCESS lista objetos acessados pela sessão, não prova objeto específico do lock; pode multiplicar linhas por objeto/fragmento. FIRST_LOAD_TIME não é hora do pedido apesar do heading histórico. Não detecta ciclo de deadlock.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @locks2.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Sessão, usuário/terminal, tipos/modos, IDs, objetos acessados, fragmento SQL e FIRST_LOAD_TIME.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  TYPE incluído na identificação do recurso, hash na junção SQLAREA e terminador SQL acrescentado. 
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
REM ********************************************************************
REM Locks v.1.01				                27/05/96
REM This query will list locking conflicts between tables
REM and indicate users who are locking the tables and
REM there waited users. Must be run as SYS
REM Sanjeev Parikh
REM ********************************************************************

set headingsep ='|'
set lines 160
set pagesize 20

ttitle 'Database Locking Conflict Report'
btitle 'Mode Held = indicates the user holding the lock|Mode Request = indicates the user waiting on the later to finish to establish lock||** End of Locking Conflict Report **'

column username 	format a10	heading 'User'
column terminal 	format a15	heading 'Application|PC'
column object 		format a15	heading	'Table'
column sql  		format a15	heading 'SQL'
column sid 		format 999	heading 'SID'
column lock_type 	format a15	heading 'Lock|Type'
column mode_held 	format a11	heading 'Mode|Held'
column mode_requested 	format a10	heading 'Mode|Request'
column lock_id1 	format a8	heading 'Lock ID1'
column lock_id2 	format a8	heading 'Lock ID2'
column first_load_time  format a19	heading 'Requested'
 
break on lock_id1

select a.sid,
       username, 
       terminal,
       decode(a.type,'MR', 'Media Recovery',
   		     'RT', 'Redo Thread',
		     'UN', 'User Name',
		     'TX', 'Transaction',
		     'TM', 'DML',
		     'UL', 'PL/SQL User Lock',
		     'DX', 'Distributed Xaction',
  		     'CF', 'Control File',
		     'IS', 'Instance State',
		     'FS', 'File Set',
		     'IR', 'Instance Recovery',
		     'ST', 'Disk Space Transaction',
		     'IR', 'Instance Recovery',
		     'ST', 'Disk Space Transaction',
		     'TS', 'Temp Segment',
		     'IV', 'Library Cache Invalidation',
		     'LS', 'Log Start or Switch',
		     'RW', 'Row Wait',
		     'SQ', 'Sequence Number',
		     'TE', 'Extend Table',
		     'TT', 'Temp Table', a.type) lock_type,
   	decode(a.lmode,0, 'None',           /* Mon Lock equivalent */
   1, 'Null',           /* N */
   2, 'Row-S (SS)',     /* L */
   3, 'Row-X (SX)',     /* R */
   4, 'Share',          /* S */
   5, 'S/Row-X (SSX)',  /* C */
   6, 'Exclusive',      /* X */
   to_char(a.lmode)) mode_held,
   decode(a.request,
   0, 'None',           /* Mon Lock equivalent */
   1, 'Null',           /* N */
   2, 'Row-S (SS)',     /* L */
   3, 'Row-X (SX)',     /* R */
   4, 'Share',          /* S */
   5, 'S/Row-X (SSX)',  /* C */
   6, 'Exclusive',      /* X */
   to_char(a.request)) mode_requested,
   to_char(a.id1) lock_id1, to_char(a.id2) lock_id2,
   c.object object,
   d.sql_text sql,
   e.first_load_time
from v$lock a, v$session, v$access c, v$sqltext d, v$sqlarea e
   where (id1,id2) in
     (select b.id1, b.id2 from v$lock b where b.id1=a.id1 and
     b.id2=a.id2 and b.type=a.type and b.request>0) and
     a.sid = v$session.sid and
     a.sid = c.sid and
     d.address = v$session.sql_address and
     d.hash_value = v$session.sql_hash_value and
     d.address = e.address and d.hash_value=e.hash_value
order by a.id1, a.lmode desc;
