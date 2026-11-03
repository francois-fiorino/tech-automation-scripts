/*
===============================================================================
SCRIPT: sys_roles.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / _security_scripts/SYS_ROLES.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar concessões de privilégios de sistema por grantee.

FUNCIONAMENTO DETALHADO
  Consulta DBA_SYS_PRIVS para GRANTEE, PRIVILEGE e ADMIN_OPTION, ordenando por grantee e privilégio; preserva créditos de Mike Ault.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_SYS_PRIVS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não expande roles ou privilégios de objeto; conferir container, visibilidade e grants comuns/locais na versão multitenant.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @sys_roles.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Uma linha por concessão de privilégio de sistema. Não são listadas concessões de roles apesar do título histórico.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  GROUP BY apenas GRANTEE era inválido para as outras colunas; substituído por ORDER BY GRANTEE, PRIVILEGE. OUTPUT passa a sys_roles.lst local. Wrappers title80/title132 ausentes substituídos por TTITLE local.
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
REM NAME        : sys_role.SQL
REM PURPOSE     : GENERATE SYSTEM GRANTS and ROLES REPORT
REM USE         : CALLED BY SQLPLUS
REM Limitations : None
REM Revisions   :
REM Date           Modified by  Reason for change
REM 08-Apr-1993    MIKE AULT     INITIAL CREATE
REM 10-Jun-1997    Mike Ault     Update to Oracle8
REM 15-May-1999    Mike Ault     No changes for Oracle8i
REM
SET FLUSH OFF TERM OFF PAGESIZE 58  LINESIZE 78
COLUMN grantee           HEADING 'User or Role'
COLUMN admin_option      HEADING Admin?
ttitle 'SYSTEM GRANTS AND ROLES REPORT'
DEFINE output = sys_roles.lst
SPOOL &output
SELECT 
     grantee, 
     privilege, 
     admin_option 
FROM 
     sys.dba_sys_privs
ORDER BY 
     grantee, privilege;
SPOOL OFF
CLEAR COLUMNS
SET TERM ON FLUSH ON
TTITLE OFF

