/*
===============================================================================
SCRIPT: con_rct2.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/CON_RCT2.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar recriação de constraints de uma tabela selecionada e manter staging para inspeção.

FUNCIONAMENTO DETALHADO
  Cursores parametrizados owner/tabela, coleta/numeração em CONS_TEMP e gera três arquivos de constraints/índices.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS de criação/execução/consulta e permissões administrativas
  conforme limitações; não instalar variantes sobre objetos de trabalho.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_CONSTRAINTS, DBA_CONS_COLUMNS, USER_INDEXES, CONS_TEMP

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Além de ordem errada de argumentos, staging/FETCH trocam tabela/search condition e precisam homologação. Índices USER_* limitam owner atual; defaults/quoting/state não cobertos. DDL e múltiplos commits têm efeito persistente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: definir OWN_NAME/TAB_NAME e revisar staging antes da saída.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  CK_RCT/PK_RCT/FK_RCT.SQL e CONS_TEMP mantida (DROP comentado).

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: DDL/DML, staging, autenticação ou efeitos da saída
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Argumentos de cursores corrigidos para owner/tabela e owner na referência FK; inconsistência restante explicitada, sem presumir fix completo. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 041 — 04/11/2026
  Correções e melhorias: Corrigida troca TABLE_NAME/SEARCH_CONDITION por FETCH e INSERT explícito; interrupção de staging.
  Limitações e pendências: Só tabela selecionada entra no staging, então pais em outras tabelas ausentes impedem geração de FK. USER_INDEXES pode selecionar owner errado; macros sem validação e estados não cobertos.
  Homologação necessária: Pai diferente/mesma tabela, owner fora do usuário, casoquoted e staging; verificar omissões antes de qualquer execução.
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
REM CON_RCT.SQL
REM
REM FUNCTION: SCRIPT FOR RE-CREATING DATABASE CONSTRAINTS 
REM
REM FUNCTION: This script must be run by the constraint owner.  
REM 
REM FUNCTION: This script is intended to run with Oracle7.
REM
REM FUNCTION: Running this script will in turn create scripts to build 
REM           constraints owned in the database. The scripts are called 
REM           'pk_rct.sql', 'fk_rct.sql', and 'ck_rct.sql'. 
REM           The primary key and unique constraints will include the
REM           USING INDEX clause, you may point this to an INDEX
REM           tablespace if the constraints don’t already. The foreign
REM           key constraints build an index if one exists with the 
REM           same name as the constraint. Otherwise, the foreign key
REM           isn’t built.  You may wish to edit this part of the 
REM           script if this isn’t the case in your database
REM 
REM Only preliminary testing of this script was performed.  Be sure to
REM test it completely before relying on it.  
REM
REM
 
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
CREATE TABLE cons_temp (owner varchar2(30),
			constraint_name varchar2(30),
			constraint_type varchar2(11),
			search_condition varchar2(2000),
			table_name varchar2(30),
			referenced_owner varchar2(30),
			referenced_constraint varchar2(30),
			delete_rule varchar2(9),
			constraint_columns varchar2(2000),
			con_number number); 

DECLARE
 
   CURSOR cons_cursor(tab_owner varchar2, tab_name varchar2) IS 
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
     from dba_constraints 
     where owner = tab_owner and
     table_name= tab_name; 

     cursor cons_col(tab_owner varchar2, tab_name varchar2) is 
          select 
	   	owner,
	   	constraint_name,
		column_name
     from dba_cons_columns 
     where owner = tab_owner
     and table_name=tab_name
     order by owner, constraint_name, 
				position;

	cursor get_cons is
	select distinct 
		OWNER,TABLE_NAME,CONSTRAINT_NAME,CONSTRAINT_TYPE
	from cons_temp
	order by owner,table_name,constraint_name;

	tab_nam			user_constraints.table_name%TYPE;
  	cons_owner		user_constraints.owner%TYPE;
  	cons_name  		user_constraints.constraint_name%TYPE;
  	cons_type		varchar2(11);
  	cons_sc		user_constraints.search_condition%TYPE;
	cons_tname		user_constraints.table_name%TYPE;
	cons_rowner		user_constraints.r_owner%TYPE;
	cons_rcons		user_constraints.r_constraint_name%TYPE;
	cons_dr			user_constraints.delete_rule%TYPE;   
	cons_col_own		user_cons_columns.owner%TYPE;
	cons_col_nam		user_cons_columns.constraint_name%TYPE;
	cons_column		user_cons_columns.column_name%TYPE;
	cons_tcol_name	user_cons_columns.table_name%TYPE;
	all_columns 		varchar2(2000);
	counter			integer:=0;
	cons_nbr 		integer;

BEGIN
   OPEN cons_cursor('&&own_name','&&tab_name');
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
	open cons_col('&&own_name','&&tab_name');
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
	insert into cons_temp (owner, constraint_name, constraint_type, table_name,
 search_condition, referenced_owner, referenced_constraint, delete_rule,
 constraint_columns, con_number) values (cons_owner,
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
  open get_cons;
  cons_nbr:=0;
  loop
    fetch get_cons into cons_owner,
			cons_tname,
			cons_name,
			cons_type;
    exit when get_cons%NOTFOUND;
    cons_nbr:=cons_nbr+1;
    sys.dbms_output.put_line('cons_nbr='||cons_nbr);
    sys.dbms_output.put_line(cons_owner||'.'||cons_name||' '||cons_type);
    update cons_temp set con_number=cons_nbr where
	constraint_name=cons_name and
	constraint_type=cons_type and
	owner=cons_owner;
  end loop;
  close get_cons;
  commit;
end;
END;
/
REM The following indexes make the create part of this script run
REM much faster
REM
create index pk_cons_temp on cons_temp(constraint_name);
create index lk_cons_temp on cons_temp(constraint_type);
create index lk_cons_temp2 on cons_temp(referenced_constraint);

set heading off feedback off pages 0 termout off echo off
set recsep off verify off
set embedded on
define cr='chr(10)'
REM
REM Do the check and default values first since they are usually 
REM the smallest
REM
spool ck_rct.sql
select 'alter table '||a.table_name||&&cr||
'drop constraint '||a.constraint_name||';'||&&cr||
'alter table '||a.table_name||' add constraint '||a.constraint_name||&&cr||
constraint_type||'( '||a.search_condition||' )'||&&cr||
';'
from cons_temp a where constraint_type in ( 'Check','Default' ) and
search_condition not like '%NULL%'
/
spool off
REM
REM Next, do the primary constraints
REM
spool pk_rct.sql
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
'pctincrease '||b.pct_increase||&&cr||
')'||&&cr||
';'
from cons_temp a, user_indexes b where
a.constraint_type in ('Primary Key','Unique') and
a.constraint_name=b.index_name 
/
spool off
REM
REM Finally do the foreign key constraints
REM
spool fk_rct.sql
select 'alter table '||a.table_name||&&cr||
'drop constraint '||a.constraint_name||';'||&&cr||
'drop index '||c.index_name||';'||&&cr||
'alter table '||a.table_name||' add constraint '||a.constraint_name||' '||a.constraint_type||'('||&&cr||
 a.constraint_columns||' )'||&&cr||
'references '||a.referenced_owner||'.'||b.table_name||' ('||&&cr||
b.constraint_columns||' )'||&&cr||
decode (a.delete_rule,'CASCADE','on delete cascade','')||&&cr||
';'||&&cr||
'create index '||c.index_name||' on '||a.table_name||'('||&&cr||
a.constraint_columns||')'||&&cr||
'tablespace '||c.tablespace_name||&&cr||
'pctfree '||c.pct_free||' '||'initrans '||c.ini_trans||' maxtrans '||c.max_trans||&&cr||
'storage ( '||'initial '||c.initial_extent||' next '||c.next_extent||&&cr||
'minextents '||c.min_extents||' maxextents '||c.max_extents||&&cr||
'pctincrease '||c.pct_increase||&&cr||
')'||&&cr||
';'
from cons_temp a, cons_temp b, user_indexes c
where a.constraint_type = 'Foreign Key' and
a.referenced_constraint=b.constraint_name and a.referenced_owner=b.owner 
and a.constraint_name=c.index_name
/
rem drop table cons_temp;

set heading on feedback on pages 22 termout on echo on
set recsep on verify on
set embedded off
undef cr
clear columns

