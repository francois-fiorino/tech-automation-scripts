/*
===============================================================================
SCRIPT: plan_directives.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/plan_directives.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar directives de planos para grupos e subplanos com níveis de CPU.

FUNCIONAMENTO DETALHADO
  Junta PLAN a directives e LEFT JOINs condicionais TYPE ao subplano/grupo para metadados.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_RSRC_PLANS, DBA_RSRC_PLAN_DIRECTIVES, DBA_RSRC_CONSUMER_GROUPS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Views/colunas de Resource Manager legado exigem verificação da versão. Não mede cota efetiva ou CPU real; não é SQL Plan Directive do otimizador.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @plan_directives.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Plano/destino/tipo, métodos/flags e CPU_P1..P8/limite paralelo.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Join OR com produto cartesiano substituído por joins condicionais; metadados do grupo passam a vir de D quando TYPE=CONSUMER_GROUP, preservando colunas. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
REM NAME        : PLAN_DIRECTIVE.SQL
REM PURPOSE     : GENERATE DATABASE RESOURCE PLAN DIRECTIVES REPORT
REM Revisions:
REM Date          Modified by     Reason for change
REM 15-May-1999     MIKE AULT     initial creation
REM
REM NAME        : RESOURCE_PLAN.SQL
REM PURPOSE     : GENERATE DATABASE RESOURCE PLAN REPORT
REM Revisions:
REM Date          Modified by     Reason for change
REM 15-May-1999     MIKE AULT     initial creation
REM
COLUMN plan                     FORMAT a12     HEADING 'Plan|Name'
COLUMN cpu_method1              FORMAT a8     HEADING 'CPU|Method'
COLUMN mandatory1               FORMAT a4      HEADING 'Man?'
COLUMN num_plan_directives      FORMAT 9999    HEADING 'Num|Directives'
COLUMN group_or_subplan         FORMAT a15     HEADING 'Group or|Subplan Name'
COLUMN type                     FORMAT a8      HEADING 'Group or|Subplan'
COLUMN cpu_method2              FORMAT a8      HEADING 'CPU|Method'
COLUMN mandatory2               FORMAT a4      HEADING 'Man?'
COLUMN cpu_p1                   FORMAT 99999   HEADING 'CPU1%'
COLUMN cpu_p2                   FORMAT 99999   HEADING 'CPU2%'
COLUMN cpu_p3                   FORMAT 99999   HEADING 'CPU3%'
COLUMN cpu_p4                   FORMAT 99999   HEADING 'CPU4%'
COLUMN cpu_p5                   FORMAT 99999   HEADING 'CPU5%'
COLUMN cpu_p6                   FORMAT 99999   HEADING 'CPU6%'
COLUMN cpu_p7                   FORMAT 99999   HEADING 'CPU7%'
COLUMN cpu_p8                   FORMAT 99999   HEADING 'CPU8%'
COLUMN parallel_degree_limit_p1 FORMAT 999999  HEADING 'Par|Degree'
REM
SET LINES 130 VERIFY OFF FEEDBACK OFF
BREAK ON plan on cpu_method1 on mandatory1 on num_plan_directives
ttitle 'Resource Plan Directives Report'
spool plan_directives.lst
REM
SELECT DISTINCT
      a.plan,
      a.cpu_method cpu_method1,
      a.mandatory mandatory1,
      b.group_or_subplan,
      DECODE(b.type,'CONSUMER_GROUP','GROUP',b.type) type,
      case when b.type='CONSUMER_GROUP' then d.cpu_method else c.cpu_method end cpu_method2,
      case when b.type='CONSUMER_GROUP' then d.mandatory else c.mandatory end mandatory2,
      b.cpu_p1,b.cpu_p2,b.cpu_p3,b.cpu_p4,
      b.cpu_p5,b.cpu_p6,b.cpu_p7,b.cpu_p8,
      parallel_degree_limit_p1
FROM dba_rsrc_plans a
JOIN dba_rsrc_plan_directives b ON a.plan=b.plan
LEFT JOIN dba_rsrc_plans c ON b.type='SUBPLAN' AND b.group_or_subplan=c.plan
LEFT JOIN dba_rsrc_consumer_groups d ON b.type='CONSUMER_GROUP' AND b.group_or_subplan=d.consumer_group
ORDER BY
     1,4,5;
SPOOL OFF
CLEAR COLUMNS
SET VERIFY ON FEEDBACK ON
TTITLE OFF

