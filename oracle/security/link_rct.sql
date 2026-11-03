/*
===============================================================================
SCRIPT: link_rct.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/LINK_RCT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar DDL histórico de database links a partir de tabelas internas.

FUNCIONAMENTO DETALHADO
  CREATE DL_TEMP; cursor LINK$/USER$ lê dono/nome/usuário/senha/host e compõe CREATE LINK e CONNECT por dono; spool e DROP staging.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e privilégios administrativos conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.LINK$, SYS.USER$, V$PARAMETER, DL_TEMP

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DDL/staging confirma transações. Layout PASSWORD de LINK$ é Oracle7, incompatível com criptografia moderna; valor pode não ser senha utilizável. .WORLD é removido e LOWER altera identificadores. Saída contém segredo e não deve ser versionada.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Revisão somente; não executar contra credenciais reais nem divulgar sua saída.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Rascunho CRT_DBLS.SQL que pode conter material de autenticação extraído.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: pode gerar ou executar DDL/DML, expor hashes/segredos
  do banco consultado ou alterar sessão conforme descrito acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  CONNECT gerado deixou de presumir senha igual ao usuário (agora solicita autenticação); senha remota deixa de ser convertida para minúsculas. Fluxo de extração preservado somente para revisão restrita. 
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
REM link_rct.sql
REM
REM    comment: SCRIPT FOR RE-CREATING DATABASE LINKS
REM
REM              This script must be run by 'SYS'.  
REM 
REM              This script is intended to run with Oracle7.
REM
REM Running this script will in turn create a script to build all the 
REM database links in the database.  This created script is called 
REM 'crt_dbls.sql'.
REM 
REM Since a DBA cannot create a private database link on behalf of a user,
REM this script will contain various connect clauses before each create 
REM statement.  In order for the database links to be created under
REM the correct schema, it must connect as that individual.  Therefore, 
REM before executing the script, you must add each user's password to the 
REM connect clause.  Duplicate connect clauses can be eliminated being 
REM sure that the database link is being created under the correct schema.  
REM
REM The PUBLIC database links will require a connect as 'SYS'.  However, this 
REM username can be changed to any user with the DBA role or with the 
REM 'CREATE PUBLIC DATABASE LINK' system privilege.
REM
REM The spooled output is ordered by the database link owner, a PUBLIC database 
REM link has 'PUBLIC' as it's owner.
REM
REM Only preliminary testing of this script was performed.  Be sure to test 
REM it completely before relying on it.  
REM
 
set verify off
set feedback off
set termout off
set echo off
set pagesize 0
 
set termout on
select 'Creating database link build script...' from dual;
set termout off
 
create table dl_temp (lineno NUMBER, grantor_owner varchar2(20),
text VARCHAR(255));
 
DECLARE
   CURSOR link_cursor IS select   u.name,
                                  l.name, 
                                  l.userid, 
                                  l.password, 
                                  l.host
                         from     sys.link$ l, sys.user$ u
                         where    l.owner# = u.user#
                         order by l.name;
   lv_owner    sys.user$.name%TYPE;
   lv_db_link  sys.link$.name%TYPE;
   lv_username sys.link$.userid%TYPE;
   lv_password sys.link$.password%TYPE;
   lv_host     sys.link$.host%TYPE;
   lv_string     VARCHAR2(255);
   lv_user       VARCHAR2(255);
   lv_connect    VARCHAR2(255);
   lv_text       VARCHAR2(500);
 
   procedure write_out(p_string VARCHAR2) is
   begin
      insert into dl_temp (grantor_owner,text) 
                        values (lv_owner,p_string);
   end;
 
BEGIN
   OPEN link_cursor;
   LOOP
      FETCH link_cursor INTO lv_owner,
                             lv_db_link,
                             lv_username,
                             lv_password,
                             lv_host;
      EXIT WHEN link_cursor%NOTFOUND;
if (lv_owner = 'PUBLIC') then
      lv_string := ('CREATE PUBLIC DATABASE LINK '||
                lower(replace(lv_db_link,'.WORLD','')));
else
      lv_string := ('CREATE DATABASE LINK '||
                lower(replace(lv_db_link,'.WORLD','')));
end if;
      if (lv_username is not null) then
         lv_user := ('CONNECT TO '||lower(lv_username)||
                   ' IDENTIFIED BY '||lv_password);
      end if;
      if (lv_host is not null) then
         lv_connect := ('USING '''||lv_host||''''||';');
      end if;
   lv_text := lv_string || ' ' || lv_user || ' ' || lv_connect;
   write_out(lv_text);
   lv_user := ' ';
   lv_connect := ' ';
   END LOOP;
   CLOSE link_cursor;
END;
/
 column dbname new_value db noprint
select value dbname from v$parameter where name='db_name';
spool rep_out\&db\crt_dbls.sql
break on downer skip 1
col text format a60 word_wrap
 
select   'connect ' || decode (grantor_owner, 'PUBLIC', 'SYS', grantor_owner) 
 downer,'
'||rtrim(text)
from     dl_temp 
order by downer 
/
spool off
 set verify on
set feedback on
set termout on
set echo on
set pagesize 22
clear columns
drop table dl_temp;
 
