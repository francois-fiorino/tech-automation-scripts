/*
===============================================================================
SCRIPT: db_rct.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/DB_RCT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar rascunho de CREATE DATABASE Oracle7 com SYSTEM e redo logs.

FUNCIONAMENTO DETALHADO
  CREATE DB_TEMP, cursores de datafiles SYSTEM e grupos/members redo, INSERT/COMMIT, consulta LOG_ARCHIVE_START, spool e DROP staging.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas conforme limitações individuais.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_DATA_FILES, V$LOG, V$LOGFILE, V$DATABASE, V$PARAMETER, DB_TEMP, DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  REUSE pode sobrescrever banco; não exporta demais tablespaces/arquivos/usuarios/charset/configuração completos. LOG_ARCHIVE_START é obsoleto; ordem de grupos sem ORDER BY pode posicionar vírgula incorreta ao usar MAX(group#). Buffers255 limitam caminhos. DDL/commits confirmam dados.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema descartável; não usar saída para recriar banco real.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  CRT_DB.SQL com CONTROLFILE/DATAFILE REUSE e ARCHIVELOG/NOARCHIVELOG legado.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos de criação, staging, autenticação, sessão
  ou código gerado descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código integral preservado e limitações concretas documentadas; não substitui backup/recovery homologado. 
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
REM FUNCTION: SCRIPT FOR CREATING DB
REM           This script must be run by a user with the DBA role.
REM           This script is intended to run with Oracle7.
REM           Running this script will in turn create a script to 
REM           rebuild the database.  This created 
REM           script, crt_db.sql,  is run by SQLDBA 
REM           Only preliminary testing of this script was performed.  
REM           Be sure to test it completely before relying on it.
REM M. Ault 3/29/96 TRECOM, REVELNET
REM
set verify off feedback off echo off pages 0
set termout on
prompt Creating db build script...
set termout off; 

create table db_temp
     (lineno NUMBER,  text VARCHAR2(255))
/
DECLARE
   CURSOR dbf_cursor IS 
	select  file_name,bytes	
	from  dba_data_files
	where tablespace_name='SYSTEM';
   CURSOR grp_cursor IS
	select group# from v$log; 
   CURSOR mem_cursor (grp_num number) IS
	select   a.member, b.bytes from v$logfile a, v$log b
	where    a.group#=grp_num
	and a.group#=b.group#
	order by member;
   grp_member        	v$logfile.member%TYPE;
    bytes		v$log.bytes%TYPE;
   db_name		varchar2(8);
   db_string            VARCHAR2(255);
   db_lineno           	number := 0;
   thrd			number;
   grp			number;
   filename		dba_data_files.file_name%TYPE;
   sz			number;
   begin_count		number;
   max_group		number;
   procedure write_out(p_line INTEGER, 
		       p_string VARCHAR2) is
   	begin
   	   insert into db_temp (lineno,text) 
		     values (db_lineno,db_string);
	   end;
BEGIN
	select max(group#) into max_group from v$log;
	db_lineno:=db_lineno+1;
   SELECT 'CREATE DATABASE '||name into db_string  
	FROM v$database;
     write_out(db_lineno,db_string);
	db_lineno:=db_lineno+1;
   SELECT 'CONTROLFILE REUSE' into db_string
	FROM dual;
     write_out(db_lineno,db_string);
	db_lineno:=db_lineno+1;
   SELECT 'LOGFILE ' into db_string 
	FROM dual;
     write_out(db_lineno,db_string);
commit;
If grp_cursor%ISOPEN 
then
	close grp_cursor;
	open grp_cursor;
else
	open grp_cursor;
end if;
loop
  	fetch grp_cursor into grp;
	exit when grp_cursor%NOTFOUND;
	db_lineno:=db_lineno+1;
	db_string:= ' GROUP '||grp||' (';
	write_out(db_lineno,db_string);
	if mem_cursor%ISOPEN then
		close mem_cursor;
		open mem_cursor(grp);
	else
	   	OPEN mem_cursor(grp);
	end if;
	db_lineno:=db_lineno+1;
	begin_count:=db_lineno;
	loop
		fetch mem_cursor into grp_member, bytes;
		exit when mem_cursor%NOTFOUND;
		if begin_count=db_lineno then
			db_string:=chr(39)||grp_member||chr(39);
			write_out(db_lineno,db_string);
			db_lineno:=db_lineno+1;
		else
			db_string:=','||chr(39)||grp_member||chr(39);
			write_out(db_lineno,db_string);
			db_lineno:=db_lineno+1;
		end if;
	end loop;
	db_lineno:=db_lineno+1;
	if grp=max_group 
	then
		db_string:=' ) SIZE '||bytes;
		write_out(db_lineno,db_string);
	else
		db_string:=' ) SIZE '||bytes||',';
		write_out(db_lineno,db_string);
	end if;
end loop;
if dbf_cursor%ISOPEN then
	close dbf_cursor;
	open dbf_cursor;
else
	open dbf_cursor;
end if;
begin_count:=db_lineno;
loop
	fetch dbf_cursor into filename, sz;
	exit when dbf_cursor%NOTFOUND;
	if begin_count=db_lineno then
		db_string:='DATAFILE '||chr(39)||filename||chr(39)||' SIZE '||sz||' REUSE';
	else
		db_string:=','||chr(39)||filename||chr(39)||' SIZE '||sz||' REUSE';
	end if;
	db_lineno:=db_lineno+1;
	write_out(db_lineno,db_string);
end loop;
commit;
SELECT decode(value,'TRUE','ARCHIVELOG','FALSE','NOARCHIVELOG')
	into db_string from v$parameter where name='log_archive_start';
	db_lineno:=db_lineno+1;
	write_out(db_lineno,db_string);
SELECT ';' into db_string from  dual;
	db_lineno:=db_lineno+1;
	write_out(db_lineno,db_string);
CLOSE dbf_cursor;
CLOSE mem_cursor;
CLOSE grp_cursor;
commit;
END;
/
column dbname new_value db noprint
select name dbname from v$database;
set heading off pages 0 verify off recsep off
spool rep_out\&db\crt_db.sql
col text format a80 word_wrap
select   text from db_temp order by  lineno;
spool off
set feedback on verify on termout on
drop table db_temp;
prompt Press enter to continue
set verify on feedback on echo on pages 22 termout on
clear columns
