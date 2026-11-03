/*
===============================================================================
SCRIPT: resource_plan.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/resource_plan.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar subplanos associados a planos do Resource Manager.

FUNCIONAMENTO DETALHADO
  Une planos a directives SUBPLAN e LEFT JOIN ao plano referenciado para mostrar seus métodos/flags.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_RSRC_PLANS, DBA_RSRC_PLAN_DIRECTIVES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Colunas CPU_METHOD/MANDATORY são legadas e exigem validar versão. Não ativa plano ou mostra alocações efetivas. Somente directives SUBPLAN, não consumer groups.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @resource_plan.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Plano/método/mandatory e subplano/tipo/método/mandatory referenciado.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Produto cartesiano do alias C e autoassociação incorreta removidos por joins explícitos ao subplano; campos preservados. Chamadas externas title80/title132 substituídos por TTITLE local.
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
REM NAME        : RESOURCE_PLAN.SQL
REM comment: GENERATE DATABASE RESOURCE PLAN REPORT

REM
COLUMN plan                FORMAT a10      HEADING 'Plan|Name'
COLUMN cpu_method1         FORMAT a30      HEADING 'CPU|Method'
COLUMN mandatory1          FORMAT a4       HEADING 'Man?'
COLUMN num_plan_directives FORMAT 9999     HEADING 'Num|Directives'
COLUMN group_or_subplan    FORMAT a12      HEADING 'Group or|Subplan Name'
COLUMN type                FORMAT a8       HEADING 'Group or|Subplan'
COLUMN cpu_method2         FORMAT a30      HEADING 'CPU|Method'
COLUMN mandatory2          FORMAT a4       HEADING 'Man?'
REM
SET PAGES 78 VERIFY OFF FEEDBACK OFF
BREAK ON plan on cpu_method1 on mandatory1 on num_plan_directives
ttitle 'Resource Plan Report'
SPOOL resource_plan.lis
REM
SELECT
      a.plan,
      a.cpu_method cpu_method1,
      a.mandatory mandatory1,
      b.group_or_subplan,
      b.type,
      c.cpu_method cpu_method2,
      c.mandatory mandatory2
FROM dba_rsrc_plans a
JOIN dba_rsrc_plan_directives b ON a.plan=b.plan AND b.type='SUBPLAN'
LEFT JOIN dba_rsrc_plans c ON c.plan=b.group_or_subplan
ORDER BY
     a.plan;
SPOOL OFF
CLEAR COLUMNS
SET VERIFY ON FEEDBACK ON
TTITLE OFF

