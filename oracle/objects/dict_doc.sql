/*
===============================================================================
SCRIPT: dict_doc.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/dict_doc.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Extrair comentários de tabelas/views com prefixo DBA_ ou sufixo $.

FUNCIONAMENTO DETALHADO
  Une TAB_COMMENTS a COL_COMMENTS por owner/tabela e seleciona pares de comentários distintos.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TAB_COMMENTS, DBA_COL_COMMENTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não filtra SYS; nomes iguais de owners distintos podem aparecer sem identificação do owner. INNER JOIN exige linha no catálogo de comentários. LIKE DBA_% usa underscore como wildcard.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @dict_doc.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Nome, comentário de tabela, coluna e comentário da coluna.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Typo Commnet corrigido no heading; seleção histórica preservada. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
column table_name format a25 heading 'View Name'
column tab_comments format a37 word_wrapped heading 'Table Comment'
column column_name format a25 heading 'Column Name'
column col_comments format a37 word_wrapped heading 'Column Comment'
break on table_name on tab_comments
set lines 131 feedback off verify off pages 47
ttitle 'Dictionary Documentation'
spool dict_doc.lst
select distinct a.table_name,a.comments tab_comments,b.column_name,
b.comments col_comments
from dba_tab_comments a, dba_col_comments b
where a.owner=b.owner and
a.table_name=b.table_name and
(a.table_name like 'DBA_%' or
a.table_name like '%$')
order by table_name
/
spool off
clear columns
clear breaks
set lines 80 pages 22 feedback on verify on
ttitle off
