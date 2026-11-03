/*
===============================================================================
SCRIPT: user.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / misc_scripts/user.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar contas e suas roles diretas em formato legado.

FUNCIONAMENTO DETALHADO
  Outer join USERS/ROLE_PRIVS por username/grantee e ordenação por conta e role.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_USERS, SYS.DBA_ROLE_PRIVS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Uma linha por role, com NULL para conta sem role. Não expande roles aninhadas nem calcula privilégio efetivo. Não inclui status/expiração da variante DB_USERS.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @user.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Username/tablespaces/profile e roles/default/admin option.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Outer join evita omitir contas sem role e OUTPUT local. USER7/USER2 são variantes de apresentação desta consulta. Chamadas externas title80/title132 substituídos por TTITLE local.
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
REM NAME        : USER.SQL
REM FUNCTION    : GENERATE USER_REPORT
REM USE         : General
REM Limitations : None
REM
set pagesize 40  linesize 131
rem
column username                 format a10 heading User
column default_tablespace       format a20 heading "Default Tablespace"
column temporary_tablespace     format a20 heading "Temporary Tablespace"
column granted_role             format a20 heading Roles
column default_role             format a9  heading Default?
column admin_option             format a7  heading Admin?
column profile                  format a15 heading 'Users Profile'
rem
ttitle 'ORACLE USER REPORT'
define output = user.lst
break on username skip 1 on default_tablespace on temporary_tablespace on profile
spool &output
rem 
select username, default_tablespace, temporary_tablespace, profile,
granted_role, admin_option, default_role 
from sys.dba_users a, sys.dba_role_privs b
where a.username = b.grantee(+) 
order by username, default_tablespace, temporary_tablespace, 
profile, granted_role;
rem
spool off
set termout on flush on feedback on verify on
clear columns
clear breaks
ttitle off
pause Press enter to continue
