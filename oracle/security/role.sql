/*
===============================================================================
SCRIPT: role.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / _security_scripts/ROLE.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Combinar privilégios de objeto, de sistema e roles concedidos a roles visíveis.

FUNCIONAMENTO DETALHADO
  UNION de ROLE_TAB_PRIVS, ROLE_SYS_PRIVS e ROLE_ROLE_PRIVS, rotulando R_ORD para ordenar categorias; usa N/A para campos sem aplicação.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.ROLE_TAB_PRIVS, SYS.ROLE_SYS_PRIVS, SYS.ROLE_ROLE_PRIVS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Visibilidade das ROLE_* depende da sessão. Não expande recursivamente roles nem calcula privilégios efetivos de usuário. Máscaras curtas podem truncar nomes modernos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @role.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  ROLE, OWNER, TABLE_NAME, PRIVILEGE e ADMIN_OPTION; em privilégios de objeto o último campo representa GRANTABLE.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  START TITEL132 (grafia incorreta e arquivo ausente) trocado por TTITLE; caminho OUTPUT externo substituído por role_rpt.lst. 
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
REM NAME        : ROLE.SQL
REM FUNCTION    : GENERATE ROLES REPORT
REM USE         : manual
REM Limitations : None
REM
set pages 58
column role         format a19 heading 'User or Role'
column admin_option format a3  heading 'Ad?'
column owner        format a7 heading 'Owner'
column table_name   format a26 heading 'Table name'
column privilege    format a21 heading 'Priv, Grant or Role'
column r_ord noprint
break on role
ttitle 'ORACLE ROLES REPORT'
define output = 'role_rpt.lst'
spool &output
select 
  2 r_ord, b.role role, b.owner owner, b.table_name,
  b.privilege privilege, b.grantable admin_option
from 
  sys.role_tab_privs b
union
select 
  1 r_ord, a.role role, 'N/A' owner, 'N/A' table_name, 
  a.privilege privilege, a.admin_option admin_option 
from 
  sys.role_sys_privs a
union
select 
  3 r_ord, c.role role, 'N/A' owner, 'N/A' table_name, 
  c.granted_role privilege, c.admin_option admin_option
from 
   sys.role_role_privs c
order by 
   role,r_ord;
spool off
set flush on term on pagesize 22  linesize 80
clear columns
clear breaks
ttitle off
pause Press enter to continue

