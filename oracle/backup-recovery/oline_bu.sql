/*
===============================================================================
SCRIPT: oline_bu.sql
CATEGORIA: Oracle / backup-recovery
ORIGEM: Oracle Script Collection 2015 / misc_scripts/OLINE_BU.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar exemplo antigo de backup online Unix por tar/compress.

FUNCIONAMENTO DETALHADO
  CREATE BU_TEMP em TEMP, cursores emitem BEGIN/END BACKUP, tar/compress de datafiles/redo/archives e switch; spool e DROP staging, sem executar saída.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas/SO conforme limitações; ler todos
  os nomes e caminhos antes de qualquer teste em ambiente descartável.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLESPACES, DBA_DATA_FILES, V$LOGFILE, V$PARAMETER, V$DATABASE, DUAL, BU_TEMP

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE TABLE em TEMP moderno geralmente falha; DDL confirma transações. Backup online user-managed exige ARCHIVELOG e plano de recovery testado; cópia online de redo não é backup consistente e compress wildcard pode afetar archives em uso. Falha pode deixar BEGIN BACKUP ativo. LINENO se repete entre tablespaces e caminhos não têm quoting.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Revisão somente; não criar BU_TEMP em temporary tablespace real nem executar saída.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  THOT_BU.SQL com DDL administrativo e HOST Unix.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cópia/restauração, DDL, estatísticas ou DML massivo
  conforme acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código/fluxo completo preservados como exemplo não homologado; nenhum backup, compress ou switch executado. 
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
create table bu_temp (line_no number,line_txt varchar2(2000)) tablespace temp; 
set verify off
define dest_dir=&1;
declare

cursor get_tbsp is
select tablespace_name from dba_tablespaces;

cursor bbu_com (tbsp varchar2) is
select 
'alter tablespace '||tablespace_name||' begin backup;'
from dba_tablespaces where tablespace_name=tbsp;

cursor tar_com (tbsp varchar2) is
select
'host /bin/tar cvf - '||file_name||'|compress>&&dest_dir/'||
substr (file_name,instr(file_name,'/',-1,1)+1,length(file_name))||'.Z'
from dba_data_files where tablespace_name=tbsp;

cursor ebu_com (tbsp varchar2) is
select
'alter tablespace '||tablespace_name||' end backup;' from
dba_tablespaces
where tablespace_name=tbsp;

cursor tar_rdo is
select
'host /bin/tar cvf - '||member||'|compress>&&dest_dir/'||
substr (member,instr(member,'/',-1,1)+1,length(member))||'.Z'
from v$logfile order by group#;

tbsp_name varchar2(64);
line_num number:=0;
line_text varchar2(2000);

begin
line_num := line_num+1;
open get_tbsp;
loop
	fetch get_tbsp into tbsp_name;
	exit when get_tbsp%NOTFOUND;
  	open bbu_com (tbsp_name);
  	fetch bbu_com into line_text;
  	insert into bu_temp values (line_num,line_text);
  	close bbu_com;
  	open tar_com (tbsp_name);
  	loop
                fetch tar_com into line_text;
  		exit when tar_com%NOTFOUND;
		line_num:=line_num+1;
		insert into bu_temp values (line_num,line_text);
  	end loop;
	close tar_com;
  open ebu_com(tbsp_name);
  fetch ebu_com into line_text;
  line_num:=line_num+1;
  insert into bu_temp values (line_num,line_text);
  close ebu_com;
end loop;
  close get_tbsp;
  select 'alter system switch logfile;' into line_text from dual;
  line_num:=line_num+1;
  insert into bu_temp values (line_num,line_text);
  open tar_rdo;
  loop
	fetch tar_rdo into line_text;
	exit when tar_rdo%NOTFOUND;
	line_num:=line_num+1;
	insert into bu_temp values (line_num,line_text);
  end loop;
  close tar_rdo;
  select 'host compress '||substr (value,1,instr(value,'/',-1,1))||'*'
  into line_text from v$parameter where name='log_archive_dest';
  line_num:=line_num+1;
  insert into bu_temp values (line_num,line_text);
  select 'host tar cvf - '||substr (value,1,instr(value,'/',-1,1))||'*.Z'||
  '|compress>&&dest_dir/'||
  substr (value,instr(value,'/',-1,1)+1,length(value))||'.Z'
  into line_text from v$parameter where name='log_archive_dest';
  line_num:=line_num+1;
  insert into bu_temp values (line_num,line_text);
end;
/
set verify off feedback off heading off termout off pages 0
set embedded on lines 132
column line_no noprint
column dbname new_value db noprint
select name dbname from v$database;
spool rep_out\&db\thot_bu.sql
select * from bu_temp order by line_no;
spool off
rem uncomment this next line and change
rem directory syntax for UNIX
rem 
rem host  sed '1,$ s/ *$//g' thot_bu.sql>hot_bu.sql
rem
drop table bu_temp;
set verify on feedback on heading on termout on pages 22
set embedded off lines 80
clear columns
undef dest_dir
