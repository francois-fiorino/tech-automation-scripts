/*
===============================================================================
SCRIPT: sys_grnt.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / _security_scripts/SYS_GRNT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Preservar variante comentada de gerador de privilégios de sistema por grantee.

FUNCIONAMENTO DETALHADO
  Só prompt/settings estão ativos; SELECT de DBA_SYS_PRIVS com filtro de grantee permanece comentado.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e privilégios administrativos conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_SYS_PRIVS e V$DATABASE no bloco comentado

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Comentário histórico fala em roles, mas SELECT comentado consulta privilégios de sistema. Ativação requer revisão de destinatário/admin option/escopo e versão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Inspeção somente; não gera arquivo de grants no estado publicado.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Prompt de intenção e settings, sem DDL executada ou gerada ativamente.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: pode gerar ou executar DDL/DML, expor hashes/segredos
  do banco consultado ou alterar sessão conforme descrito acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Estado desativado preservado e finalidade real do SQL comentado documentada. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 039 — 04/11/2026
  Correções e melhorias: Trecho DBA_SYS_PRIVS permanece comentado.
  Limitações e pendências: Nome histórico menciona roles, mas consulta privilégios de sistema. Macro GRANTEE não é validada no trecho inativo; não ativar sem revisão.
  Homologação necessária: Verificar ausência de arquivo gerado; revisar destinatário/admin option antes de qualquer reativação.
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
REM FUNCTION:   SCRIPT FOR CAPTURING ROLE SYSTEM GRANTS
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
set pagesize 0 embedded on


prompt Creating role sys grant script...

/*
column dbname new_value db noprint
select name dbname from v$database;
spool rep_out\&db\grt_sys.sql
 
select 'GRANT ' || lower(privilege) || ' TO ' || lower(grantee) ||
       decode(admin_option,'YES',' WITH ADMIN OPTION;',';')
  from sys.dba_sys_privs
  where grantee not in ('SYS','CONNECT','RESOURCE','DBA', 
	'EXP_FULL_DATABASE','IMP_FULL_DATABASE')  
        and grantee = upper('&grantee') 	  
order by grantee
/

*/
spool off
clear columns
set verify on feedback on termout on  pagesize 22 embedded off
