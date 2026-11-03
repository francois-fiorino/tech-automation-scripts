/*
===============================================================================
SCRIPT: ind_part.sql
CATEGORIA: Oracle / objects/indexes
ORIGEM: Oracle Script Collection 2015 / _index_scripts/ind_part.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar subpartições de índices e atributos de sua partição pai.

FUNCIONAMENTO DETALHADO
  Une DBA_IND_PARTITIONS e DBA_IND_SUBPARTITIONS por INDEX_OWNER, INDEX_NAME e PARTITION_NAME; exibe HIGH_VALUE do pai e tablespace/logging/status da subpartição.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_IND_PARTITIONS, SYS.DBA_IND_SUBPARTITIONS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  INNER JOIN retorna apenas índices com subpartições; não é inventário completo de índices particionados simples. HIGH_VALUE é LONG em versões históricas e pode ser truncado pelo cliente. Não lista nomes físicos de arquivos apesar do título original.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @ind_part.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner/índice/partição, HIGH_VALUE, subpartição, tablespace, logging e status.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  A.OWNER=B.OWNER corrigido para A.INDEX_OWNER=B.INDEX_OWNER, colunas reais das views. Removido / após SELECT terminado por ; para evitar execução duplicada no SQL*Plus. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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

rem
rem Name: ind_part.sql
-- comment: Report on partitioned index structure

rem
COLUMN index_owner       FORMAT a10 HEADING 'Owner'
COLUMN index_name        FORMAT a15 HEADING 'Index'
COLUMN partition_name    FORMAT a15 HEADING 'Partition'
COLUMN subpartition_name FORMAT a15 HEADING 'Sub|Partition'
COLUMN tablespace_name   FORMAT a15 HEADING 'Tablespace'
COLUMN high_value        FORMAT a10 HEADING 'Partition|Value'
COLUMN status            FORMAT a10 Heading 'Status'
SET LINES 130
ttitle 'Index Partition Files'
BREAK ON index_owner ON index_name
spool ind_part.lst

SELECT
   a.index_owner, 
   a.index_name, 
   a.partition_name, 
   a.high_value, 
   b.subpartition_name, 
   b.tablespace_name,
   b.logging,
   b.status
FROM 
   sys.dba_ind_partitions a, 
   sys.dba_ind_subpartitions b
WHERE 
   a.index_owner=b.index_owner
AND 
   a.index_name=b.index_name
And 
   a.partition_name=b.partition_name
ORDER BY 
   a.index_owner,
   a.index_name,
   a.partition_name,
   b.subpartition_position;
SPOOL OFF
