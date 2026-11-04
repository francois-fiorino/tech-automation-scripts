/*
===============================================================================
SCRIPT: tab_rct3.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/tab_rct3.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar DROP/CREATE de tabela e owner informados incluindo precisão NUMBER/FLOAT.

FUNCIONAMENTO DETALHADO
  Cursores DBA_TABLES/COLUMNS montam T_TEMP com nomes/tipos/not null e atributos storage, spool e DROP staging.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas conforme limitações individuais.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES, DBA_TAB_COLUMNS, T_TEMP, variáveis TAB_NAME/OWN_NAME

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não exporta defaults, LOBs, particionamento/constraints completas ou nomes quoted. SQL gerado não qualifica owner em todos os comandos; deve ser executado no contexto correto. DDL confirma transações.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema descartável; revisar tabela/owner e arquivo gerado.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  CRT_TABS.SQL com precisão/escala de NUMBER e precisão FLOAT.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos de criação, staging, autenticação, sessão
  ou código gerado descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Col_cursor agora restringe OWNER informado e FREELIST GROUPS corrigido; finalidade/colunas completas preservadas. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 040 — 04/11/2026
  Correções e melhorias: Interrupção SQL antes do CREATE protege T_TEMP preexistente.
  Limitações e pendências: Cursor principal usa macros sem normalização enquanto colunas usam UPPER; parâmetros exigem case de catálogo. Saída não qualifica owner e perde NUMBER(*,s), defaults/char semântica/LOB/constraints.
  Homologação necessária: Owner/tabela lower e upper, tabela homônima e quoted; validar NUMBER e destino de CREATE/DROP.
  Parâmetros e execução: contrato detalhado acima e no corpo; somente laboratório.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  sem Windows, exportação, job ou comando administrativo executado.

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
REM
REM tab_rct.sql
REM
REM FUNCTION: SCRIPT FOR CREATING TABLES
REM
REM           This script can be run by any user .
REM
REM           This script is intended to run with Oracle7.
REM
REM           Running this script will in turn create a script to 
REM           build all the tables owner by the user in the database.  This created 
REM           script, create_table.sql, can be run by any user with the 
REM	      'CREATE TABLE' system privilege. 
REM
REM NOTE:     The script will NOT include constraints on tables.  This 
REM           script will also NOT capture tables created by user 'SYS'.
REM
REM Only preliminary testing of this script was performed.  Be sure to test
REM it completely before relying on it.
REM
 
set verify off
rem set feedback off
rem set termout off
rem set echo off;
set pagesize 0
 
set termout on
select 'Creating table build script...' from dual;
rem set termout off
 
whenever sqlerror exit failure rollback
create table t_temp
     (lineno NUMBER, tb_owner VARCHAR2(30), tb_name VARCHAR2(30),
      text VARCHAR2(2000))
/
 
DECLARE
   CURSOR tab_cursor(tab_name varchar2, own_name varchar2) IS 
                        select   table_name,
				 pct_free,
				 pct_used,
				 ini_trans,
				 max_trans,
				 tablespace_name,
				 initial_extent,
				 next_extent,
				 min_extents,
				 max_extents,
				 pct_increase,
				freelists,
				freelist_groups
			from     dba_tables
			where table_name=tab_name and
                        owner=own_name;
   CURSOR col_cursor (c_tab VARCHAR2) IS select   
						  column_name,
						  data_type,
						  data_length,
						  data_precision,
						  data_scale,
						  nullable
					 from     dba_tab_columns
					 where owner=upper('&own_name') and table_name = c_tab
					order by column_id;
lv_table_name        dba_tables.table_name%TYPE;
   lv_pct_free          dba_tables.pct_free%TYPE;
   lv_pct_used          dba_tables.pct_used%TYPE;
   lv_ini_trans         dba_tables.ini_trans%TYPE;
   lv_max_trans         dba_tables.max_trans%TYPE;
   lv_tablespace_name   dba_tables.tablespace_name%TYPE;
   lv_initial_extent    dba_tables.initial_extent%TYPE;
   lv_next_extent       dba_tables.next_extent%TYPE;
   lv_min_extents       dba_tables.min_extents%TYPE;
   lv_max_extents       dba_tables.max_extents%TYPE;
   lv_pct_increase      dba_tables.pct_increase%TYPE;
   lv_column_name       dba_tab_columns.column_name%TYPE;
   lv_data_type         dba_tab_columns.data_type%TYPE;
   lv_data_length       dba_tab_columns.data_length%TYPE;
   lv_data_precision    dba_tab_columns.data_precision%TYPE;
   lv_data_scale        dba_tab_columns.data_scale%TYPE;
   lv_nullable          dba_tab_columns.nullable%TYPE;
   lv_freelists	dba_tables.freelists%TYPE;
   lv_freelist_groups dba_tables.freelist_groups%TYPE;
   lv_first_rec         BOOLEAN;
   lv_lineno            number := 0;
   lv_string            VARCHAR2(2000);
   nul_cnt	   number;
 
   procedure write_out(p_line INTEGER,  p_name VARCHAR2,
		       p_string VARCHAR2) is
   begin
      insert into t_temp (lineno, tb_name, text)
	     values (p_line,p_name,p_string);
   end;
 
BEGIN
   OPEN tab_cursor('&tab_name','&own_name');
   LOOP
      FETCH tab_cursor INTO
         			lv_table_name,
				lv_pct_free,
				lv_pct_used,
				lv_ini_trans,
				lv_max_trans,
				lv_tablespace_name,
				lv_initial_extent,
				lv_next_extent,
				lv_min_extents,
				lv_max_extents,
				lv_pct_increase,
				lv_freelists,
				lv_freelist_groups;
      EXIT WHEN tab_cursor%NOTFOUND;
	lv_lineno := 1;
	lv_string := 'DROP TABLE '|| lower(lv_table_name)||';';
	write_out(lv_lineno,  lv_table_name, lv_string);
	lv_lineno := lv_lineno + 1;
	lv_first_rec := TRUE;
	lv_string := 'CREATE TABLE '|| lower(lv_table_name)||' (';
	write_out(lv_lineno,  lv_table_name, lv_string);
	lv_lineno := lv_lineno + 1;
      lv_string := null;
      OPEN col_cursor(lv_table_name);
      nul_cnt:=0;
      LOOP
	 FETCH col_cursor INTO  lv_column_name,
				lv_data_type,
				lv_data_length,
				lv_data_precision,
				lv_data_scale,
				lv_nullable;
	 EXIT WHEN col_cursor%NOTFOUND;
	 if (lv_first_rec) then
	    lv_first_rec := FALSE;
	 else
	    lv_string :=  ',';
	 end if;
	if ((lv_data_type = 'NUMBER') and (lv_data_precision>0)) then
	 lv_string := lv_string || lower(lv_column_name) ||
		     ' ' || lv_data_type ||'('||lv_data_precision||','||
			nvl(lv_data_scale,0)||')';
	elsif ((lv_data_type = 'FLOAT') and (lv_data_precision>0)) then
	 lv_string := lv_string || lower(lv_column_name) ||
		     ' ' || lv_data_type ||'('||lv_data_precision||')';
	else
	 lv_string := lv_string || lower(lv_column_name) ||
		     ' ' || lv_data_type;
	end if;
	 if ((lv_data_type = 'CHAR') or (lv_data_type = 'VARCHAR2')) then
	    lv_string := lv_string || '(' || lv_data_length || ')';
	 end if;
	 if (lv_nullable = 'N') then
	    nul_cnt:=nul_cnt+1;
	    lv_string := lv_string || ' constraint ck_'||lv_table_name||'_'||nul_cnt||' NOT NULL';
	 end if;
      write_out(lv_lineno, lv_table_name, lv_string);
      lv_lineno := lv_lineno + 1;
      END LOOP;
      CLOSE col_cursor;
      lv_string := ')';
      write_out(lv_lineno, lv_table_name, lv_string);
      lv_lineno := lv_lineno + 1;
      lv_string := null;
      lv_string := 'PCTFREE ' || to_char(lv_pct_free) ||
		'   PCTUSED ' || to_char(lv_pct_used);
      write_out(lv_lineno,  lv_table_name, lv_string);
      lv_lineno := lv_lineno + 1;
      lv_string := 'INITRANS ' || to_char(lv_ini_trans) ||
		  ' MAXTRANS ' || to_char(lv_max_trans);
      write_out(lv_lineno,  lv_table_name, lv_string);
      lv_lineno := lv_lineno + 1;
      lv_string := 'TABLESPACE ' || lv_tablespace_name;
      write_out(lv_lineno,  lv_table_name, lv_string);
      lv_lineno := lv_lineno + 1;
      lv_string := 'STORAGE (';
      write_out(lv_lineno,  lv_table_name, lv_string);
      lv_lineno := lv_lineno + 1;
      lv_string := 'INITIAL ' || to_char(lv_initial_extent) ||
		     ' NEXT ' || to_char(lv_next_extent);
      write_out(lv_lineno,  lv_table_name, lv_string);
      lv_lineno := lv_lineno + 1;
      lv_string := 'FREELISTS ' || to_char(lv_freelists) ||
		  ' FREELIST GROUPS ' || to_char(lv_freelist_groups);
      write_out(lv_lineno,  lv_table_name, lv_string);
      lv_lineno := lv_lineno + 1;
      lv_string := 'MINEXTENTS ' || to_char(lv_min_extents) ||
		  ' MAXEXTENTS ' || to_char(lv_max_extents) ||
		 ' PCTINCREASE ' || to_char(lv_pct_increase) || ')';
      write_out(lv_lineno,  lv_table_name, lv_string);
      lv_lineno := lv_lineno + 1;
      lv_string := '/';
      write_out(lv_lineno,  lv_table_name, lv_string);
      lv_lineno := lv_lineno + 1;
      lv_string:='                                                  ';
      write_out(lv_lineno,  lv_table_name, lv_string);
   END LOOP;
   CLOSE tab_cursor;
END;
/
 
set heading off
spool rep_out\crt_tabs.sql
 
select   text
from     T_temp
order by  tb_name, lineno;
 
spool off
 
drop table t_temp;
set verify on
rem set feedback on
rem set termout on
set echo on
set pagesize 22


