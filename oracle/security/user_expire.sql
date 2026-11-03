/*
===============================================================================
SCRIPT: user_expire.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / misc_scripts/user_expire.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar status de contas, perfis e datas de lock/expiração.

FUNCIONAMENTO DETALHADO
  Consulta DBA_USERS sem filtrar tipo de conta e formata datas para dia.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_USERS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não altera senha/status, não mostra segredo e não determina sozinho autenticação externa ou acessibilidade atual. Hora é omitida intencionalmente e NULL pode ser normal conforme autenticação/perfil.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @user_expire.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Username/tablespaces/profile/status e datas de lock/expiry.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta e crédito de criação preservados. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
REM NAME        : USER_EXPIRE.SQL
REM
REM FUNCTION    : GENERATE USER EXPIRY DATA REPORT
REM Limitations : None
REM
REM Updates     : MRA 5/22/99 Created
REM
COLUMN account_status           FORMAT a15 HEADING Status
COLUMN default_tablespace       FORMAT a14 HEADING Default
COLUMN temporary_tablespace     FORMAT a10 HEADING Temporary
COLUMN username                 FORMAT a12 HEADING User
COLUMN lock_date                FORMAT a11 HEADING 'Date|Locked'
COLUMN expiry_date              FORMAT a11 HEADING 'Expiry|Date'
COLUMN profile                  FORMAT a15 HEADING Profile
SET PAGESIZE 58  LINESIZE 131 FEEDBACK OFF
ttitle 'ORACLE USER EXPIRATION REPORT'
BREAK ON username SKIP 1 ON default_tablespace ON temporary_tablespace ON profile ON account_status
spool user_expire.lst
rem 
SELECT username, 
       default_tablespace, 
       temporary_tablespace, 
       profile,
       account_status,
       TO_CHAR(lock_date,'dd-mon-yyyy') lock_date,
       TO_CHAR(expiry_date,'dd-mon-yyyy') expiry_date
FROM sys.dba_users
ORDER BY username, 
         default_tablespace, 
         temporary_tablespace, 
         profile,
         account_status;
rem
SPOOL OFF
SET TERMOUT ON FLUSH ON FEEDBACK ON VERIFY ON
CLEAR COLUMNS
CLEAR BREAKS
PAUSE Press Enter to continue


