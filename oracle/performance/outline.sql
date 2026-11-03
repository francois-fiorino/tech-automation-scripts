/*
===============================================================================
SCRIPT: outline.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / misc_scripts/outline.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar stored outlines e metadados de SQL associados.

FUNCIONAMENTO DETALHADO
  Consulta DBA_OUTLINES por padrão case-sensitive de owner e ordena owner/category.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_OUTLINES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Stored outlines são recurso legado; não altera USE_STORED_OUTLINES ou planos. TIMESTAMP é data de criação/registro conforme versão, não data garantida de último uso. SQL_TEXT pode ser sensível.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE owner = HR
  @outline.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner/nome/category, USED, timestamp, versão e texto SQL.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Heading Date Last Used corrigido para Outline Timestamp; consulta preservada. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem NAME: outline.sql
rem FUNCTION: Generate a lit of all outlines in the 
rem database for a specific user or all users
rem HISTORY: MRA 5/13/98 Created
rem
COLUMN owner        FORMAT a8   HEADING 'Owner'
COLUMN name         FORMAT a13  HEADING 'Outline|Name'
COLUMN category     FORMAT a8  HEADING 'Category|Name'
COLUMN used         FORMAT a7   HEADING 'Used?'
COLUMN timestamp    FORMAT a16  HEADING 'Outline|Timestamp'
COLUMN version      FORMAT a9   HEADING 'Version'
COLUMN sql_text     FORMAT a40  HEADING 'SQL Outlined' WORD_WRAPPED 
BREAK ON owner ON category
SET PAGES 58 LINES 130 FEEDBACK OFF VERIFY OFF
ttitle 'Database OUTLINE Report'
spool outline.lst
SELECT 
     owner,
     name,
     category,
     used,
     to_char(timestamp,'dd/mm/yyyy hh24:mi') timestamp ,
     version,
     sql_text
FROM
     Dba_outlines 
WHERE
      Owner LIKE '%&owner%'
ORDER BY
      owner,category;
SPOOL OFF
CLEAR BREAKS
TTITLE OFF
SET FEEDBACK ON VERIFY ON

