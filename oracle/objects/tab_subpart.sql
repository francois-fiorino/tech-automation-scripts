/*
===============================================================================
SCRIPT: tab_subpart.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/tab_subpart.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar armazenamento de subpartições de tabelas com identificação de proprietário.

FUNCIONAMENTO DETALHADO
  Consulta DBA_TAB_SUBPARTITIONS e apresenta tabela/partição/subpartição/tablespace/logging e extents em KiB.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_TAB_SUBPARTITIONS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não filtra owner e não mostra arquivo físico. NEXT_EXTENT/PCT_INCREASE podem ter semântica histórica; atributos de LMT variam. Sem ordenação por SUBPARTITION_POSITION.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @tab_subpart.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  TABLE_OWNER visível, tabela, partição, subpartição, tablespace e atributos de extent.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Removida dependência de OWNER1 no título antes de definir a variável e coluna do proprietário deixou de ser NOPRINT, evitando misturar schemas sem identificação. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem Name: tab_subpart.sql
rem Function : Report on partitioned table structure
rem History: MRA 6/13/97 Created
rem
COLUMN table_owner FORMAT a20 HEADING 'Owner'
COLUMN table_name       FORMAT a15 HEADING 'Table'
COLUMN partition_name 	FORMAT a15 HEADING 'Partition'
COLUMN tablespace_name 	FORMAT a15 HEADING 'Tablespace'
COLUMN initial_extent   FORMAT 9,999 HEADING 'Initial|Extent (K)'
COLUMN next_extent      FORMAT 9,999 HEADING 'Next|Extent (K)'
COLUMN pct_increase     FORMAT 999 HEADING 'PCT|Increase'
COLUMN subpartition_name FORMAT a15 HEADING 'Sub|Partition'
SET LINES 130 head on
ttitle 'Table Sub-Partition Files'
BREAK ON table_owner ON table_name ON partition_name
spool tab_subpart.lst
SELECT
	table_owner,            
	table_name,             
	partition_name,
        subpartition_name,                      
	tablespace_name,        
	logging,
        initial_extent/1024 initial_extent,
        next_extent/1024 next_extent,
        pct_increase                 
FROM sys.dba_tab_subpartitions
ORDER BY table_owner,table_name,partition_name
/
SPOOL OFF
