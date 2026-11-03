/*
===============================================================================
SCRIPT: profile.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/PROFILE.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir limites dos perfis cadastrados no banco.

FUNCIONAMENTO DETALHADO
  Consulta DBA_PROFILES com PROFILE, RESOURCE_NAME e LIMIT, agrupando visualmente por PROFILE; gera relatório local e restaura parte da apresentação.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_PROFILES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não mostra associação a usuários nem RESOURCE_TYPE; recursos homônimos podem exigir contexto. Não exibe hashes ou senhas. TERMOUT OFF oculta execução enquanto produz spool.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @profile.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Nome do perfil, recurso e limite textual, incluindo DEFAULT e UNLIMITED quando aplicável.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  DEFINE OUTPUT com caminho externo substituído por nome local independente de DB. Wrappers title80/title132 ausentes substituídos por TTITLE local. Relatório gravado em profiles.lst local; pode substituir arquivo anterior.
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
REM NAME        : PROFILE.SQL
REM
REM FUNCTION    : GENERATE USER PROFILES REPORT
REM
REM USE         : CALLED BY PROFILE_REPORT.COM
REM
set flush off term off pagesize 58 linesize 78
column profile        	format A20  	heading Profile
column resource_name              		heading 'Resource:'
column limit          	format A15  	heading Limit
break on profile
ttitle 'ORACLE PROFILES REPORT'
define output = profiles.lst
spool &output
select profile, resource_name, limit  from sys.dba_profiles
order by profile;
spool off
set flush on term on pagesize 22 linesize 80
clear columns
clear breaks
pause Press enter to continue
