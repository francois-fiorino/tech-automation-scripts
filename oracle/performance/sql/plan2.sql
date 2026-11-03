/*
===============================================================================
SCRIPT: plan2.sql
CATEGORIA: Oracle / performance/sql
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/PLAN2.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir hierarquia histórica de operações a partir do nó ID=1 de PLAN_TABLE.

FUNCIONAMENTO DETALHADO
  Consulta OWNER.PLAN_TABLE e usa CONNECT BY PRIOR ID=PARENT_ID com START WITH ID=1; indenta operação e nome de objeto por LEVEL.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  PLAN_TABLE do proprietário indicado

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Requer PLAN_TABLE preenchida para um único plano: sem filtro STATEMENT_ID/PLAN_ID, várias capturas podem se cruzar ou formar loops. ID=0, normalmente raiz, não é mostrado. Não executa EXPLAIN PLAN nem representa necessariamente plano real de cursor.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE owner = HR
  @plan2.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  QUERY_PLAN com operação/objeto hierárquicos a partir de ID=1.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código histórico preservado; escopo de nó inicial e risco de misturar planos explicitados. Usar somente cópia de PLAN_TABLE isolada com um plano. 
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
COLUMN QUERY_PLAN FORMAT A60
SELECT LPAD( '  ' , 2*LEVEL) || OPERATION || ' ' || OBJECT_NAME QUERY_PLAN
FROM &owner..PLAN_TABLE 
CONNECT BY PRIOR ID = PARENT_ID
START WITH ID=1;

