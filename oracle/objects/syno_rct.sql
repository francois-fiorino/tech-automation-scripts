/*
===============================================================================
SCRIPT: syno_rct.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/SYNO_RCT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar CREATE SYNONYM privado/público a partir do catálogo.

FUNCIONAMENTO DETALHADO
  Consulta DBA_SYNONYMS excluindo targets SYS, compõe nome qualificado/DB link e spool.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e privilégios administrativos conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_SYNONYMS, V$DATABASE, DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não exporta synonyms de targets SYS, editionable/common flags ou grants. LOWER/nomes sem quoting podem alterar objetos com case misto. Não verifica existência/conectividade de targets e não é backup completo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Revisar nomes/targets/acesso da saída antes de executar manualmente.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  CRT_SYNS.SQL com DDL textual, sem criação automática.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: pode gerar ou executar DDL/DML, expor hashes/segredos
  do banco consultado ou alterar sessão conforme descrito acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código e exclusões preservados. 
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
REM FUNCTION: SCRIPT FOR CREATING SYNONYMS
REM
REM           This script must be run by a user with the DBA role.
REM
REM           This script is intended to run with Oracle7.
REM
REM           Running this script will in turn create a script to build 
REM           all the synonyms in the database. The created script, 
REM           create_synonyms.sql, can be run by any user with the DBA 
REM           role or with the 'CREATE ANY SYNONYM' and 'CREATE PUBLIC 
REM           SYNONYM' system privileges.
REM 
REM NOTE:    This script does not capture synonyms created on tables owned 
REM          by the 'SYS' user.
REM
REM          Only preliminary testing of this script was performed.  Be 
REM          sure to test it completely before relying on it.
REM
 
set verify off
set feedback off
set termout off
set echo off
set pagesize 0 lines 132
 
set termout on
select 'Creating synonym build script...' from dual;
set termout off
column dbname new_value db noprint
select name dbname from v$database; 
define cr='chr(10)' 
spool rep_out\&db\crt_syns.sql
 
select 'CREATE '|| decode(owner,'PUBLIC','PUBLIC ',null) || 
       'SYNONYM ' || decode(owner,'PUBLIC',null, owner || '.') || 
        lower(synonym_name) || ' FOR ' || lower(table_owner) ||
        '.' || lower(table_name) || 
        decode(db_link,null,null,'@'||db_link) || ';'
  from sys.dba_synonyms
  where table_owner != 'SYS'
  order by owner
/
spool off
set verify on
set feedback on
set termout on
set echo on
set pagesize 22
clear columns
undef cr
