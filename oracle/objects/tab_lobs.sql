/*
===============================================================================
SCRIPT: tab_lobs.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/tab_lobs.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar metadados de colunas LOB após exclusões de schemas históricas.

FUNCIONAMENTO DETALHADO
  Consulta DBA_LOBS com owner/tabela/coluna/segmento/índice e IN_ROW.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_LOBS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não é tamanho físico nem inventário completo das partições/subpartições LOB. IN_ROW é configuração, não garantia de que todo LOB esteja armazenado na linha. Exclusões fixas preservadas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @tab_lobs.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OWNER, TABLE_NAME, COLUMN_NAME, SEGMENT_NAME, INDEX_NAME e IN_ROW.

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
col column_name format a15 heading 'Column|Name'
col segment_name format a26 heading 'Segment|Name'
col index_name format a26 heading 'Index|Name'
col owner format a15 heading 'Owner'
col table_name format a22 heading 'Table|Name'
col in_row format a3 heading 'In|Row'
set lines 132 pages 50
ttitle 'Database Lob Column Data'
spool tab_lobs.lst
select owner,table_name,column_name,segment_name,index_name,in_row from dba_lobs
where owner not in ('SYS','SYSTEM','PRECISE','MAULT','PATROL','QDBA','OUTLN','XDB','WMSYS','MDSYS','CTXSYS','ODM','SYSMAN')
/
spool off
set lines 80 pages 22
ttitle off
