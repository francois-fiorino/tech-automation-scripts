/*
===============================================================================
SCRIPT: db_users.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / misc_scripts/db_users.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar contas, status, perfil, tablespaces e grants diretos de roles.

FUNCIONAMENTO DETALHADO
  Outer join USERS/ROLE_PRIVS por username/grantee; formata datas e exibe default/admin option.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_USERS, SYS.DBA_ROLE_PRIVS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Uma linha por role ou linha com role NULL. Não expande roles aninhadas nem privilégios de sistema/objeto. Coluna INITIAL_RSRC_CONSUMER_GROUP é histórica e exige verificar versão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @db_users.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Conta/status/datas/tablespaces/profile/roles e grupo inicial de recurso.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Outer join preserva contas sem role antes omitidas; OUTPUT local. Chamadas externas title80/title132 substituídos por TTITLE local.
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
REM NAME        : DB_USER.SQL
REM
REM FUNCTION    : GENERATE USER_REPORT
REM Limitations : None
REM
REM Updates     : MRA 6/10/97 added Oracle8 account status
REM               MRA 5/14/99 Added Oracle8i Resource Group
REM
SET PAGESIZE 58  LINESIZE 131 FEEDBACK OFF
rem
COLUMN username                 FORMAT a10 HEADING User
COLUMN account_status           FORMAT a10 HEADING Status
COLUMN default_tablespace       FORMAT a15 HEADING Default
COLUMN temporary_tablespace     FORMAT a15 HEADING Temporary
COLUMN granted_role             FORMAT a21 HEADING Roles
COLUMN default_role             FORMAT a9  HEADING Default?
COLUMN admin_option             FORMAT a7  HEADING Admin?
COLUMN profile                  FORMAT a15 HEADING Profile
COLUMN initial_rsrc_consumer_group FORMAT a10 HEADING 'Resource|Group'
COLUMN lock_date                HEADING 'Date|Locked'
COLUMN expiry_date              HEADING 'Expiry_date'
rem
ttitle 'ORACLE USER REPORT'
define output = db_users.lst
BREAK ON username SKIP 1 ON account_status ON default_tablespace 
ON temporary_tablespace ON profile
SPOOL &output
rem 
SELECT a.username, 
       a.account_status,
       TO_CHAR(a.lock_date,'dd-mon-yyyy hh24:mi') lock_date,
       TO_CHAR(a.expiry_date,'dd-mon-yyyy hh24:mi') expiry_date,
       a.default_tablespace, 
       a.temporary_tablespace, 
       a.profile,
       b.granted_role, 
       b.admin_option, 
       b.default_role,
       a.initial_rsrc_consumer_group
FROM sys.dba_users a, 
     sys.dba_role_privs b
WHERE a.username = b.grantee(+) 
ORDER BY username, 
         default_tablespace, 
         temporary_tablespace, 
         profile, 
         granted_role;
rem
SPOOL OFF
SET TERMOUT ON FLUSH ON FEEDBACK ON VERIFY ON
CLEAR COLUMNS
CLEAR BREAKS
PAUSE Press Enter to continue

