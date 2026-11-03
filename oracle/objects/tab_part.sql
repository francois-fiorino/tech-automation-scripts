/*
===============================================================================
SCRIPT: tab_part.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/TAB_PART.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar partições de tabelas incluindo número de subpartições.

FUNCIONAMENTO DETALHADO
  Consulta DBA_TAB_PARTITIONS com SUBPARTITION_COUNT e ordena proprietário/tabela/partição.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_TAB_PARTITIONS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não mostra subpartições individualmente nem arquivos; HIGH_VALUE e nomes longos podem truncar na apresentação. Mantida como variante funcional distinta de tab_part80.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @tab_part.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner/tabela/partição, quantidade de subpartições, limite, tablespace e logging.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código original preservado. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem Name: tab_part.sql
rem Function : Report on partitioned table structure
rem History: MRA 6/13/97 Created
rem
COLUMN table_owner     FORMAT a10 HEADING 'Owner'
COLUMN table_name      FORMAT a35 HEADING 'Table'
COLUMN partition_name  FORMAT a10 HEADING 'Partition'
COLUMN tablespace_name FORMAT a30 HEADING 'Tablespace'
COLUMN high_value      FORMAT a10 HEADING 'Partition|Value'
COLUMN subpartition_count FORMAT 9,999 HEADING 'Sub-Partitions'
SET LINES 130 pages 47
ttitle 'Table Partition Files'
BREAK ON table_owner ON table_name
spool tab_part.lst
SELECT
     table_owner,
     table_name,
     partition_name,
     subpartition_count,
     high_value,
     tablespace_name,
     logging
FROM sys.dba_tab_partitions
ORDER BY table_owner,table_name,partition_name
/
SPOOL OFF
undef tab_owner
