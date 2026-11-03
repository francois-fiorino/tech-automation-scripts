/*
===============================================================================
SCRIPT: plan_directive.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/plan_directive.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar directives de subplanos com níveis de CPU e limite paralelo.

FUNCIONAMENTO DETALHADO
  Une planos/directives SUBPLAN e metadados do plano referenciado por joins explícitos.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_RSRC_PLANS, DBA_RSRC_PLAN_DIRECTIVES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Colunas legadas CPU_METHOD/MANDATORY/CPU_Pn podem variar por versão. Não se refere a SQL Plan Directives do otimizador; não ativa Resource Manager nem mede consumo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @plan_directive.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Plano/subplano, métodos/flags, CPU_P1..P8 e PARALLEL_DEGREE_LIMIT_P1.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Typo DBA_RSRC_PALNS e vírgula ausente corrigidos; join C cartesiano/autoassociação corrigidos, sem retirar métricas. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
-- comment:     : GENERATE DATABASE RESOURCE PLAN DIRECTIVES REPORT
REM Revisions:
REM Date          Modified by     Reason for change
REM 15-May-1999     MIKE AULT     initial creation
REM
REM NAME        : RESOURCE_PLAN.SQL
REM PURPOSE     : GENERATE DATABASE RESOURCE PLAN REPORT
REM Revisions:
REM Date          Modified by     Reason for change

REM
COLUMN plan                     FORMAT a10     HEADING 'Plan|Name'
COLUMN cpu_method1              FORMAT a30     HEADING 'CPU|Method'
COLUMN mandatory1               FORMAT a4      HEADING 'Man?'
COLUMN num_plan_directives      FORMAT 9999    HEADING 'Num|Directives'
COLUMN group_or_subplan         FORMAT a12     HEADING 'Group or|Subplan Name'
COLUMN type                     FORMAT a8      HEADING 'Group or|Subplan'
COLUMN cpu_method2              FORMAT a30     HEADING 'CPU|Method'
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
spool plan_directive.lst
REM
SELECT
      a.plan,
      a.cpu_method cpu_method1,
      a.mandatory mandatory1,
      b.group_or_subplan,
      b.type,
      c.cpu_method cpu_method2,
      c.mandatory mandatory2,
      b.cpu_p1,b.cpu_p2,b.cpu_p3,b.cpu_p4,
      b.cpu_p5,b.cpu_p6,b.cpu_p7,b.cpu_p8,
      parallel_degree_limit_p1

FROM dba_rsrc_plans a
JOIN dba_rsrc_plan_directives b ON a.plan=b.plan AND b.type='SUBPLAN'
LEFT JOIN dba_rsrc_plans c ON c.plan=b.group_or_subplan
ORDER BY
     a.plan;
SPOOL OFF
CLEAR COLUMNS
SET VERIFY ON FEEDBACK ON
TTITLE OFF

