/*
===============================================================================
SCRIPT: sys_gran.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / _security_scripts/SYS_GRAN.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Preservar gerador histórico de grants de sistema atualmente desativado por comentário.

FUNCIONAMENTO DETALHADO
  Comandos ativos só configuram cliente e consultam nome do banco; bloco SPOOL/SELECT GRANT está dentro de comentário de bloco histórico.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e privilégios administrativos conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$DATABASE, DUAL; SYS.DBA_SYS_PRIVS no trecho comentado

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não reativar bloco sem revisão. Se habilitado, gera privilégios/admin option amplos e exclui cinco roles; não é inventário de todos os grants. Não confundir comentário com implementação executada.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente inspeção; @sys_gran.sql não gera grants enquanto trecho permanecer comentado.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Mensagem/configuração de cliente; sem script de grants funcional no estado original.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: pode gerar ou executar DDL/DML, expor hashes/segredos
  do banco consultado ou alterar sessão conforme descrito acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Comentário de desativação integral preservado, sem ativar funcionalidade administrativa silenciosamente. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 039 — 04/11/2026
  Correções e melhorias: Trecho gerador comentado preservado, sem reativação.
  Limitações e pendências: SPOOL OFF ativo pode fechar spool do chamador; não gera grants no estado atual. Lista exclui roles predefinidas e não representa inventário completo.
  Homologação necessária: Inspecionar comentário e estado do cliente em sessão isolada.
  Parâmetros/execução: manter contrato descrito acima e no corpo histórico.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação realizada: leitura integral e comparação estática; sem compilação
  ou execução Oracle, sem execução de comandos administrativos.

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
REM FUNCTION:  SCRIPT FOR CAPTURING SYSTEM PRIVILEGE GRANTS
REM
REM FUNCTION: This script must be run by a user with the DBA role.
REM
REM This script is intended to run with Oracle7.
REM
REM FUNCTION: Running this script will in turn create a script of all the system
REM FUNCTION: privilege grants to users and roles.  This created script, 
REM FUNCTION: grant_sys_privs.sql must be run by a user with the DBA role or 
REM FUNCTION: with the 'GRANT ANY PRIVILEGE' system privilege. 
REM 
REM NOTE:  This script will not capture grants made to the Oracle
REM predefined roles, CONNECT, RESOURCE, DBA, EXP_FULL_DATABASE, or
REM IMP_FULL_DATABASE.
REM
REM Since system grants are not dependant on the schema that issued the grant,
REM the grant_sys_privs.sql script will not issue the grant of a role by the
REM original grantor.  All grants will be issued by the user specified when
REM running this script.
REM
REM Only preliminary testing of this script was performed.  Be sure to test
REM it completely before relying on it.
REM
column dbname new_value db noprint;
select name dbname from v$database;

set verify off
set feedback off
set termout off
set echo off;
set pagesize 0
 
set termout on
select 'Creating system privilege grant script...' from dual;
set termout off
/*
spool rep_out\&db\grt_sysp.sql
 
select 'GRANT ' || rpad(lower(privilege),30) || ' TO ' || lower(grantee) ||
       decode(admin_option,'YES',' WITH ADMIN OPTION;',';')
  from sys.dba_sys_privs
  where grantee not in ('CONNECT','RESOURCE','DBA',
                       'EXP_FULL_DATABASE','IMP_FULL_DATABASE')
order by grantee
/

*/
spool off
set verify on
set feedback on
set termout on
set echo on
set pagesize 22
clear columns
