/*
===============================================================================
SCRIPT: dim_attribute.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/dim_attribute.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar atributos de dimensões de data warehouse por owner.

FUNCIONAMENTO DETALHADO
  Une DIMENSIONS/LEVELS/ATTRIBUTES por owner/nome/nível e apresenta atributo e INFERRED.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_DIMENSIONS, DBA_DIM_LEVELS, DBA_DIM_ATTRIBUTES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Views exigem suporte a dimensões no catálogo. Owner LIKE original é case-sensitive; passar padrão correto. Metadados não validam integridade dos dados.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE owner = HR
  @dim_attribute.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, dimensão, nível, coluna e inferred.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Título incorreto OPERATOR trocado para Dimension Attributes; joins preservados. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem NAME: dim_attribute.sql
rem FUNCTION: Generate a lit of all Dimensions and atrributes in the 
rem database for a specific user or all users
rem HISTORY: MRA 5/12/98 Created
rem
COLUMN owner             FORMAT a8   HEADING 'Owner'
COLUMN dimension_name    FORMAT a10  HEADING 'Dimension|Name'
COLUMN column_name       FORMAT a20  HEADING 'Column|Name'
COLUMN level_name        FORMAT a20  HEADING 'Level|Name'
COLUMN inferred          FORMAT a10  HEADING 'Inferred'
BREAK ON owner ON level_name
SET PAGES 58 LINES 78 FEEDBACK OFF VERIFY OFF
ttitle 'Database Dimension Attributes Report'
spool dim_attribute.lst
SELECT 
     a.owner,
     a.dimension_name,
     b.level_name,
     c.column_name,
     c.inferred
FROM
     Dba_dimensions a, dba_dim_levels b, dba_dim_attributes c
WHERE
          a.owner LIKE '%&owner%'
      AND a.owner=b.owner
      AND a.dimension_name=b.dimension_name
      AND a.owner=c.owner
      AND a.dimension_name=c.dimension_name
      AND b.level_name=c.level_name
ORDER BY
      a.owner,
      a.dimension_name,
      b.level_name;
SPOOL OFF
CLEAR BREAKS
CLEAR COLUMNS
TTITLE OFF
SET FEEDBACK ON VERIFY ON

