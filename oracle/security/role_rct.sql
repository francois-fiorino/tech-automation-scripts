/*
===============================================================================
SCRIPT: role_rct.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / _security_scripts/ROLE_RCT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar recriação de roles e concessões administrativas históricas.

FUNCIONAMENTO DETALHADO
  Consulta ROLES/USER$ para roles sem senha ou IDENTIFIED BY VALUES e ROLE_PRIVS para grants; exclui cinco roles predefinidas.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e privilégios administrativos conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_ROLES, SYS.USER$, SYS.DBA_ROLE_PRIVS, V$DATABASE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Extrai verificadores de senha legados de USER$ e expõe material sensível; layout e sintaxe não são portáveis a releases atuais. Não cobre roles secure application/external/global completamente. Não executar como restauração automática.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Revisão somente; não coletar hashes reais para publicação.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  DDL textual CREATE ROLE e GRANT com admin option.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: pode gerar ou executar DDL/DML, expor hashes/segredos
  do banco consultado ou alterar sessão conforme descrito acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  AND após FROM ROLE_PRIVS corrigido para WHERE; extração de hashes fica restrita a proposta, nunca executada ou acompanhada de valores reais. 
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
REM role_rct.sql
REM
REM FUNCTION: SCRIPT FOR CREATING ROLES
REM
REM This script must be run by a user with the DBA role.
REM
REM This script is intended to run with Oracle7.
REM
REM Running this script will in turn create a script to build all the 
REM roles in the database.  This created file, create_roles.sql, can  
REM be run by any user with the DBA role or with 'CREATE ROLE' system 
REM privilege.
REM
REM Since it is not possible to create a role under a specific schema, it is 
REM essential that the original creator be granted 'ADMIN' option to the role.
REM Therefore, such grants will be made at the end of the create_roles.sql
REM script.  Since it is not possible to distinguish the creator from someone 
REM who was simply granted 'WITH ADMIN OPTION', all grants will be spooled.
REM In addition, the user who creates the role is automatically granted 
REM 'ADMIN' option on the role, therefore, if this script is run a second
REM time, this user will also be granted 'ADMIN' on all the roles.  You must
REM explicitly revoke 'ADMIN OPTION' from this user to prevent this from 
REM happening.
REM
REM NOTE:  This script will not capture the create or grant on the Oracle 
REM predefined roles, CONNECT, RESOURCE, DBA, EXP_FULL_DATABASE, or 
REM IMP_FULL_DATABASE. 
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
select 'Creating role build script...' from dual;
set termout off
 column dbname new_value db noprint
select name dbname from v$database;

spool rep_out\&db\crt_role.sql
 
select 'CREATE ROLE ' || lower(role) || ' NOT IDENTIFIED;'
  from sys.dba_roles
  where role not in ('CONNECT','RESOURCE','DBA', 'EXP_FULL_DATABASE', 
                    'IMP_FULL_DATABASE')
  and password_required='NO'
/
select 'CREATE ROLE ' || lower(role) || ' IDENTIFIED BY VALUES ' ||
       '''' || password || '''' || ';'
  from sys.dba_roles, sys.user$
  where role not in ('CONNECT','RESOURCE','DBA', 'EXP_FULL_DATABASE',
                    'IMP_FULL_DATABASE')
  and password_required='YES' and
     dba_roles.role=user$.name
     and user$.type=0
/
 
select 'GRANT ' || lower(granted_role) || ' TO ' || lower(grantee) ||
       decode(admin_option,'YES',' WITH ADMIN OPTION;',';')
  from sys.dba_role_privs
  where granted_role not in ('CONNECT','RESOURCE','DBA', 'EXP_FULL_DATABASE',
                           'IMP_FULL_DATABASE')
  order by grantee
/
spool off
set verify on
set feedback on
set termout on
set echo on
set pagesize 22
clear columns
