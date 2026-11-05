/*
===============================================================================
SCRIPT: tab_grnt.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / _security_scripts/TAB_GRNT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar grants de objetos com reconexão por grantor.

FUNCIONAMENTO DETALHADO
  Consulta DBA_TAB_PRIVS excluindo lista de destinatários e compõe CONNECT e GRANT por objeto.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e privilégios administrativos conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_TAB_PRIVS, V$PARAMETER

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não inclui privilégios de coluna ou sistema e ordem não garante dependência de grants em cadeia. Nomes sem quoting e multitenant exigem revisão; saída sensível a política de acesso.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Revisar gerador/saída em laboratório; não aplicar grants automaticamente.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Arquivo GR TABS com privilégios/grant option e conexão sem senha embutida.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: pode gerar ou executar DDL/DML, expor hashes/segredos
  do banco consultado ou alterar sessão conforme descrito acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Aspas tipográficas normalizadas; WITH ADMIN OPTION de objeto corrigido para WITH GRANT OPTION e senha presumida igual ao grantor removida. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 039 — 04/11/2026
  Correções e melhorias: Corpo preservado; sem senha embutida.
  Limitações e pendências: Ordenação por CONNECT/grantee não resolve dependências transitivas. SQL*Plus quebra/formatos e nomes sem quoting podem invalidar saída; grants de coluna ausentes.
  Homologação necessária: Grants encadeados, PUBLIC, nomes mixed case e largura/spool; não aplicar automaticamente.
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
REM FUNCTION:   SCRIPT FOR CAPTURING TABLE GRANTS
REM
REM This script must be run by a user with the DBA role.
REM
REM This script is intended to run with Oracle7.
REM
REM Running this script will create a script of all the grants 
REM of roles to users and other roles.  This created script, 
REM grt_sys.sql, must be run by a user with the DBA role.
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
 
break on line1
column dbname new_value db noprint
select value dbname from v$parameter where name='db_name';
spool rep_out\&db\grt_tabs.sql
 define cr='chr(10)';
select 'CONNECT '||grantor||'' line1,
'GRANT'||&&cr||
lower(privilege)||' on '||owner||'.'||table_name||' to '|| lower(grantee) ||&&cr||
decode(grantable,'YES',' WITH GRANT OPTION;',';')
from sys.dba_tab_privs
where grantee not in ('SYS','CONNECT','RESOURCE','DBA',
'EXP_FULL_DATABASE','IMP_FULL_DATABASE')
order by line1,grantee
/

spool off
set verify on feedback on termout on echo on pagesize 22 embedded off
set heading on
clear columns
clear breaks
