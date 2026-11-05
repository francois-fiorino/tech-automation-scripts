/*
===============================================================================
SCRIPT: unix_oline_bu.sql
CATEGORIA: Oracle / backup-recovery
ORIGEM: Oracle Script Collection 2015 / misc_scripts/unix_oline_bu.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar script Unix de backup online por tar/compress, archives e controlfile.

FUNCIONAMENTO DETALHADO
  CREATE/TRUNCATE BU_TEMP; gera BEGIN/END BACKUP e blocos HOST com tar/pipe/compress, switch/archive/controlfile; spool e DROP staging.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas/SO conforme limitações; ler todos
  os nomes e caminhos antes de qualquer teste em ambiente descartável.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLESPACES, DBA_DATA_FILES, V$LOGFILE, V$PARAMETER, V$DATABASE, BU_TEMP, DUAL, DEST_DIR

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Tar cvrf em stream e HOST interativo/EXIT precisam testes; wildcard compress afeta archives de origem. Não há cleanup garantido de BEGIN BACKUP e backup online exige ARCHIVELOG/recuperação homologada. Syntax control file e paths sem quotes são incompletos; cópia redo online não é garantia. DDL confirma transações.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente revisão em laboratório Unix, sem iniciar backup real.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  THOT_BU.SQL com comandos SQL/shell e nomes de arquivos datados.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cópia/restauração, DDL, estatísticas ou DML massivo
  conforme acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Gerador completo e créditos preservados; não trocado por pipeline simplificado ou executado. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 044 — 04/11/2026
  Correções e melhorias: Interrupção SQL antes de CREATE/TRUNCATE BU_TEMP; gerador completo mantido.
  Limitações e pendências: tar cvrf emstream, HOSTinterativo/exit, wildcardcompress, cópiaredo e controlfile semaspas continuam não homologados. Não filtra tablespacetemp e falhas podem manter backupmode.
  Homologação necessária: Staging existente, múltiplos arquivos, pathscomespaços e erro de pipeline; apenas simular saída, sem Shell ou backup.
  Parâmetros/execução: contratos descritos acima e no corpo; somente laboratório.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  submissão de jobs, backup/recovery, Shell/Windows/VMS ou coleta de credenciais.

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
REM Script to create a hot backup script on UNIX
REM Created 6/23/98 MRA
REM
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
create table bu_temp (line_no number,line_txt varchar2(2000))
storage (initial 1m next 1m pctincrease 0);
truncate table bu_temp;
set verify off embedded off
define dest_dir=&1;
declare
--
-- Declare cursors
--
-- Cursor to get all tablespace names
--
cursor get_tbsp is
select tablespace_name from dba_tablespaces;
--
-- cursor to create BEGIN BACKUP command
--
cursor bbu_com (tbsp varchar2) is
select 
'alter tablespace '||tablespace_name||' begin backup;'
from dba_tablespaces where tablespace_name=tbsp;
--
-- Cursor to create HOST backup commands
--
cursor tar1_com (tbsp varchar2) is
select '/bin/tar cvf - '||file_name||' \'
from dba_data_files where tablespace_name=tbsp 
and file_id=(select min(file_id)from dba_data_files 
where tablespace_name=tbsp);
--
cursor tar2_com (tbsp varchar2) is
select
file_name||' \'
from dba_data_files where tablespace_name=tbsp
and file_id>(select min(file_id) from dba_data_files 
where tablespace_name=tbsp);
--
cursor tar3_com (tbsp varchar2) is
select '/bin/tar cvrf - '||file_name||' \'
from dba_data_files where tablespace_name=tbsp 
and file_id=(select min(file_id)from dba_data_files 
where tablespace_name=tbsp);
--
cursor comp_com (tbsp varchar2) is
select
'|compress>&&dest_dir/'||tablespace_name||'_'||to_char(sysdate,'dd_mon_yy')||'.Z'||chr(10)||'exit'
from dba_tablespaces where tablespace_name=tbsp;

--
-- Cursor to create END BACKUP command
--
cursor ebu_com (tbsp varchar2) is
select
'alter tablespace '||tablespace_name||' end backup;' from
dba_tablespaces
where tablespace_name=tbsp;
--
-- Cursor to create redo log HOST backup commands
--
cursor tar1_rdo is
select '/bin/tar cvf -  \'
from dual;
--
cursor tar2_rdo is
select
member||' \'
from v$logfile;
--
cursor comp_rdo is
select
'|compress>&&dest_dir/redo_logs_'||to_char(sysdate,'dd_mon_yy')||'.Z'||chr(10)||'exit'
from dual;
--
-- Temporary variable declarations
--
tbsp_name varchar2(64);
line_num number:=0;
line_text varchar2(2000);
min_value number;
first_tbsp boolean;
--
-- Begin build of commands into temporary table
--
begin
--
-- first, create script header
--
line_num := line_num+1;
select 'REM Online Backup Script for '||name||' instance' 
into line_text from v$database;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
select 'REM Script uses UNIX tar format backup commands'  
into line_text from dual;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
select 'REM created on '||to_char(sysdate, 'dd-mon-yyyy hh24:mi')||' by user '||user  
into line_text from dual;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
select 'REM developed for Burleson Consulting - DMR Consulting Group 7-Oct-2011'  
into line_text from dual;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
select 'REM Script expects to be fed backup directory location on execution.'  
into line_text from dual;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
select 'REM Script should be re-run anytime physical structure of database altered.'  
into line_text from dual;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
select 'REM '  
into line_text from dual;
insert into bu_temp values (line_num,line_text);
line_num := line_num+1;
--
-- Now get tablespace names and loop through until all are handled
--
open get_tbsp;
first_tbsp:=TRUE;
loop
-- 
-- Get name
--
	fetch get_tbsp into tbsp_name;
	exit when get_tbsp%NOTFOUND;
--
-- Add comments to script showing which tablespace
--
	select 'REM' into line_text from dual;
  	insert into bu_temp values (line_num,line_text);
	line_num:=line_num+1;
	select 'REM Backup for tablespace '||tbsp_name into line_text from dual;
  	insert into bu_temp values (line_num,line_text);
	line_num:=line_num+1;
	select 'REM' into line_text from dual;
  	insert into bu_temp values (line_num,line_text);
	line_num:=line_num+1;
--
-- Get begin backup command built for this tablespace
--
  	open bbu_com (tbsp_name);
  	fetch bbu_com into line_text;
  	insert into bu_temp values (line_num,line_text);
	line_num:=line_num+1;
  	close bbu_com;
--
-- The actual backup commands are per datafile, open cursor and loop
--
  	open tar1_com (tbsp_name);
	open tar2_com (tbsp_name);
open tar3_com (tbsp_name);
	open comp_com (tbsp_name);
	min_value:=line_num;
  	loop
		if line_num=min_value
		then
				select 'host' into line_text from dual;
				insert into bu_temp values (line_num,line_text);
				line_num:=line_num+1;
			if first_tbsp THEN
                  fetch tar1_com into line_text;
                else
                  fetch tar3_com into line_text;
                end if;
		else
			fetch tar2_com into line_text;
  				exit when tar2_com%NOTFOUND;
		end if;
		insert into bu_temp values (line_num,line_text);
		line_num:=line_num+1;
           first_tbsp:=FALSE;
  	end loop;
	fetch comp_com into line_text;
	insert into bu_temp values (line_num,line_text);
    line_num:=line_num+1;
	close tar1_com;
	close tar2_com;
close tar3_com;
	close comp_com;
--
-- Build end backup command for this tablespace
--
  open ebu_com(tbsp_name);
  fetch ebu_com into line_text;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  close ebu_com;
end loop;
  close get_tbsp;
--
-- Backup redo logs, normally you won't recover redo logs you
-- will use your current redo logs so current SCN information not lost
-- commands just here for completeness
--
  select 'REM' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'REM Backup for redo logs' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'REM Normally you will not recover redo logs' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'REM' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
--
-- Create host backup commands for all redo logs
--
  open tar1_rdo;
  open tar2_rdo;
  open comp_rdo;
  min_value:=line_num;
  loop
	if line_num=min_value 
	then
	 select 'host' into line_text from dual;
	 insert into bu_temp values (line_num,line_text);
	 line_num:=line_num+1;
	 fetch tar1_rdo into line_text;
	else
	 fetch tar2_rdo into line_text;
	 exit when tar2_rdo%NOTFOUND;
	end if;
	insert into bu_temp values (line_num,line_text);
  	line_num:=line_num+1;
  end loop;
  fetch comp_rdo into line_text;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  close tar1_rdo;
  close tar2_rdo;
  close comp_rdo;
--
-- Now get all archive logs, performing a switch to be sure all
-- required archives are written out
--
  select 'REM' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'REM Backup for archive logs' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'REM' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'alter system switch logfile;' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'archive log all;' into line_text from dual;
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
--
-- The next command builds the actual backup command based on the 
-- value of the log_archive_dest initialization parameter, it looks for the
-- last right square bracket in the name and just uses that section with
-- a wildcard
--
  select 'host compress '||substr (value,1,instr(value,'/',-1,1))||'*'
  into line_text from v$parameter where name='log_archive_dest';
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
  select 'host tar cvf - '||substr (value,1,instr(value,'/',-1,1))||'*.Z'||
  '|compress>&&dest_dir/'||
  substr (value,instr(value,'/',-1,1)+1,length(value))||'_'||to_char(sysdate,'dd_mon_yy')||'.Z'
  into line_text from v$parameter where name='log_archive_dest';
  insert into bu_temp values (line_num,line_text);
  line_num:=line_num+1;
--
-- Next, backup a control file just to be sure
-- we have a good one available that is current with this backup
-- 
   select 'alter database backup control file to '||'&&dest_dir'||'/ora_conbackup_'||to_char(sysdate,'dd_mon_yy')||'.bac;'  
   into line_text from dual;
   insert into bu_temp values (line_num,line_text);
   line_num:=line_num+1;
end;
/
rem
rem Now generate output based on bu_temp table contents
rem
set verify off feedback off heading off termout off pages 0
set embedded on lines 132
column line_no noprint
column dbname new_value db noprint
select name dbname from v$database;
spool rep_out\&db\thot_bu.sql
select * from bu_temp order by line_no;
spool off
rem directory syntax for UNIX
rem 
rem host  sed '1,$ s/ *$//g' thot_bu.sql>hot_bu.sql
rem
drop table bu_temp;
set verify on feedback on heading on termout on pages 22
set embedded off lines 80
clear columns
undef dest_dir

