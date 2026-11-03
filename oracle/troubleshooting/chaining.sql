/*
===============================================================================
SCRIPT: chaining.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _table_scripts/CHAINING.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Estimar fetches adicionais de linhas durante leitura controlada de tabela.

FUNCIONAMENTO DETALHADO
  Lê contador de table fetch continued row antes/depois, localiza última coluna e uma coluna leading index NOT NULL e faz SELECT das linhas através de predicado MAX.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$STATNAME, V$SESSION, V$SESSTAT, DBA_TAB_COLUMNS, SYS.COL$, SYS.OBJ$, SYS.ICOL$, SYS.USER$, DUAL, tabela alvo

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Diferença não é contagem exata de linhas encadeadas: inclui migração/chaining e depende do plano/colunas efetivamente lidas. Full scan/fetch pode ser caro. Sem índice elegível variáveis ficam indefinidas e consulta anterior à mensagem pode falhar; múltiplos índices podem escolher última coluna retornada. SID via AUDSID deve ser único; objetos internos variam.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @chaining.sql HR EMP
  -- Somente tabela pequena de laboratório com leading index NOT NULL e SELECT autorizado.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Diferença do contador da própria sessão, apresentada com aviso de ser continued-row fetches.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Texto principal esclarece que se trata de continued-row fetches, sem remover leitura, contador, diagnóstico de pré-requisito ou créditos históricos. Não usar estimativa como prova de necessidade de rebuild. 
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
rem  **************************************************************************
rem
rem  NAME: CHAINING.sql     
rem
rem  FUNCTION: Report on the number of CHAINED rows within a named table 
rem
rem  NOTES:  Requires DBA priviledges.
rem          The target table must have a column that is the leading portion
rem             of an index and is defined as not null.
rem          Uses the V$SESSTAT table where USERNAME is the current user.
rem              A problem if > 1 session active with that USERID.
rem          The statistics in V$SESSTAT may change between releases and
rem              platforms.  Make sure that 'table fetch continued row' is
rem              a valid statistic.
rem          This routine can be run by AUTO_CHN.sql by remarking the two
rem              accepts and un-remarking the two defines.
rem
rem  INPUTS: obj_own = the owner of the table.
rem          obj_nam = the name of the table.
rem
rem  **************************************************************************

rem accept obj_own prompt 'Enter the table owner''s name: '
rem accept obj_nam prompt 'Enter the name of the table: '

define obj_own = &1
define obj_nam = &2

set termout off feedback off verify off echo off heading off embedded on

rem  Find out what statistic we want
column statistic# new_value stat_no 
select statistic# 
  from v$statname n
 where n.name = 'table fetch continued row'
/

rem  Find out who we are in terms of sid
column sid new_value user_sid 
select distinct sid from v$session
 where audsid = userenv('SESSIONID')
/

rem  Find the last col of the table and a not null indexed column
column column_name new_value last_col 
column name new_value indexed_column 
column value new_value before_count 
select column_name
  from dba_tab_columns
 where table_name = upper('&&obj_nam')
   and owner      = upper('&&obj_own')
 order by column_id
/
select c.name
  from sys.col$ c, sys.obj$ idx, sys.obj$ base, sys.icol$ ic
 where base.obj#   = c.obj#
   and ic.bo#      = base.obj#
   and ic.col#     = c.col#
   and base.owner# = (select user# from sys.user$
		       where name = upper('&&obj_own'))
   and ic.obj#     = idx.obj#
   and base.name   = upper('&&obj_nam')
   and ic.pos#     = 1
   and c.null$     > 0
/
select value
  from v$sesstat
 where v$sesstat.sid = &user_sid
   and v$sesstat.statistic# = &stat_no
/

rem  Select every row from the target table
select &last_col xx
  from &obj_own..&obj_nam
 where &indexed_column <= (select max(&indexed_column)
			     from &obj_own..&obj_nam)
/

column value new_value after_count 
select value
  from v$sesstat
 where v$sesstat.sid = &user_sid
   and v$sesstat.statistic# = &stat_no
/
 
set termout on

select 'Table '||upper('&obj_own')||'.'||upper('&obj_nam')||' contains '||
       (to_number(&after_count) - to_number(&before_count))||
       ' continued-row fetch'||
       decode(to_number(&after_count) - to_number(&before_count),1,'.','s.')
  from dual
 where rtrim('&indexed_column') is not null
/

rem If we don't have an indexed column this won't work so say so
select 'Table '||
       upper('&obj_own')||'.'||upper('&obj_nam')||
      ' has no indexed, not null columns.'
  from dual
 where rtrim('&indexed_column') is null
/

set termout on feedback 15 verify on pagesize 20 linesize 80 space 1 heading on
undef obj_nam
undef obj_own
undef before_count
undef after_count
undef indexed_column
undef last_col
undef stat_no
undef user_sid
clear columns
clear computes
