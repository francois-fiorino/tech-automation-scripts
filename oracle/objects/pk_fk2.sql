/*
===============================================================================
SCRIPT: pk_fk2.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/PK_FK2.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Montar staging de constraints do usuário e relatar chaves referenciadas/filhas.

FUNCIONAMENTO DETALHADO
  CREATE/TRUNCATE CONS_TEMP, cursores USER_CONSTRAINTS/COLUMNS, concatena colunas por posição, numera FKs com commits e gera relatório por outer join; DROP staging.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS de criação/execução/consulta e permissões administrativas
  conforme limitações; não instalar variantes sobre objetos de trabalho.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  USER_CONSTRAINTS, USER_CONS_COLUMNS, CONS_TEMP, DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DDL/commits confirmam dados; SEARCH_CONDITION LONG/buffers2000 e tipos antigos limitam cobertura. USER_CONSTRAINTS tem OWNER; mantém escopo do usuário. Não exporta definição completa de constraints modernas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema descartável sem CONS_TEMP/índices homônimos.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Relatório PK/FK, incluindo chaves sem FK via outer join, e staging removido.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: DDL/DML, staging, autenticação ou efeitos da saída
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Owner referenciado incluído no outer join final, mantendo (+), para não cruzar chaves homônimas; nenhum cursor/relatório removido. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 042 — 04/11/2026
  Correções e melhorias: Interrupção SQL antes de CREATE/TRUNCATE; comparação de constraint preserva case em vez de UPPER.
  Limitações e pendências: Staging30/2000 e USER_* não resolvem pais externos; outer join também mostra constraints não PK/UK sem filtro específico. Commits e DROP staging persistem; helper TITLE132 externo.
  Homologação necessária: Constraint quoted e FK composta; pai ausente, chave sem filha e staging preexistente; verificar colunas em ordem.
  Parâmetros e execução: contratos descritos acima e no corpo histórico.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  backup/recovery, comandos Windows/Unix ou uso de credenciais reais.

AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de qualquer utilização em produção. Sua execução é de responsabilidade do profissional responsável pelo ambiente. Os mantenedores deste repositório não se responsabilizam por indisponibilidade, perda de dados, alterações indevidas ou outros impactos decorrentes de sua utilização.

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
REM    	FUNCTION: SCRIPT FOR DOCUMENTING DATABASE CONSTRAINTS 
REM
REM    	FUNCTION: This script must be run by the constraint owner.  
REM 
REM 	FUNCTION: This script is intended to run with Oracle7.
REM
REM FUNCTION: Running this script will document the primary key - foreign key
REM FUNCTION: constraints in the database 
REM 
REM
REM Only preliminary testing of this script was performed.  Be sure to test 
REM it completely before relying on it.  
REM

set arraysize 1 
set verify off
rem set feedback off
rem set termout off
rem set echo off
set pagesize 0
set long 4000
set termout on
select 'Creating constraint build script...' from dual;
rem set termout off
 
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
create table cons_temp (owner varchar2(30),
			constraint_name varchar2(30),
			constraint_type varchar2(11),
			search_condition varchar2(2000),
			table_name varchar2(30),
			referenced_owner varchar2(30),
			referenced_constraint varchar2(30),
			delete_rule varchar2(9),
			constraint_columns varchar2(2000),
			con_number number); 
truncate table cons_temp;

DECLARE
 
   CURSOR cons_cursor IS select	owner,
   				constraint_name, 
   decode(constraint_type,'P','Primary Key',
	  		'R','Foreign Key',
			'U','Unique',
			'C','Check',
			'D','Default'),
   				search_condition, 
   				table_name,
				r_owner,
				r_constraint_name,
				delete_rule
     from user_constraints 
     where owner not in ('SYS','SYSTEM')
     order by owner; 

     cursor cons_col (cons_name in varchar2) is 
	select 
	   	owner,
	   	constraint_name,
		column_name
     from user_cons_columns 
     where owner not in ('SYS','SYSTEM') and
	constraint_name = cons_name
     order by owner, constraint_name, 
				position;

	cursor get_cons (tab_nam in varchar2) is
	select distinct 
		OWNER,TABLE_NAME,CONSTRAINT_NAME,CONSTRAINT_TYPE
	from cons_temp
	where table_name=tab_nam
	and constraint_type='Foreign Key'
	order by owner,table_name,constraint_name;

	cursor get_tab_nam is
	select distinct table_name
	from cons_temp
	where constraint_type='Foreign Key'
	order by table_name;

	tab_nam		user_constraints.table_name%TYPE;
   	cons_owner	user_constraints.owner%TYPE;
   	cons_name  	user_constraints.constraint_name%TYPE;
   	cons_type	varchar2(11);
   	cons_sc		user_constraints.search_condition%TYPE;
	cons_tname	user_constraints.table_name%TYPE;
	cons_rowner	user_constraints.r_owner%TYPE;
	cons_rcons	user_constraints.r_constraint_name%TYPE;
	cons_dr		user_constraints.delete_rule%TYPE;   
	cons_col_own	user_cons_columns.owner%TYPE;
	cons_col_nam	user_cons_columns.constraint_name%TYPE;
	cons_column	user_cons_columns.column_name%TYPE;
	cons_tcol_name	user_cons_columns.table_name%TYPE;
	all_columns 	varchar2(2000);
	counter		integer:=0;
	cons_nbr 	integer;

BEGIN
   OPEN cons_cursor;
   LOOP
      FETCH cons_cursor INTO 	cons_owner,
      				cons_name,
      				cons_type,
      				cons_sc,
      				cons_tname,
      				cons_rowner,
				cons_rcons,
      				cons_dr;
      EXIT WHEN cons_cursor%NOTFOUND;
	all_columns :='';	
	counter := 0;
	open cons_col (cons_name);
	loop
		fetch cons_col  into
					cons_col_own,
	   				cons_col_nam,
	   				cons_column;
	exit when cons_col%NOTFOUND; 
		if cons_owner = cons_col_own and cons_name=cons_col_nam
		then
			counter := counter+1;
			if counter = 1 then
			all_columns := all_columns||cons_column;
			else
			all_columns := all_columns||', '||cons_column;
			end if;
		end if;
	end loop;
	close cons_col;
	insert into cons_temp values (cons_owner,
				      cons_name,
				      cons_type,
				      cons_sc,
				      cons_tname,
				      cons_rowner,
				      cons_rcons,
				      cons_dr,
				all_columns,
				0);
   commit;
   END LOOP;
   CLOSE cons_cursor;
   commit;
begin
 open get_tab_nam;
loop
  fetch get_tab_nam into tab_nam;
  exit when get_tab_nam%NOTFOUND;
/*sys.dbms_output.put_line(tab_nam);*/
  open get_cons (tab_nam);
  cons_nbr:=0;
  loop
    fetch get_cons into cons_owner,
			cons_tname,
			cons_name,
			cons_type;
    exit when get_cons%NOTFOUND;
    cons_nbr:=cons_nbr+1;
