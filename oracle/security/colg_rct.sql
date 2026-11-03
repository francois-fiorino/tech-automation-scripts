/*
===============================================================================
SCRIPT: colg_rct.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / misc_scripts/COLG_RCT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar grants de coluna e encerrar cliente após spool.

FUNCIONAMENTO DETALHADO
  Consulta COL_PRIVS, monta CONNECT e GRANT privilégio(coluna) ON objeto; mantém EXIT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e privilégios administrativos conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_COL_PRIVS, V$PARAMETER, SQL*Plus EXIT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  EXIT pode confirmar transação. Grants de coluna suportam conjunto específico de privilégios por versão; não são grants de schema/sistema. Não preserva ordem de cadeia por grantor automaticamente e nomes quoted exigem escaping.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente sessão descartável sem transação pendente; revisar saída.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  DDL textual de grants por coluna e finalização do cliente.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: pode gerar ou executar DDL/DML, expor hashes/segredos
  do banco consultado ou alterar sessão conforme descrito acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Sintaxe ON owner.table.column trocada por privilégio(column) ON owner.table; GRANT OPTION e aspas corrigidos; CONNECT sem senha presumida. EXIT e créditos mantidos. 
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
REM COLG_RCT.SQL
REM
REM FUNCTION:   SCRIPT FOR CAPTURING TABLE COLUMN GRANTS
REM
REM This script must be run by a user with the DBA role.
REM
REM This script is intended to run with Oracle7.
REM
REM Running this script will create a script of all the grants 
REM of roles to users and other roles.  This created script, 
REM grt_tabc.sql, must be run by a user with the DBA role.
REM 
REM Since role grants are not dependant on the schema that issued the
REM grant, the grt_role.sql script will not issue the grant of a role by 
REM the original grantor.  All grants will be issued by the user 
REM specified when running this script.
REM 
REM NOTE:  Grants made to 'SYS','CONNECT','RESOURCE','DBA',
REM 		'EXP_FULL_DATABASE','IMP_FULL_DATABASE' are not captured.
REM 
REM        Only preliminary testing of this script was performed.  Be 
REM        sure to test it completely before relying on it.
REM
set verify off feedback off termout off echo off pagesize 0 embedded on
set heading off

set termout on
prompt Creating table grant script...
set termout off
 
break on grantor
column dbname new_value db noprint
select value dbname from v$parameter where name='db_name';
spool rep_out\&db\grt_tabc.sql
 
select 'CONNECT '||grantor line1,
'GRANT '||lower(privilege)||' ('||column_name||') ON '||owner||'.'||table_name||' TO '||lower(grantee)||decode(grantable,'YES',' WITH GRANT OPTION;',';')
 from sys.dba_col_privs
where grantee not in ('SYS','CONNECT','RESOURCE','DBA',
'EXP_FULL_DATABASE','IMP_FULL_DATABASE')
order by grantor,grantee
/
spool off
exit
