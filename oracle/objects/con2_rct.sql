/*
===============================================================================
SCRIPT: con2_rct.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/CON2_RCT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar scripts de checks, PK/UK e FK do usuário com staging de nomes 64.

FUNCIONAMENTO DETALHADO
  Coleta USER_CONSTRAINTS/COLUMNS, numera FKs em CONS_TEMP, cria índices e emite três arquivos DROP/ADD/index/storage.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS de criação/execução/consulta e permissões administrativas
  conforme limitações; não instalar variantes sobre objetos de trabalho.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  USER_CONSTRAINTS, USER_CONS_COLUMNS, USER_INDEXES, CONS_TEMP, V$DATABASE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DROPs gerados podem remover integridade/índices; presume nome de índice igual ao da constraint. Default não é tipo D de constraint moderna; SEARCH_CONDITION LONG e buffers2000 podem truncar. Não preserva estados/quoting/recursos novos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema descartável; revisar todos os três arquivos antes de usar.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  CK_RCT/PK_RCT/FK_RCT.SQL; CONS_TEMP permanece instalada.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: DDL/DML, staging, autenticação ou efeitos da saída
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Fechamento de parêntese STORAGE ausente acrescentado ao PK_RCT e owner na referência FK; todo pipeline/commits preservado. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 041 — 04/11/2026
  Correções e melhorias: Interrupção SQL antes de CREATE de CONS_TEMP.
  Limitações e pendências: FK exige pai presente no staging USER; pai cross-schema pode ser omitido. Assume índice=constraint, DROP de índice FK presume existência e filtro %NULL% elimina CHECK legítimo. Estados/deferrability/NOT NULL não completos.
  Homologação necessária: FK externa, PK com índice de nome diferente, CHECK contendo NULL e staging existente; inspecionar três arquivos.
  Parâmetros e execução: contratos acima e no corpo; só ambiente controlado.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e comparação estática; sem compilação/execução
  Oracle, Windows, alteração de privilégio ou gravação de arquivo no servidor.

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
REM    	FUNCTION: This script must be run by the constraint owner.  
REM 
REM 	FUNCTION: This script is intended to run with Oracle7.
REM
REM FUNCTION: Running this script will in turn create a script to build all the 
REM FUNCTION: constraints owned in the database.  Th created script is called 
REM FUNCTION: 'create_constraints.sql'.
REM 
REM
REM Only preliminary testing of this script was performed.  Be sure to test 
REM it completely before relying on it.  
REM
 
set verify off
set feedback off
set termout off
set echo off
set pagesize 0
set long 4000
set termout on
select 'Creating constraint build script...' from dual;
set termout off
 
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
CREATE TABLE cons_temp (owner varchar2(64),
			constraint_name varchar2(64),
			constraint_type varchar2(15),
			table_name varchar2(64),
			search_condition varchar2(2000),
			referenced_owner varchar2(64),
			referenced_constraint varchar2(64),
			delete_rule varchar2(9),
			constraint_columns varchar2(2000),
			con_number number); 

DECLARE
 
   CURSOR cons_cursor IS 
	select	owner,
   		constraint_name, 
   		decode(constraint_type,'P','Primary Key',
	  		'R','Foreign Key',
			'U','Unique',
			'C','Check',
			'D','Default'),
   		table_name,
   		search_condition, 
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
     where 
	constraint_name=cons_name and 
	owner not in ('SYS','SYSTEM')
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
   	cons_name  	varchar2(64);
   	cons_type	varchar2(15);
   	cons_sc		user_constraints.search_condition%TYPE;
	cons_tname	user_constraints.table_name%TYPE;
	cons_rowner	user_constraints.r_owner%TYPE;
	cons_rcons	user_constraints.r_constraint_name%TYPE;
	cons_dr		user_constraints.delete_rule%TYPE;   
	cons_col_own	varchar2(64);
	cons_col_nam	varchar2(64);
	cons_column	varchar2(64);
	cons_tcol_name user_cons_columns.table_name%TYPE;
	all_columns 	varchar2(2000);
	counter		integer:=0;
	cons_nbr 	integer;

BEGIN
   OPEN cons_cursor;
   LOOP
      FETCH cons_cursor INTO 	cons_owner,
      				cons_name,
      				cons_type,
      				cons_tname,
      				cons_sc,
      				cons_rowner,
				cons_rcons,
      				cons_dr;
      EXIT WHEN cons_cursor%NOTFOUND;
	all_columns :='';	
	counter := 0;
	open cons_col (cons_name);
	loop
		fetch cons_col into
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
				      cons_tname,
				      cons_sc,
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
create index lk_cons_temp on cons_temp(constraint_type);
create index lk_cons_temp2 on cons_temp(referenced_constraint);
set heading off feedback off pages 0 termout off echo off
set recsep off verify off
set embedded on
define cr='chr(10)'
column x word_wrapped
column dbname new_value db noprint
select name dbname from v$database;
spool rep_out\&db\ck_rct.sql
select 'alter table '||a.table_name||&&cr||
'drop constraint '||a.constraint_name||';'||&&cr||
'alter table '||a.table_name||' add constraint '||a.constraint_name||&&cr||
constraint_type||'( '||a.search_condition||' )'||&&cr||
';' x
from cons_temp a where constraint_type in ( 'Check','Default' ) and
search_condition not like '%NULL%'
/
spool off
spool rep_out\&db\pk_rct.sql
select 'alter table '||a.table_name||&&cr||
'drop constraint '||a.constraint_name||';'||&&cr||
'drop index '||a.constraint_name||';'||&&cr||
'alter table '||a.table_name||' add constraint '||a.constraint_name||&&cr||
constraint_type||'( '||a.constraint_columns||' )'||&&cr||
'using index tablespace '||b.tablespace_name||&&cr||
'pctfree '||b.pct_free||&&cr||
'initrans '||b.ini_trans||&&cr||
'maxtrans '||b.max_trans||&&cr||
'storage ('||&&cr||
'initial '||b.initial_extent||&&cr||
'next '||b.next_extent||&&cr||
'minextents '||b.min_extents||&&cr||
'maxextents '||b.max_extents||&&cr||
'pctincrease '||b.pct_increase||&&cr||')'||&&cr||
';' x
from cons_temp a, user_indexes b where
a.constraint_type in ('Primary Key','Unique') and
a.constraint_name=b.index_name 
/
spool off
spool rep_out\&db\fk_rct.sql
select 'alter table '||a.table_name||&&cr||
'drop constraint '||a.constraint_name||&&cr||
';'||&&cr||
'drop index '||a.constraint_name||';'||&&cr||
'alter table '||a.table_name||' add constraint '||'FK_'||a.table_name||'_'||a.con_number||&&cr||
a.constraint_type||'( '||&&cr||
a.constraint_columns||' )'||&&cr||
'references '||a.referenced_owner||'.'||b.table_name||' ( '||&&cr||
b.constraint_columns||' ) '||&&cr||
decode (a.delete_rule,'CASCADE','on delete cascade','')||&&cr||
';'||&&cr||
'create index '||'FK_'||a.table_name||'_'||a.con_number||' on '||a.table_name||'( '||&&cr||
a.constraint_columns||') '||&&cr||
'tablespace &tablespace_name'||&&cr||
';' x
from cons_temp a, cons_temp b
where a.constraint_type = 'Foreign Key' and
a.referenced_constraint=b.constraint_name and a.referenced_owner=b.owner
/
spool off
set verify on
set feedback on
set termout on
set echo on
set pagesize 22
clear columns
clear breaks
undef cr
