/*
===============================================================================
SCRIPT: rgnt_rct.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / misc_scripts/RGNT_RCT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar concessões de roles a usuários/roles excluindo SYS.

FUNCIONAMENTO DETALHADO
  Consulta DBA_ROLE_PRIVS, compõe GRANT e WITH ADMIN OPTION quando presente.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e privilégios administrativos conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_ROLE_PRIVS, V$DATABASE, DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não exporta default roles, common/local/inherited flags ou todas as propriedades modernas. Admin option permite delegação; ordem por grantee não garante resolver dependências de criação. Não executa grants aqui.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente revisão de destinatários e privilégios antes de usar saída.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  GR_ROLE.SQL com grants de roles.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: pode gerar ou executar DDL/DML, expor hashes/segredos
  do banco consultado ou alterar sessão conforme descrito acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código completo preservado. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 042 — 04/11/2026
  Correções e melhorias: Nomes de roles e grantees agora citados/escapados; PUBLIC tratado como palavra-chave.
  Limitações e pendências: Não inclui default/common/inherited/estado de roles; ordem não cria dependências. Saída deve ter largura cliente adequada e DEFINE OFF para nomes com ampersand; não executa GRANT.
  Homologação necessária: Role mixed case, aspas, ampersand, PUBLIC e ADMIN OPTION; comparar cada comando sem conceder acesso.
  Parâmetros e execução: contratos descritos acima e no corpo histórico.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  backup/recovery, comandos Windows/Unix ou uso de credenciais reais.

AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de qualquer utilização em produção. Sua execução é de responsabilidade do profissional responsável pelo ambiente. Os mantenedores deste repositório não se responsabilizam por indisponibilidade, perda de dados, alterações indevidas ou outros impactos decorrentes de sua utilização.

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
REM FUNCTION:   SCRIPT FOR CAPTURING ROLE GRANTS
REM
REM This script must be run by a user with the DBA role.
REM
REM This script is intended to run with Oracle7.
REM
REM Running this script will create a script of all the grants 
REM of roles to users and other roles.  This created script, 
REM grant_roles.sql, must be run by a user with the DBA role.
REM 
REM Since role grants are not dependant on the schema that issued the grant, 
REM the grant_roles.sql script will not issue the grant of a role by the 
REM original grantor.  All grants will be issued by the user specified when 
REM running this script.
REM 
REM NOTE:  Grants made to 'SYS' are not captured.
REM 
REM        Only preliminary testing of this script was performed.  Be 
REM        sure to test it completely before relying on it.
REM
 column dbname new_value db noprint
select name dbname from v$database;
set verify off
set feedback off
set termout off
set echo off;
set pagesize 0
 
set termout on
select 'Creating role grant script...' from dual;
set termout off
 
spool rep_out\&db\grt_role.sql
 
select 'GRANT ' || '"'||replace(granted_role,'"','""')||'"' || ' TO ' || case when grantee='PUBLIC' then 'PUBLIC' else '"'||replace(grantee,'"','""')||'"' end ||
       decode(admin_option,'YES',' WITH ADMIN OPTION;',';')
  from sys.dba_role_privs
  where grantee != 'SYS'
order by grantee
/
 
spool off
set verify on
set feedback on
set termout on
set echo on
set pagesize 22
clear columns
