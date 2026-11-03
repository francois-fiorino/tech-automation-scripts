/*
===============================================================================
SCRIPT: outline_hint.sql
CATEGORIA: Oracle / performance/sql
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/outline_hint.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar hints de stored outlines por padrões de owner e nome.

FUNCIONAMENTO DETALHADO
  Une DBA_OUTLINES e DBA_OUTLINE_HINTS por proprietário/nome e retorna nó, posição de join e hint.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_OUTLINES, DBA_OUTLINE_HINTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Stored outlines são tecnologia legada; não são SQL plan baselines. Padrões contêm % antes/depois da entrada. Não aplica hint nem força plano. Texto pode truncar na coluna cliente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE owner = HR
  DEFINE outline = %
  @outline_hint.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, outline, categoria, NODE, JOIN_POS e HINT.

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
rem
rem NAME: outline_hint.sql
rem comment: Generate a list of all outlines in the database for a specific user and outline or all users and outlines

rem
COLUMN owner        FORMAT a8   HEADING 'Owner'
COLUMN name         FORMAT a13  HEADING 'Outline|Name'
COLUMN category     FORMAT a10  HEADING 'Category|Name'
COLUMN node         FORMAT 9999 HEADING 'Node'
COLUMN join_pos     FORMAT 9999 HEADING 'Join|Pos'
COLUMN hint         FORMAT A27  HEADING 'Hint Text' WORD_WRAPPED
BREAK ON owner ON category ON name
SET PAGES 58 LINES 78 FEEDBACK OFF VERIFY OFF
ttitle 'Database OUTLINE Report'
spool outline_hint.lst
SELECT 
     a.owner,
     a.name,
     a.category,
     b.node,
     b.join_pos,
     b.hint
FROM
     Dba_outlines a, dba_outline_hints b 
WHERE
      a.Owner LIKE UPPER('%&owner%')
      AND a.name LIKE UPPER('%&outline%')
      AND a.owner=b.owner
      AND a.name=b.name
ORDER BY
      owner,category,name,b.node;
SPOOL OFF
CLEAR BREAKS
TTITLE OFF
SET FEEDBACK ON VERIFY ON

