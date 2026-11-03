/*
===============================================================================
SCRIPT: operator.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/operator.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar operadores extensíveis, argumentos e bindings.

FUNCIONAMENTO DETALHADO
  Une OPERATORS/OPARGUMENTS/OPBINDINGS por owner/nome/binding#, mostrando posição e função ligada.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_OPERATORS, DBA_OPARGUMENTS, DBA_OPBINDINGS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não são operadores aritméticos SQL comuns; consulta somente metadados, sem invocar funções. Filtro case-sensitive e várias linhas por binding são esperadas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE owner = HR
  @operator.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Operador, número de binds, posição/tipo de argumento, função e tipo/schema de retorno.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  ORDER BY compatível com BREAK e binding/posição acrescentado para apresentação consistente. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem
rem NAME: operator.sql
rem FUNCTION: Generate a lit of all OPERATORS in the database
rem for a specific user or all users
rem HISTORY: MRA 5/12/98 Created
rem
COLUMN owner             FORMAT a8   HEADING 'Owner'
COLUMN operator_name     FORMAT a10  HEADING 'Operator|Name'
COLUMN number_of_binds   FORMAT 9999 HEADING 'Binds'
COLUMN position                      HEADING 'Position'
COLUMN argument_type     FORMAT A10  HEADING 'Argument|Type'
COLUMN function_name     FORMAT A21  HEADING 'Bound|Function'
COLUMN return_schema     FORMAT A10  HEADING 'Return|Schema'
COLUMN return_type       FORMAT A10  HEADING 'Return|Type'
BREAK ON owner ON operator_name ON number_of_binds
SET PAGES 58 LINES 130 FEEDBACK OFF VERIFY OFF
ttitle 'Database OPERATOR Report'
spool operator.lst
SELECT 
     a.owner,
     a.operator_name,
     a.number_of_binds,
     b.position,
     b.argument_type,
     c.function_name,
     DECODE(c.return_schema,NULL,'Internal',c.return_schema) return_schema,
     c.return_type
FROM
     Dba_operators a, dba_oparguments b, dba_opbindings c
WHERE
         a.Owner LIKE '%&owner%'
     AND a.owner=b.owner
     AND a.operator_name=b.operator_name
     AND a.owner=c.owner
     AND a.operator_name=c.operator_name
     AND b.binding#=c.binding#
ORDER BY a.owner,a.operator_name,b.binding#,b.position;
SPOOL OFF
CLEAR BREAKS
CLEAR COLUMNS
TTITLE OFF
SET FEEDBACK ON VERIFY ON

