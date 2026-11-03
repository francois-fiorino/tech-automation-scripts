/*
===============================================================================
SCRIPT: plan_group_grants.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / _security_scripts/plan_group_grants.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar privilégios de troca para grupos consumidores do Resource Manager.

FUNCIONAMENTO DETALHADO
  Consulta DBA_RSRC_CONSUMER_GROUP_PRIVS, seleciona GRANTED_GROUP, GRANTEE, GRANT_OPTION e INITIAL_GROUP e ordena por grupo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_RSRC_CONSUMER_GROUP_PRIVS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  INITIAL_GROUP e políticas do Resource Manager são sensíveis à versão; conferir existência da coluna. Concessão não comprova plano ativo nem mapeamento efetivo da sessão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @plan_group_grants.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Grupo consumidor, usuário/role, possibilidade de conceder e indicador histórico de grupo inicial.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
REM NAME        : PLAN_GROUP_GRANTS.SQL
REM PURPOSE     : GENERATE DATABASE RESOURCE PLAN GROUP GRANTS REPORT
REM Revisions:
REM Date          Modified by     Reason for change
REM 15-May-1999     MIKE AULT     initial creation
REM
COLUMN granted_group   FORMAT a30    HEADING 'Granted Group'
COLUMN grantee         FORMAT a30    HEADING 'User or Role'
COLUMN grant_option    FORMAT a7     HEADING 'Admin?'
COLUMN initial_group   FORMAT a8     HEADING 'Initial?'
BREAK ON granted_group
SET LINES 78 VERIFY OFF FEEDBACK OFF
ttitle 'Resource Plan Group Grants'
spool plan_group_grants.lst
REM
SELECT 
     Granted_group, grantee, grant_option, initial_group
FROM
    Dba_rsrc_consumer_group_privs
ORDER BY
    Granted_group;
SPOOL OFF
SET VERIFY ON FEEDBACK ON
TTITLE OFF

