/*
===============================================================================
SCRIPT: tab_part_stat.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/tab_part_stat.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar estatísticas e parâmetros de partições de tabelas.

FUNCIONAMENTO DETALHADO
  Filtra DBA_TAB_PARTITIONS por fragmento de owner e ordena owner/tabela/posição.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_TAB_PARTITIONS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Estatísticas podem estar NULL/antigas; em partição composta algumas informações residem nas subpartições. PCT_USED/freelists não controlam ASSM.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @tab_part_stat.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  TABLE_OWNER, tabela/partição, rows/blocks/avg space/chains/len, parâmetros e LAST_ANALYZED.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  TABLE_OWNER incluído na saída para sustentar BREAK e distinguir owners; ordenação por PARTITION_POSITION acrescentada. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem Name: tab_part_stat.sql
rem Function : Report on partitioned table statistics
rem History: MRA 6/13/97 Created
rem
COLUMN table_name       FORMAT a13   HEADING 'Table'
COLUMN partition_name 	FORMAT a16   HEADING 'Partition'
COLUMN num_rows HEADING 'Num|Rows' format 9999999
COLUMN blocks HEADING 'Blocks' format 99999
COLUMN avg_space HEADING 'Avg|Space' format 99999
COLUMN chain_cnt HEADING 'Chain|Count' format 99999
COLUMN avg_row_len HEADING 'Avg|Row|Length' format 999999
COLUMN last_analyzed HEADING 'Analyzed'
ACCEPT owner1 PROMPT 'Which Owner to report on?:'
SET LINES 132
ttitle 'Table Partition Statistics For &owner1'
BREAK ON table_owner ON table_name ON partition_name
spool tab_part_stat.lst
SELECT table_owner,
	table_name,             
	partition_name,
        num_rows,
        blocks,
        avg_space,
        chain_cnt,
        avg_row_len,
        pct_free,
        pct_used,
        ini_trans,
        freelists,
        to_char(last_analyzed,'dd-mon-yyyy hh24:mi') last_analyzed                      
FROM sys.dba_tab_partitions
WHERE table_owner LIKE UPPER('%&&owner1%')
ORDER BY table_owner,table_name,partition_position
/
SPOOL OFF
CLEAR BREAKS
CLEAR COLUMNS
TTITLE OFF
UNDEF owner1
