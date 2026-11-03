/*
===============================================================================
SCRIPT: display_users.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/display_users.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar usuários com grants diretos de DBA/RESOURCE e seus perfis.

FUNCIONAMENTO DETALHADO
  Une DBA_USERS e DBA_ROLE_PRIVS por usuário/grantee, filtra duas roles e mostra admin/default.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_USERS, SYS.DBA_ROLE_PRIVS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não expande roles aninhadas nem detecta toda capacidade administrativa ou SYSDBA. Ausência de grant direto não implica ausência de privilégio efetivo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @display_users.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  USERNAME, PROFILE, GRANTED_ROLE, ADMIN_OPTION e DEFAULT_ROLE.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta preservada; OUTPUT externo substituído por display_users.lst. Wrappers title80/title132 ausentes substituídos por TTITLE local.
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

-- comment:  DBA user report
column username                 format a15 heading User
column granted_role             format a20 heading Roles
column default_role             format a9  heading Default?
column admin_option             format a7  heading Admin?
column profile                  format a15 heading 'Users Profile'
rem
set pages 55 lines 132
ttitle 'ORACLE DBA/RESOURCE REPORT'
define output = display_users.lst
break on username on profile
spool &output
select username, profile,
granted_role, admin_option, default_role
from sys.dba_users a, sys.dba_role_privs b
where a.username = b.grantee
and granted_role in ('DBA','RESOURCE')
order by username,
profile, granted_role
/
spool off
set pages 22 lines 80
ttitle off
clear columns
