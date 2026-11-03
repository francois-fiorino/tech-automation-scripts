/*
===============================================================================
SCRIPT: in_rct2.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _index_scripts/in_rct2.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar DDL de índices com tamanho estimado de SIZE_IT.

FUNCIONAMENTO DETALHADO
  Cursor INDEXES/SIZE_IT calcula extents SIZE_IN_BLOCKS*8192, exclui INDEX_TS; cria I_TEMP e gera DROP para UNIQUE e CREATE/storage.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas conforme limitações individuais.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_INDEXES, DBA_IND_COLUMNS, SIZE_IT (customizada), I_TEMP, V$DATABASE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  8 KB fixos podem estar errados e SIZE_IT só unido por nome pode cruzar owners. Não cobre bitmap/LOB/expressões/partições como variante IN_RCT. DDL/staging confirma transações; nomes e limites exigem revisão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório com contrato SIZE_IT revisado e sem I_TEMP valiosa.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  CRT_INDX.SQL com sizing estimado e possíveis DROP INDEX.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos de criação, staging, autenticação, sessão
  ou código gerado descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Owner acrescentado ao cursor de colunas; fórmula/fluxo de DROP e estimativa de tamanho preservados para homologação. 
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
REM
REM in_rct.sql
REM
REM FUNCTION: SCRIPT FOR CREATING INDEXES
REM
REM           This script must be run by a user with the DBA role.
REM
REM  comment: Running this script will in turn create a script to build all the indexes in the database.  
REM           This created 
REM           script, create_index.sql, can be run by any user with 
REM           the DBA role or with the 'CREATE ANY INDEX' system 
REM           privilege.
REM
REM           The script will NOT capture the indexes created by 
REM           the user 'SYS'.
REM
REM NOTE:     Indexes automatically created by table CONSTRAINTS will 
REM           also be INCLUDED in the create_index.sql script.  It may 
REM           cause a problem to create an index with a system assigned 
REM           name such as SYS_C00333.
REM 
REM           Only preliminary testing of this script was performed.  
REM           Be sure to test it completely before relying on it.
REM
 
set verify off;
set termout off;
set feedback off;
set echo off;
set pagesize 0;
undef table
undef owner
set termout on
select 'Creating index build script...' from dual;
rem set termout off;
 
create table i_temp 
     (lineno NUMBER, id_name VARCHAR2(30), 
      text VARCHAR2(2000)) storage (initial 100k next 100k)
/
truncate table i_temp;
 
DECLARE
   CURSOR ind_cursor IS select   
				 a.owner,
				 a.index_name,
				 a.table_owner, 
				 a.table_name,
				 a.uniqueness,
				 a.tablespace_name,
				 a.ini_trans,
				 a.max_trans,
				 b.size_in_blocks*8192 initial_extent,
				 b.size_in_blocks*8192 next_extent,
				 a.min_extents,
				 a.max_extents,
				 a.pct_increase,
				 a.pct_free
			from     dba_indexes a, size_it b
			where a.table_name like upper('%&table%')
			and a.owner like upper('%&owner%')
			and a.tablespace_name != 'INDEX_TS'
			and a.index_name=b.segment_name
			order by b.size_in_blocks desc,a.owner,a.index_name;
   CURSOR col_cursor ( c_ind VARCHAR2, c_tab VARCHAR2, c_owner VARCHAR2) IS
	       select   column_name
					 from     dba_ind_columns
					 where    
					     index_owner=c_owner and index_name = c_ind
					   and    table_name = c_tab
					 order by column_position;
   lv_owner		dba_indexes.owner%TYPE;
   lv_index_name        dba_indexes.index_name%TYPE;
   lv_table_owner       dba_indexes.table_owner%TYPE;
   lv_table_name        dba_indexes.table_name%TYPE;
   lv_uniqueness        dba_indexes.uniqueness%TYPE;
   lv_tablespace_name   dba_indexes.tablespace_name%TYPE;
   lv_ini_trans         dba_indexes.ini_trans%TYPE;
   lv_max_trans         dba_indexes.max_trans%TYPE;
   lv_initial_extent    dba_indexes.initial_extent%TYPE;
   lv_next_extent       dba_indexes.next_extent%TYPE;
   lv_min_extents       dba_indexes.min_extents%TYPE;
   lv_max_extents       dba_indexes.max_extents%TYPE;
   lv_pct_increase      dba_indexes.pct_increase%TYPE;
   lv_pct_free          dba_indexes.pct_free%TYPE;
   lv_column_name       dba_ind_columns.column_name%TYPE;
   lv_first_rec         BOOLEAN;
   lv_string            VARCHAR2(2000);
   lv_lineno            number := 0;
 
   procedure write_out(p_line INTEGER, p_name VARCHAR2, 
		       p_string VARCHAR2) is
   begin
      insert into i_temp (lineno, id_name,text) 
	     values (p_line,p_name,p_string);
   end;
 
BEGIN
   OPEN ind_cursor;
   LOOP
      FETCH ind_cursor INTO     
				lv_owner,
				lv_index_name,
				lv_table_owner,
				lv_table_name,
				lv_uniqueness,
				lv_tablespace_name,
				lv_ini_trans,
				lv_max_trans,
				lv_initial_extent,
				lv_next_extent,
				lv_min_extents,
				lv_max_extents,
				lv_pct_increase,
				lv_pct_free;
      EXIT WHEN ind_cursor%NOTFOUND;
	lv_lineno := 1;
      lv_first_rec := TRUE;
      if (lv_uniqueness = 'UNIQUE') then
	 lv_string:= 'DROP INDEX '||lower(lv_owner)||'.'||lower(lv_index_name)||';'||chr(10)||
		     'CREATE UNIQUE INDEX '||lower(lv_owner)||'.'||lower(lv_index_name);
	 write_out(lv_lineno, lv_index_name, lv_string);
	 lv_lineno := lv_lineno + 1;
      else
	 lv_string:= 'CREATE INDEX ' || lower(lv_index_name);
	 write_out(lv_lineno,  lv_index_name, lv_string);
	 lv_lineno := lv_lineno + 1;
      end if;
      OPEN col_cursor(lv_index_name,lv_table_name,lv_owner);
      LOOP
	 FETCH col_cursor INTO  lv_column_name;
	 EXIT WHEN col_cursor%NOTFOUND;
	 if (lv_first_rec) then
	    lv_string := '   ON '|| lower(lv_table_owner) || '.' || 
			 lower(lv_table_name)||' (';
	 lv_first_rec := FALSE;
	 else
	    lv_string := lv_string || ',';
	 end if;
	 lv_string := lv_string || lower(lv_column_name);
      END LOOP;
      CLOSE col_cursor;
      lv_string := lv_string || ')';
      write_out(lv_lineno,  lv_index_name, lv_string);
      lv_lineno := lv_lineno + 1;
      lv_string := null;
      lv_string := 'PCTFREE ' || to_char(lv_pct_free);
      write_out(lv_lineno,  lv_index_name, lv_string);
      lv_lineno := lv_lineno + 1;
      lv_string := 'INITRANS ' || to_char(lv_ini_trans) ||
		' MAXTRANS ' || to_char(lv_max_trans);
      write_out(lv_lineno,  lv_index_name, lv_string);
      lv_lineno := lv_lineno + 1;
      lv_string := 'TABLESPACE ' || lv_tablespace_name || ' STORAGE (';
      write_out(lv_lineno,  lv_index_name, lv_string);
      lv_lineno := lv_lineno + 1;
      lv_string := 'INITIAL ' || to_char(lv_initial_extent) ||
		   ' NEXT ' || to_char(lv_next_extent);
      write_out(lv_lineno,  lv_index_name, lv_string);
      lv_lineno := lv_lineno + 1;
      lv_string := 'MINEXTENTS ' || to_char(lv_min_extents) ||
		' MAXEXTENTS ' || to_char(lv_max_extents) ||
		' PCTINCREASE ' || to_char(lv_pct_increase) || ')';
      write_out(lv_lineno,  lv_index_name, lv_string);
      lv_lineno := lv_lineno + 1;
      lv_string := '/';
      write_out(lv_lineno,  lv_index_name, lv_string); 
      lv_lineno := lv_lineno + 1;
      lv_lineno := lv_lineno + 1;
      lv_string:='                                                  ';
      write_out(lv_lineno,  lv_index_name, lv_string);
   END LOOP;
   CLOSE ind_cursor;
END;
/
 column dbname new_value db noprint;
select name dbname from v$database;
spool rep_out\&db\crt_indx.sql
set heading off
set recsep off
col text format a80 word_wrap
 
select   text
from     I_temp
order by  id_name, lineno;
 
spool off
 
drop table i_temp;
 set verify on;
set termout on;
set feedback on;
set pagesize 22;
clear columns
