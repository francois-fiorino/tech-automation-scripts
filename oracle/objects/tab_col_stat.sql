/*
===============================================================================
SCRIPT: tab_col_stat.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/tab_col_stat.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir estatísticas de colunas por fragmentos de owner/tabela.

FUNCIONAMENTO DETALHADO
  Consulta TAB_COLUMNS com NDV/density/nulls, data de análise, amostra e AVG_COL_LEN.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TAB_COLUMNS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DENSITY depende de histogramas e versão; não traduz automaticamente seletividade real. Dados podem estar NULL ou antigos; não coleta estatísticas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE owner = HR
  DEFINE tabname = EMP
  @tab_col_stat.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner/tabela/coluna/tipo e estatísticas, médias em bytes.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta integral preservada; spool específico evita colisão com TAB_COL. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Título convertido em TTITLE local.
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
rem tab_col_stat.sql
rem
rem FUNCTION: Report on Table and View Column Definitions
rem
rem MRA 9/18/96
rem MRA 6/14/97 Added table level selectivity
rem MRA 5/8/99 Converted to do stats
rem
COLUMN owner 		FORMAT a12 	HEADING Owner
COLUMN table_name 	FORMAT a20 	HEADING "Table Name"
COLUMN COLUMN_name 	FORMAT a13	HEADING "Table|Attribute"
COLUMN data_type 	FORMAT a10 	HEADING "Data|Type"
COLUMN avg_col_len      FORMAT 99,999   HEADING "Aver|Length"
COLUMN density          FORMAT 9.9999   HEADING "Density"
COLUMN last_analyzed                    Heading "Analyzed"
COLUMN num_distinct                     HEADING "Distinct|Values"
COLUMN num_nulls                        HEADING "Num.|Nulls"
COLUMN sample_size                      HEADING "Sample|Size"
BREAK ON owner ON table_name SKIP 1
SET LINES 132 PAGES 48 FEEDBACK OFF VERIFY OFF
ttitle "Table Column Stats Report"
spool tab_col_stat.lst
select owner,table_name,column_name,data_type,
num_distinct,density,num_nulls,
to_char(last_analyzed,'dd-mon-yyyy hh24:mi') last_analyzed, 
sample_size, avg_col_len
from dba_tab_columns 
where owner like upper('%&owner%')
and table_name like upper('%&tabname%')
/
SPOOL OFF
TTITLE OFF
SET LINES 80 PAGES 22 FEEDBACK ON VERIFY ON

