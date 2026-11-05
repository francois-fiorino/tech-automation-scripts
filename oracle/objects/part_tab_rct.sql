/*
===============================================================================
SCRIPT: part_tab_rct.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/part_tab_rct.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar DROP/CREATE de tabela particionada de nome informado usando modelo range/hash.

FUNCIONAMENTO DETALHADO
  CREATE T_TEMP e LINENO_SEQ; múltiplos cursores de colunas/chaves/partições/subpartições geram storage/high values e spool; DROP staging.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas conforme limitações individuais.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_PART_TABLES, DBA_TAB_COLUMNS, DBA_PART_KEY_COLUMNS, DBA_SUBPART_KEY_COLUMNS, DBA_TAB_PARTITIONS, DBA_TAB_SUBPARTITIONS, T_TEMP, LINENO_SEQ

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Cursores filtram nome sem owner e podem misturar schemas. Sempre gera PARTITION BY RANGE/SUBPARTITION BY HASH mesmo havendo tipos modernos diferentes; não preserva defaults/constraints/LOBs/state. CLOSE condicionais são inconsistentes e ramo de uma partição pode deixar cursor aberto. DDL/REUSE do staging confirmam transações.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente clone isolado e nome sem homônimos em outros schemas; revisar saída integral.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  CREATE_PART_TABLE.SQL com definição de tabela e subpartições.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos de criação, staging, autenticação, sessão
  ou código gerado descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Algoritmo completo de mais de 20 KB preservado para revisão; não resumido ou substituído por DBMS_METADATA simplificado. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 040 — 04/11/2026
  Correções e melhorias: Algoritmo integral preservado com defeitos individuais registrados.
  Limitações e pendências: Cursores sem owner misturam schemas; CLOSE SUBPART_KEY somente no ramo múltiplo, CLOSE SUBPART_TBSP mesmo quando não aberto e PART_CURSOR aberto no ramo único. RANGE/HASH imposto ignora tipo real; sem tablespace/logging de partição, nomes/defaults/LOBs incompletos.
  Homologação necessária: Uma e várias partições/subchaves, contagem zero/um de subpartições, homônimos e LIST/HASH; confrontar cada DDL ao catálogo e impedir uso como backup.
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
REM part_tab_rct.sql
REM
REM FUNCTION: SCRIPT FOR CREATING PARTITIONED TABLES
REM
REM           This script can be run by any user .
REM
REM           This script is intended to run with Oracle8i.
REM
REM           Running this script will in turn create a script to 
REM           build all the partitioned tables owned by the user in the database.  
REM           This created script, create_part_table.sql, can be run by any user 
REM           with the 'CREATE TABLE' system privilege. 
REM
REM NOTE:     The script will NOT include constraints on tables.  This 
REM           script will also NOT capture tables created by user 'SYS'.
REM
REM Only preliminary testing of this script was performed.  Be sure to test
REM it completely before relying on it.
REM
 
set verify off
set feedback off
set echo off;
set pagesize 0 lines 132 embedded on
 
set termout on
select 'Creating table build script...' from dual;

 
create table t_temp
     (lineno NUMBER, tb_owner VARCHAR2(30), tb_name VARCHAR2(30),
      text VARCHAR2(2000))
/
drop sequence lineno_seq;
create sequence lineno_seq start with 1 increment by 1 nocache nocycle;

DECLARE
   CURSOR tab_cursor(tab_name VARCHAR2) IS select   table_name,
                                 PARTITIONING_TYPE,              
                                 SUBPARTITIONING_TYPE,           
                                 PARTITION_COUNT,                
                                 DEF_SUBPARTITION_COUNT,         
                                 PARTITIONING_KEY_COUNT,         
                                 SUBPARTITIONING_KEY_COUNT,      
                                 DEF_PCT_FREE,                   
                                 DEF_PCT_USED,                   
                                 DEF_INI_TRANS,                  
                                 DEF_MAX_TRANS,                  
                                 DEF_TABLESPACE_NAME,
                                 DEF_INITIAL_EXTENT,             
                                 DEF_NEXT_EXTENT,                
                                 DEF_MIN_EXTENTS,                
                                 DEF_MAX_EXTENTS,                
                                 DEF_PCT_INCREASE,               
                                 DEF_FREELISTS,                  
                                 DEF_FREELIST_GROUPS,            
                                 DEF_LOGGING,                    
                                 DEF_BUFFER_POOL                
			from     dba_part_tables
			where  table_name=upper(tab_name);
--
   CURSOR col_cursor (c_tab VARCHAR2) IS select   
						  column_name,
						  data_type,
						  data_length,
						  data_precision,
						  data_scale,
						  nullable
					 from     dba_tab_columns
					 where    table_name = c_tab
					order by column_id;
--
   CURSOR  part_key (c_tab VARCHAR2) is select 	column_name,
							column_position
					  from dba_part_key_columns
                                          where trim(name)=c_tab
                                          and trim(object_type)='TABLE'
                                          order by column_position;
--
   CURSOR  part_cursor (c_tab VARCHAR2) IS select 	PARTITION_NAME,         
							SUBPARTITION_COUNT,
							HIGH_VALUE,             
							HIGH_VALUE_LENGTH,      
							PARTITION_POSITION,
							TABLESPACE_NAME,        
							PCT_FREE,               
							PCT_USED,               
							INI_TRANS,              
							MAX_TRANS,              
							MIN_EXTENT,             
							MAX_EXTENT,             
							FREELISTS,              
							FREELIST_GROUPS,        
							LOGGING,                         
							BUFFER_POOL                       
					from dba_tab_partitions
                                        where table_name=c_tab
                                        order by partition_position;
--
   CURSOR subpart_key (c_tab VARCHAR2) IS select 	column_name,
							column_position
					  from dba_subpart_key_columns
                                          where trim(name)=c_tab
                                          and trim(object_type)='TABLE'
                                          order by column_position;
--
   CURSOR subpart_tbsp (c_tab VARCHAR2) IS select unique tablespace_name
					   from dba_tab_subpartitions
                                           where table_name=c_tab;
--
   CURSOR subpart_cursor (c_tab VARCHAR2, tab_part VARCHAR2) IS select 
								SUBPARTITION_NAME,
								tablespace_name
 					from dba_tab_subpartitions
                                        where table_name=c_tab 
                                        and partition_name=tab_part
                                        order by subpartition_position;
--
   CURSOR subpart_stor (c_tab varchar2, tab_part varchar2) IS select
								initial_extent,
								next_extent,
								pct_increase
 					from dba_tab_subpartitions
                                        where table_name=c_tab 
                                        and partition_name=tab_part
                                        and subpartition_position=1;
--
   lv_table_name		dba_part_tables.table_name%TYPE;
   lv_partitioning_type		dba_part_tables.partitioning_type%TYPE;
   lv_subpartitioning_type 	dba_part_tables.subpartitioning_type%TYPE;
   lv_partition_count		dba_part_tables.partition_count%TYPE;
   lv_subpartition_count 	dba_part_tables.def_subpartition_count%TYPE;
   lv_partition_key_count	dba_part_tables.partitioning_key_count%TYPE;
   lv_subpartition_key_count	dba_part_tables.subpartitioning_key_count%TYPE;
   lv_pct_free			dba_part_tables.def_pct_free%TYPE;
   lv_pct_used			dba_part_tables.def_pct_used%TYPE;
   lv_ini_trans			dba_part_tables.def_ini_trans%TYPE;
   lv_max_trans			dba_part_tables.def_max_trans%TYPE;
   lv_tablespace_name		dba_part_tables.def_tablespace_name%TYPE;
   lv_initial_extent		dba_part_tables.def_initial_extent%TYPE;
   lv_next_extent		dba_part_tables.def_next_extent%TYPE;
   lv_min_extents		dba_part_tables.def_min_extents%TYPE;
   lv_max_extents		dba_part_tables.def_max_extents%TYPE;
   lv_pct_increase		dba_part_tables.def_pct_increase%TYPE;
   lv_logging			dba_part_tables.def_logging%TYPE;
   lv_buffer_pool		dba_part_tables.def_buffer_pool%TYPE;
   lv_column_name		dba_tab_columns.column_name%TYPE;
   lv_data_type			dba_tab_columns.data_type%TYPE;
   lv_data_length		dba_tab_columns.data_length%TYPE;
   lv_data_precision		dba_tab_columns.data_precision%TYPE;
   lv_data_scale		dba_tab_columns.data_scale%TYPE;
   lv_nullable			dba_tab_columns.nullable%TYPE;
   lv_freelists			dba_part_tables.def_freelists%TYPE;
   lv_freelist_groups 		dba_part_tables.def_freelist_groups%TYPE;
   lv_pkey_column_name		dba_part_key_columns.column_name%TYPE;
   lv_pkey_column_number	dba_part_key_columns.column_position%TYPE;
   lv_spkey_column_name		dba_subpart_key_columns.column_name%TYPE;
   lv_spkey_column_number	dba_subpart_key_columns.column_position%TYPE;
   lv_part_COMPOSITE		dba_tab_partitions.composite%TYPE;              
   lv_PARTITION_NAME		dba_tab_partitions.partition_name%TYPE;
   lv_part_SUBPARTITION_COUNT	dba_tab_partitions.subpartition_count%TYPE;
   lv_HIGH_VALUE		dba_tab_partitions.high_value%TYPE;
   lv_HIGH_VALUE_LENGTH		dba_tab_partitions.high_value_length%TYPE;
   lv_PARTITION_POSITION	dba_tab_partitions.partition_position%TYPE;
   lv_part_TABLESPACE_NAME     	dba_tab_partitions.tablespace_name%TYPE;
   lv_part_PCT_FREE            	dba_tab_partitions.pct_free%TYPE;
   lv_part_PCT_USED            	dba_tab_partitions.pct_used%TYPE;
   lv_part_INI_TRANS           	dba_tab_partitions.ini_trans%TYPE;
   lv_part_MAX_TRANS           	dba_tab_partitions.max_trans%TYPE;
   lv_part_INITIAL_EXTENT      	dba_tab_partitions.initial_extent%TYPE;
   lv_part_NEXT_EXTENT         	dba_tab_partitions.next_extent%TYPE;
   lv_part_MIN_EXTENT          	dba_tab_partitions.min_extent%TYPE;
   lv_part_MAX_EXTENT          	dba_tab_partitions.max_extent%TYPE;
   lv_part_PCT_INCREASE        	dba_tab_partitions.pct_increase%TYPE;
   lv_part_FREELISTS           	dba_tab_partitions.freelists%TYPE;
   lv_part_FREELIST_GROUPS     	dba_tab_partitions.freelist_groups%TYPE;
   lv_part_LOGGING    		dba_tab_partitions.logging%TYPE;
   lv_part_BUFFER_POOL        	dba_tab_partitions.buffer_pool%TYPE;
   lv_SUBPARTITION_NAME     	dba_tab_subpartitions.SUBPARTITION_NAME%TYPE;
   lv_spart_TABLESPACE_NAME	dba_tab_subpartitions.TABLESPACE_NAME%TYPE;
   lv_subpartition_position	dba_tab_subpartitions.subpartition_position%TYPE;
   lv_subp_initial_extent	dba_tab_subpartitions.initial_extent%TYPE;
   lv_subp_next_extent		dba_tab_subpartitions.next_extent%TYPE;
   lv_subp_pct_increase		dba_tab_subpartitions.pct_increase%TYPE;
   lv_first_rec         BOOLEAN;
   lv_string            VARCHAR2(2000);
   tbsp_string		VARCHAR2(2000);
   tmp_string		VARCHAR2(2000);
   nul_cnt	   	number;
   sp_cnt		number;
   flg			VARCHAR2(32);
   fl			VARCHAR2(32);
   minex		VARCHAR2(32);
   maxex		VARCHAR2(32);
--
   procedure write_out(p_name VARCHAR2,
		       p_string VARCHAR2) is
   begin
      insert into t_temp (lineno, tb_name, text)
	     values (lineno_seq.nextval,p_name,rtrim(p_string,chr(32)));
   end;
-- 
BEGIN
   OPEN tab_cursor('&tab_name');
   LOOP
      FETCH tab_cursor INTO     lv_table_name,
				lv_partitioning_type,
   				lv_subpartitioning_type,
   				lv_partition_count,
   				lv_subpartition_count,
   				lv_partition_key_count,
   				lv_subpartition_key_count,
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
				lv_freelist_groups,
   				lv_logging,
  				lv_buffer_pool;
      EXIT WHEN tab_cursor%NOTFOUND;
	lv_string := 'DROP TABLE '|| lower(lv_table_name)||';';
	write_out(lv_table_name, lv_string);
	lv_first_rec := TRUE;
	lv_string := 'CREATE TABLE '|| lower(lv_table_name)||' (';
	write_out(lv_table_name, lv_string);
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
      write_out(lv_table_name, lv_string);
      END LOOP;
      CLOSE col_cursor;
      lv_string := ')';
      write_out(lv_table_name, lv_string);
      lv_string := NULL; 
      nul_cnt:=0;
--
      OPEN part_key(lv_table_name);
      IF lv_partition_key_count>1 THEN
       LOOP
        FETCH part_key INTO lv_pkey_column_name,lv_pkey_column_number;
        exit when part_key%NOTFOUND;
        if nul_cnt=0 THEN
           tmp_string:=lv_pkey_column_name;
           nul_cnt:=nul_cnt+1;
        else 
           tmp_string:=tmp_string||','||lv_pkey_column_name;
           nul_cnt:=nul_cnt+1;
           dbms_output.put_line(tmp_string);
        end if;
       END LOOP;
      end if;  
      if lv_partition_key_count=1 THEN
       FETCH part_key INTO lv_pkey_column_name,lv_pkey_column_number;
       tmp_string:=lv_pkey_column_name;
      end if;
      CLOSE part_key;
--
      lv_string:='PARTITION BY RANGE ('||tmp_string||')';
      write_out(lv_table_name, lv_string);
      lv_string := NULL;
      tmp_string:=NULL;
--
      if lv_subpartition_key_count>0 THEN
       OPEN subpart_key(lv_table_name);
       if lv_subpartition_key_count=1 THEN
        FETCH subpart_key INTO lv_spkey_column_name,lv_spkey_column_number;
        tmp_string:=lv_spkey_column_name;
       else
        nul_cnt:=0;
        LOOP
         FETCH subpart_key INTO lv_spkey_column_name,lv_spkey_column_number;
         exit when subpart_key%NOTFOUND;
         if nul_cnt=0 THEN
           tmp_string:=lv_spkey_column_name;
           nul_cnt:=nul_cnt+1;
           dbms_output.put_line(tmp_string);
         else 
           tmp_string:=tmp_string||','||lv_spkey_column_name;
           nul_cnt:=nul_cnt+1;
         end if;  
        END LOOP;
       CLOSE subpart_key;
       end if;
--  
       if lv_subpartition_count>1 then
        OPEN subpart_tbsp(lv_table_name);
        nul_cnt:=0;
        LOOP
         FETCH subpart_tbsp INTO lv_spart_tablespace_name;
         exit when subpart_tbsp%NOTFOUND;
         dbms_output.put_line(lv_spart_tablespace_name);
         if nul_cnt=0 then
          tbsp_string:=lv_spart_tablespace_name;
          nul_cnt:=nul_cnt+1;
         else
          tbsp_string:=tbsp_string||','||lv_spart_tablespace_name;
          nul_cnt:=nul_cnt+1;
         end if;
        END LOOP;
       end if;
       CLOSE subpart_tbsp;
--
       lv_string := 'SUBPARTITION BY HASH ('||tmp_string||')';
       write_out(lv_table_name, lv_string);
       lv_string := 'SUBPARTITIONS '||to_char(lv_subpartition_count);
       write_out(lv_table_name, lv_string);
       lv_string := 'STORE IN ('||tbsp_string||')';
       write_out(lv_table_name, lv_string);
       lv_string := null;
      end if;
--
      OPEN part_cursor(lv_table_name);
      if lv_partition_count=1 THEN
      FETCH part_cursor INTO    lv_PARTITION_NAME,
				lv_part_SUBPARTITION_COUNT,
				lv_HIGH_VALUE,
				lv_HIGH_VALUE_LENGTH,
				lv_PARTITION_POSITION,
				lv_part_TABLESPACE_NAME,
				lv_part_PCT_FREE,
				lv_part_PCT_USED,
				lv_part_INI_TRANS,
				lv_part_MAX_TRANS,
				lv_part_MIN_EXTENT,
				lv_part_MAX_EXTENT,
				lv_part_FREELISTS,
				lv_part_FREELIST_GROUPS,
				lv_part_LOGGING,
				lv_part_BUFFER_POOL;
      OPEN subpart_stor(lv_table_name,lv_partition_name);
      FETCH subpart_stor into lv_part_initial_extent,lv_part_next_extent,lv_part_pct_increase;
      CLOSE subpart_stor;
      SELECT decode(lv_part_freelist_groups,null,null,' FREELIST GROUPS '||to_char(lv_part_freelist_groups)||chr(10)),
             decode(lv_part_freelists,null,null,' FREELISTS '||to_char(lv_part_freelists)||chr(10)),
             decode(lv_part_min_extent,null,null,' MINEXTENTS '||to_char(lv_part_min_extent)||chr(10)),
             decode(lv_part_max_extent,null,null,' MAXEXTENTS '||to_char(lv_part_max_extent)||chr(10))
     INTO flg,fl,minex,maxex FROM DUAL;
      lv_string:='(PARTITION '||lv_partition_name||' VALUES LESS THAN ('||lv_high_value||')';
                  write_out(lv_table_name, lv_string);
      lv_string:='PCTFREE '||to_char(lv_part_pct_free);
                  write_out(lv_table_name, lv_string);
      lv_string:='PCTUSED '||to_char(lv_part_pct_used);
                  write_out(lv_table_name, lv_string);
      lv_string:='INITRANS '||to_char(lv_part_ini_trans);
                  write_out(lv_table_name, lv_string);
      lv_string:='MAXTRANS '||to_char(lv_part_max_trans);
                  write_out(lv_table_name, lv_string);
      lv_string:='STORAGE ( INITIAL '||to_char(lv_part_initial_extent)||
                 ' NEXT '||to_char(lv_part_next_extent);
                  write_out(lv_table_name, lv_string);
      lv_string:=' PCTINCREASE '||to_char(lv_part_pct_increase);
                  write_out(lv_table_name, lv_string);
      lv_string:=fl||flg||minex||maxex;
      if lv_string is not null then
                  write_out(lv_table_name, lv_string);
      end if;
      lv_string:=' BUFFER_POOL '||lv_part_buffer_pool||')';
           write_out(lv_table_name, lv_string);
      lv_string := null;
      ELSE
       nul_cnt:=0;
       LOOP
        FETCH part_cursor INTO  lv_PARTITION_NAME,
				lv_part_SUBPARTITION_COUNT,
				lv_HIGH_VALUE,
				lv_HIGH_VALUE_LENGTH,
				lv_PARTITION_POSITION,
				lv_part_TABLESPACE_NAME,
				lv_part_PCT_FREE,
				lv_part_PCT_USED,
				lv_part_INI_TRANS,
				lv_part_MAX_TRANS,
				lv_part_MIN_EXTENT,
				lv_part_MAX_EXTENT,
				lv_part_FREELISTS,
				lv_part_FREELIST_GROUPS,
				lv_part_LOGGING,
				lv_part_BUFFER_POOL;
        exit when part_cursor%NOTFOUND;
        OPEN subpart_stor(lv_table_name,lv_partition_name);
        FETCH subpart_stor into lv_part_initial_extent,lv_part_next_extent,lv_part_pct_increase;
        CLOSE subpart_stor;
        SELECT decode(lv_part_freelist_groups,null,null,' FREELIST GROUPS '||to_char(lv_part_freelist_groups)),
             decode(lv_part_freelists,null,null,' FREELISTS '||to_char(lv_part_freelists)),
             decode(lv_part_min_extent,null,null,' MINEXTENTS '||to_char(lv_part_min_extent)),
             decode(lv_part_max_extent,null,null,' MAXEXTENTS '||to_char(lv_part_max_extent))
        INTO flg,fl,minex,maxex FROM DUAL;
      lv_string:='PARTITION '||lv_partition_name||' VALUES LESS THAN ('||lv_high_value||')';
        if nul_cnt=0 then 
         lv_string:='('||lv_string;
        else 
         lv_string:=','||lv_string;
        end if;
        write_out(lv_table_name, lv_string);
      lv_string:='PCTFREE '||to_char(lv_part_pct_free);
                  write_out(lv_table_name, lv_string);
      lv_string:='PCTUSED '||to_char(lv_part_pct_used);
                  write_out(lv_table_name, lv_string);
      lv_string:='INITRANS '||to_char(lv_part_ini_trans);
                  write_out(lv_table_name, lv_string);
      lv_string:='MAXTRANS '||to_char(lv_part_max_trans);
                  write_out(lv_table_name, lv_string);
      lv_string:='STORAGE ( INITIAL '||to_char(lv_part_initial_extent)||
                 ' NEXT '||to_char(lv_part_next_extent);
                  write_out(lv_table_name, lv_string);
      lv_string:=' PCTINCREASE '||to_char(lv_part_pct_increase);
                  write_out(lv_table_name, lv_string);
      lv_string:=fl||flg||minex||maxex;
      if lv_string is not null then
                  write_out(lv_table_name, lv_string);
      end if;
      lv_string:=' BUFFER_POOL '||lv_part_buffer_pool||')';
           write_out(lv_table_name, lv_string);
      lv_string := null;        
        nul_cnt:=nul_cnt+1;
--
        if lv_part_subpartition_count>0 THEN
         OPEN subpart_cursor(lv_table_name,lv_partition_name);
         sp_cnt:=0;
         LOOP
          FETCH subpart_cursor INTO    	lv_SUBPARTITION_NAME,
					lv_spart_TABLESPACE_NAME;
          exit when subpart_cursor%NOTFOUND;
          if sp_cnt=0 THEN
           lv_string:='(SUBPARTITION '||lv_subpartition_name||
          ' TABLESPACE '||lv_spart_tablespace_name;
           write_out(lv_table_name, lv_string);
           else
           lv_string:=',SUBPARTITION '||lv_subpartition_name||
          ' TABLESPACE '||lv_spart_tablespace_name;
           write_out(lv_table_name, lv_string);
          end if;
          sp_cnt:=sp_cnt+1;
         END LOOP;
        lv_string:=')';      
        write_out(lv_table_name, lv_string);
        lv_string := null;
        close subpart_cursor;
        end if;  
       END LOOP;
       close part_cursor;
      end if;
--
      lv_string := ')'||chr(10)||'/';
      write_out(lv_table_name, lv_string);
      lv_string:='                                                  ';
      write_out(lv_table_name, lv_string);
   END LOOP;
   CLOSE tab_cursor;
END;
/
 
set heading off trimspool on
spool create_part_table.sql
 
select   text
from     T_temp
order by  tb_name, lineno;
 
spool off
 
drop table t_temp;
set verify on
set feedback on
set termout on
set pagesize 22 lines 80


