/*
===============================================================================
SCRIPT: trig_rct2.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/trig_rct2.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar triggers de uma tabela e owner específicos.

FUNCIONAMENTO DETALHADO
  Mesmo staging/cursores de TRIG_RCT com filtros TAB_NAME/OWNER e ordenação por trigger_name.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS de criação/execução/consulta e permissões administrativas
  conforme limitações; não instalar variantes sobre objetos de trabalho.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TRIGGERS, DBA_TRIGGER_COLS, DUAL, TRIG_TEMP, TOOLS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE/DROP staging e COMMIT confirmam transações. Limites 30/400/2000/LONG4000, tipos modernos e state de triggers não são exportados integralmente. Nomes sem quoting e slash inicial da saída exigem revisão manual.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: revisar filtros e TOOLS antes de executar gerador.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  CRT_TRGS.SQL de subset de triggers.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: DDL/DML, staging, autenticação ou efeitos da saída
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Terminador final do último trigger acrescentado; filtros que distinguem variante preservados. 
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
REM  trig_rct.sql
REM
REM    FUNCTION: SCRIPT FOR RE-CREATING DATABASE TRIGGERS 
REM              This script can be run by anyone with access to dba_ triggers
REM              This script is intended to run with Oracle7.
REM              Running this script will in turn create a script to 
REM              build all the triggers in the database.  This created 
REM              script is called 'crt_trig.sql'.
REM              Only preliminary testing of this script was performed.  
REM              Be sure to test it completely before relying on it.  
set verify off feedback off termout off echo off pagesize 0 long 4000
set termout on arraysize 1
select 'Creating trigger build script...' from dual;
rem set termout off
set echo on
create table trig_temp (owner varchar2(30),
			trigger_name varchar2(30),
			trigger_type varchar2(16),
			triggering_event varchar2(26),
			table_owner varchar2(30),
			table_name varchar2(30),
			referencing_names varchar2(87),
			when_clause varchar2(2000),
			trigger_body long,
			trigger_columns varchar2(400)) 
storage (initial 100k next 100k)
tablespace tools;
 
DECLARE
   CURSOR trig_cursor IS select owner,
				trigger_name, 
				trigger_type , 
				triggering_event, 
				'on '||table_owner,
				table_name,
				referencing_names,
				'when '||when_clause,
				trigger_body
			from dba_triggers 
			where owner not in ('SYS','SYSTEM')
			and table_name=upper('&tab_name')
			and owner=upper('&owner')
			order by trigger_name;
	cursor trig_col ( owner varchar2, name varchar2 ) is 
			select trigger_owner,
				trigger_name,
				column_name
			from dba_trigger_cols 
			where trigger_owner = owner and
				trigger_name = name;

	trig_owner      dba_triggers.owner%TYPE;
	trig_name       dba_triggers.trigger_name%TYPE;
	trig_type       dba_triggers.trigger_type%TYPE;
	trig_event      dba_triggers.triggering_event%TYPE;
	trig_towner     dba_triggers.table_owner%TYPE;
	trig_tname      dba_triggers.table_name%TYPE;
	trig_rnames     dba_triggers.referencing_names%TYPE;
	trig_wclause    dba_triggers.when_clause%TYPE;
	trig_body       dba_triggers.trigger_body%TYPE;   
	trig_col_own    dba_trigger_cols.trigger_owner%TYPE;
	trig_col_nam    dba_trigger_cols.trigger_name%TYPE;
	trig_column     dba_trigger_cols.column_name%TYPE;   
	all_columns     varchar2(400);
	counter         integer:=0;

BEGIN
   OPEN trig_cursor;
   LOOP
      FETCH trig_cursor INTO    trig_owner,
				trig_name,
				trig_type,
				trig_event,
				trig_towner,
				trig_tname,
				trig_rnames,
				trig_wclause,
				trig_body;
      EXIT WHEN trig_cursor%NOTFOUND;
	all_columns :='';       
	counter := 0;
	open trig_col(trig_owner,trig_name);
	loop
		fetch trig_col into
				     	trig_col_own,
					trig_col_nam,
					trig_column;
		exit when trig_col%NOTFOUND; 
			counter := counter+1;
			if counter = 1 then
			all_columns := ' of '||all_columns||trig_column;
			else
			all_columns := all_columns||', '||trig_column;
		end if;
	end loop;
	close trig_col;
	if trig_rnames = 'REFERENCING NEW AS NEW OLD AS OLD' then
		trig_rnames := '';
	end if;
	if trig_wclause = 'when ' then
		trig_wclause := '';
	end if;
	insert into trig_temp values (trig_owner,
				trig_name,
				trig_type,
				trig_event,
				trig_towner,
				trig_tname,
				trig_rnames,
				trig_wclause,
				trig_body,
				all_columns);
   END LOOP;
   CLOSE trig_cursor;
   commit;
END;
/
define cr='chr(10)'
spool rep_out\crt_trgs.sql
set heading off
set recsep off pages 0

select '/'||&&cr||&&cr||'create or replace trigger '||owner||'.'||trigger_name||&&cr||
decode(trigger_type,'BEFORE EACH ROW','BEFORE ',
		'AFTER EACH ROW','AFTER ',trigger_type)||triggering_event||&&cr||
trigger_columns||&&cr||
table_owner||'.'||table_name||' '||referencing_names||&&cr||
decode(trigger_type,'BEFORE EACH ROW','FOR EACH ROW',
		'AFTER EACH ROW','FOR EACH ROW','')||&&cr||
when_clause,
trigger_body
from trig_temp 
order by owner;
select '/' from dual;
spool off
drop table trig_temp;   
set verify on feedback on termout on echo on pagesize 22
set heading on recsep on
clear columns
