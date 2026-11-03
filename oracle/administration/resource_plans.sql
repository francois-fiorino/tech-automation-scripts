/*
===============================================================================
SCRIPT: resource_plans.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/resource_plans.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relacionar planos e suas directives de grupos ou subplanos.

FUNCIONAMENTO DETALHADO
  Une PLAN a directives e LEFT JOIN condicional para metadados do subplano ou consumer group, mantendo DECODEs da saída.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_RSRC_PLANS, DBA_RSRC_PLAN_DIRECTIVES, DBA_RSRC_CONSUMER_GROUPS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CPU_METHOD/MANDATORY são atributos de versões antigas; não garante compilação moderna. Não mostra quotas/níveis de CPU nem altera plano.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @resource_plans.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Plano/método/flags e destino com metadados, sufixo CG para grupo conforme DECODE histórico.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Join com OR que multiplicava planos/grupos substituído por LEFT JOINs condicionais ao TYPE; projeção DISTINCT/DECODE preservada. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
REM Revisions:
REM Date          Modified by     Reason for change

REM
COLUMN plan                FORMAT a12      HEADING 'Plan|Name'
COLUMN cpu_method1         FORMAT a10      HEADING 'CPU|Method'
COLUMN mandatory1          FORMAT a4       HEADING 'Man?'
COLUMN num_plan_directives FORMAT 9999     HEADING 'Num|Directives'
COLUMN group_or_subplan    FORMAT a15      HEADING 'Group or|Subplan Name'
COLUMN type                FORMAT a8       HEADING 'Group or|Subplan'
COLUMN cpu_method2         FORMAT a15      HEADING 'CPU|Method'
COLUMN mandatory2          FORMAT a4       HEADING 'Man?'
COLUMN plan2 NOPRINT
REM
SET LINES 78 VERIFY OFF FEEDBACK OFF
BREAK ON plan on cpu_method1 on mandatory1 on num_plan_directives
ttitle 'Resource Plan Report'
spool resource_plans.lst
REM
SELECT DISTINCT
      decode(b.plan,'',a.plan,b.plan) plan,
      b.plan plan2,
      a.cpu_method cpu_method1,
      a.mandatory mandatory1,
      decode(b.group_or_subplan,'',d.consumer_group||' CG',b.group_or_subplan) group_or_subplan,
      DECODE(b.type,'CONSUMER_GROUP','GROUP',b.type) type,
      decode(c.cpu_method,'',d.cpu_method||' CG',c.cpu_method) cpu_method2,
      decode(c.mandatory,'',d.mandatory||' CG',c.mandatory) mandatory2
FROM dba_rsrc_plans a
JOIN dba_rsrc_plan_directives b ON a.plan=b.plan
LEFT JOIN dba_rsrc_plans c ON b.type='SUBPLAN' AND b.group_or_subplan=c.plan
LEFT JOIN dba_rsrc_consumer_groups d ON b.type='CONSUMER_GROUP' AND b.group_or_subplan=d.consumer_group
ORDER BY
     2,5;
SPOOL OFF
CLEAR COLUMNS
SET VERIFY ON FEEDBACK ON
TTITLE OFF

