/*
===============================================================================
SCRIPT: tab_stat.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _table_scripts/TAB_STAT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar estatísticas e estimativa de proporção de bytes de linhas nos blocos da tabela.

FUNCIONAMENTO DETALHADO
  UNION de estatísticas DBA_TABLES/OBJECT_TABLES; calcula NUM_ROWS*AVG_ROW_LEN dividido por blocos e tamanho de bloco do tablespace.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES, DBA_OBJECT_TABLES, DBA_TABLESPACES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Estatísticas podem estar antigas/NULL. Estimativa não mede overhead/LOB/compressão nem ocupação ASSM exata; EMPTY_BLOCKS depende do modo de coleta. Tabela particionada sem tablespace global terá percentual NULL.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @tab_stat.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner/tabela, estatísticas de linhas/blocos, percentual estimado, chains e freelists.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Bloco fixo 2048 substituído por BLOCK_SIZE do tablespace em ambos os ramos; EMPTY_BLOCKS NULL tratado e denominador protegido. OUTPUT local. Título convertido em TTITLE local.
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
rem  NAME: tab_stat.sql
rem
rem  FUNCTION:  Will show table statistics for a user's tables or all tables.
rem
 set pages 56 lines 140 newpage 0 verify off echo off feedback off
rem
column owner            format a7            heading "Table|Owner"
column table_name       format a30            heading "Table"
column tablespace_name  format a13            heading "Tablespace"
column num_rows         format 999,999    heading "Rows"
column blocks           format 99,999        heading "Blocks" 
column empty_blocks     format 99,999        heading "Empties" 
column space_full       format 9999.99         heading "% Full" 
column chain_cnt        format 9,999        heading "Chains"
column avg_row_len      format 99,999 heading "Avg|Length|(Bytes)"
column num_freelist_blocks format 99,999     heading "Num|Freelist|Blocks"
column avg_space_freelist_blocks FORMAT 9,999 heading "Avg Space|Freelist|Blocks"
rem
ttitle "Table Statistics Report"
define output = tab_stat.lst
spool &output
rem
BREAK ON OWNER SKIP 2 ON TABLESPACE_NAME SKIP 1;
select owner, table_name, tablespace_name, num_rows, blocks,
	empty_blocks,  
	100*((NUM_ROWS * AVG_ROW_LEN)/nullif((GREATEST(blocks,1) + nvl(empty_blocks,0)) * (select ts.block_size from dba_tablespaces ts where ts.tablespace_name=t.tablespace_name),0)) space_full,
	chain_cnt, avg_row_len,avg_space_freelist_blocks, num_freelist_blocks
from dba_tables t
WHERE OWNER NOT IN ('SYS','SYSTEM') and num_rows is not null
union
select owner, table_name, tablespace_name, num_rows, blocks,
	empty_blocks,  
	100*((NUM_ROWS * AVG_ROW_LEN)/nullif((GREATEST(blocks,1) + nvl(empty_blocks,0)) * (select ts.block_size from dba_tablespaces ts where ts.tablespace_name=t.tablespace_name),0)) space_full,
	chain_cnt, avg_row_len,avg_space_freelist_blocks, num_freelist_blocks
from dba_object_tables t
WHERE OWNER NOT IN ('SYS','SYSTEM') and num_rows is not null
order by owner, tablespace_name;
spool off
pause Press enter to continue
 set pages 22 lines 80 newpage 1 verify on feedback on
clear columns
clear breaks
ttitle off

