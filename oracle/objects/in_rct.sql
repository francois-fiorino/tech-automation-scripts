/*
===============================================================================
SCRIPT: in_rct.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _index_scripts/In_rct.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar DDL de índices selecionados por padrão de owner/tabela.

FUNCIONAMENTO DETALHADO
  CREATE/TRUNCATE I_TEMP, cursor INDEXES inclui UNIQUE/BITMAP e exclui LOB; concatena colunas/storage/buffer pool, spool e DROP staging.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas conforme limitações individuais.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_INDEXES, DBA_IND_COLUMNS, I_TEMP, V$DATABASE, DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DDL confirma transações; inclui índices de constraints e nomes de sistema. Não exporta expressões/descendência/partições/compressão/domain indexes integralmente; nomes LOWER e buffers2000 podem perder fidelidade. I_TEMP não tem owner na ordenação de nomes homônimos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema descartável e metadados de teste; revisar saída.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  CRT_INDX.SQL com CREATE de índices e atributos históricos.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos de criação, staging, autenticação, sessão
  ou código gerado descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Col_cursor passou a restringir INDEX_OWNER recebido do cursor principal, evitando misturar colunas de índices homônimos entre schemas; toda geração preservada. 
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
REM
REM           Running this script will in turn create a script to 
REM           build all the indexes in the database.  This created 
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
 
rem set verify off;
rem set termout off;
rem set feedback off;
rem set echo off;
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
				 owner,
				 index_name,
				 table_owner, 
				 table_name,
				 uniqueness,
				 tablespace_name,
				 ini_trans,
				 max_trans,
				 initial_extent,
				 next_extent,
				 min_extents,
				 max_extents,
				 pct_increase,
				 pct_free,
                                 index_type,
                                 buffer_pool
			from     dba_indexes
			where table_name like upper('%&table%')
			and owner like upper('&owner')
			order by owner,index_name;
   CURSOR col_cursor ( c_ind VARCHAR2, c_tab VARCHAR2, c_owner VARCHAR2) IS
	       select   column_name
					 from dba_ind_columns
					 where    
					     index_owner=c_owner and index_name = c_ind
					     and table_name = c_tab
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
   lv_index_type        dba_indexes.index_type%TYPE;
   lv_column_name       dba_ind_columns.column_name%TYPE;
   lv_def_buffer_pool	dba_indexes.buffer_pool%TYPE;
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
				lv_pct_free,
                                lv_index_type,
                                lv_def_buffer_pool;
      EXIT WHEN ind_cursor%NOTFOUND;
      if nvl(lv_index_type,' ')<>'LOB' THEN
	lv_lineno := 1;
      lv_first_rec := TRUE;
      if (lv_uniqueness = 'UNIQUE') then
	 lv_string:= 'CREATE UNIQUE INDEX '||lower(lv_owner)||'.'||lower(lv_index_name);
	 write_out(lv_lineno, lv_index_name, lv_string);
	 lv_lineno := lv_lineno + 1;
      elsif (lv_index_type = 'BITMAP') then
	 lv_string:= 'CREATE BITMAP INDEX '||lower(lv_owner)||'.'||lower(lv_index_name);
	 write_out(lv_lineno, lv_index_name, lv_string);
	 lv_lineno := lv_lineno + 1;
      else
	 lv_string:= 'CREATE INDEX ' || lower(lv_owner)||'.'||lower(lv_index_name);
	 write_out(lv_lineno,  lv_index_name, lv_string);
	 lv_lineno := lv_lineno + 1;
      end if;
         lv_string:='';
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
      lv_string := 'INITRANS ' || to_char(lv_ini_trans) ||chr(10)||
		' MAXTRANS ' || to_char(lv_max_trans);
      write_out(lv_lineno,  lv_index_name, lv_string);
      lv_lineno := lv_lineno + 1;
      lv_string := 'TABLESPACE ' || lv_tablespace_name ||chr(10)||
                 ' STORAGE (';
      write_out(lv_lineno,  lv_index_name, lv_string);
      lv_lineno := lv_lineno + 1;
      lv_string := 'INITIAL ' || to_char(lv_initial_extent) ||chr(10)||
		   ' NEXT ' || to_char(lv_next_extent);
      write_out(lv_lineno,  lv_index_name, lv_string);
      lv_lineno := lv_lineno + 1;
      lv_string := 'MINEXTENTS ' || to_char(lv_min_extents) ||chr(10)||
		' MAXEXTENTS ' || to_char(lv_max_extents) ||chr(10)||
		' PCTINCREASE ' || to_char(lv_pct_increase) ||chr(10)||
                ' BUFFER_POOL '||lv_def_buffer_pool||')';
      write_out(lv_lineno, lv_index_name, lv_string);
      lv_lineno := lv_lineno + 1;
      lv_string := '/';
      write_out(lv_lineno,  lv_index_name, lv_string); 
      lv_lineno := lv_lineno + 1;
      lv_lineno := lv_lineno + 1;
      lv_string:='                                                  ';
      write_out(lv_lineno,  lv_index_name, lv_string);
   END IF;
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