/*    sys.dbms_output.put_line('cons_nbr='||cons_nbr);*/
/*sys.dbms_output.put_line(cons_owner||'.'||cons_name||' '||cons_type);*/
    update cons_temp set con_number=cons_nbr where
	constraint_name=cons_name and
	constraint_type=cons_type and
	owner=cons_owner;
  end loop;
  close get_cons;
  commit;
end loop;
close get_tab_nam;
commit;
end;
END;
/
create index pk_cons_temp on cons_temp(constraint_name);
create index lk_cons_temp2 on cons_temp(referenced_constraint);
set feedback off pages 0 termout off echo off
set verify off
set pages 48 lines 132
column pri_own format a15 heading 'Pri Table|Owner'
column for_own format a15 heading 'For Table|Owner'
column pri_tab format a15 heading 'Pri Table|Name'
column for_tab format a15 heading 'For Table|Name'
column pri_col format a30 heading 'Pri Key|Columns' word_wrapped
column for_col format a30 heading 'For Key|Columns' word_wrapped
start title132 'Primary Key - Foreign Key Report'
spool rep_out\&db\pk_fk
break on a.owner on a.table_name on b.owner on b.table_name
select 
	b.owner pri_own,
	b.table_name pri_tab,
	rtrim(b.constraint_columns) pri_col,
	a.owner for_own, 
	a.table_name for_tab,
	rtrim(a.constraint_columns) for_col
from 
	cons_temp a, 
	cons_temp b
where
	a.referenced_constraint(+)=b.constraint_name and a.referenced_owner(+)=b.owner
order by
	1,2,4,5;
spool off
drop table cons_temp;
set verify on
set feedback on
set termout on
set echo on
set pagesize 22 lines 80
clear columns
clear breaks 
ttitle off
