/*
===============================================================================
SCRIPT: rct_usrs.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / misc_scripts/RCT_USRS.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar CREATE USER e quotas de tabela de usuários em catálogo legado.

FUNCIONAMENTO DETALHADO
  UNION de CREATE USER com hash de DBA_USERS e ALTER USER QUOTA, excluindo SYS/SYSTEM.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e privilégios administrativos conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_USERS (PASSWORD legado), DBA_TS_QUOTAS, V$DATABASE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  PASSWORD legado não exporta autenticação moderna nem todos os atributos de conta. Saída sensível; não publicar hashes. CREATE inclui quota ilimitada no default e ordenação textual não garante CREATE antes de ALTER em todo nome. Não é restauração completa de contas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Não executar contra hashes reais; revisar apenas em laboratório isolado.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  DDL textual com verificadores de senha e quotas.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: pode gerar ou executar DDL/DML, expor hashes/segredos
  do banco consultado ou alterar sessão conforme descrito acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Quota ALTER passou de BYTES usado para MAX_BYTES autorizado, tratando -1 como UNLIMITED; CREATE/UNION/ordem histórica preservados com ressalvas. 
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
REM rct_usrs.sql
REM
REM FUNCTION: Create a script to recreate users
REM
REM This script is designed to run on an ORACLE database
REM
REM This script creates a script called crt_usrs.sql that 
REM recreates the CREATE USER commands required to rebuild the database
REM user community. The script includes the tablespace quota grants for REM each user as a set of ALTER USER commands. The user’s passwords are
REM initially set to the username so editing is suggested if other 
REM values are desired.
REM
REM Only preliminary testing has been accomplished on this script, 
REM please fully qualify it for your environment before use
REM
REM M. Ault Burleson Consulting 8.23.01
REM
set verify off feedback off termout off echo off pagesize 0 embedded on
set heading off
set termout on
prompt Creating user create script...
set termout off
rem
rem FUNCTION: Create a use recreate script
rem
column dbname new_value db noprint
select name dbname from v$database;
define cr='chr(10)'
spool rep_out\&db\crt_usrs.sql

SELECT 'create user '||username||' identified by values '||chr(39)||password||chr(39)||&&cr||
' default tablespace '||default_tablespace||&&cr||
' temporary tablespace '||temporary_tablespace||&&cr||
' profile '||profile||&&cr||
' quota unlimited on '||default_tablespace||';'||&&cr x
FROM dba_users
WHERE username not in ('SYS','SYSTEM')
UNION
SELECT 'alter user '||username||&&cr||
'quota '||decode(max_bytes,-1,'unlimited',to_char(max_bytes))||' on '||tablespace_name||';'||&&cr x
FROM dba_ts_quotas
WHERE username not in ('SYS','SYSTEM')
order by x desc
/
spool off
set verify on feedback on termout on pagesize 22 embedded off
set heading on
clear columns
undef cr
