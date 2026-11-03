/*
===============================================================================
SCRIPT: tab_col.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/TAB_COL.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Descrever tipos e nulabilidade de colunas de tabelas/views/clusters selecionados.

FUNCIONAMENTO DETALHADO
  Une TAB_COLUMNS a OBJECTS por owner/nome, filtra proprietário e fragmento de nome e ordena COLUMN_ID.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TAB_COLUMNS, DBA_OBJECTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DATA_LENGTH é bytes máximos, não precisão/escala ou tamanho médio. Não cobre todos os atributos de caracteres/identidade; objetos internos e containers dependem do catálogo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE owner = HR
  DEFINE table = EMP
  @tab_col.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, nome/tipo de objeto, coluna, tipo/type owner, DATA_LENGTH e nullable.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta e créditos históricos preservados. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Título convertido em TTITLE local.
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
rem tab_col.sql
rem
rem FUNCTION: Report on Table and View Column Definitions
rem
rem MRA 9/18/96
rem MRA 6/14/97 Added table level selectivity
rem
COLUMN owner 		FORMAT a10 	HEADING Owner
COLUMN table_name 	FORMAT a30 	HEADING "Table or View Name"
COLUMN COLUMN_name 	FORMAT a32 	HEADING "Table or View|Attribute"
COLUMN data_type 	FORMAT a15 	HEADING "Data|Type"
COLUMN data_type_owner  FORMAT a13      HEADING "Type|Owner"
COLUMN data_length 			HEADING Length
COLUMN nullable 	FORMAT a5 	HEADING Null
BREAK ON owner ON table_name SKIP 1
SET LINES 132 PAGES 48 FEEDBACK OFF VERIFY OFF
ttitle "Table Columns Report"
spool tab_col.lst
SELECT 
	a.owner,
	table_name||' '||object_type table_name, 
	column_name,
	data_type,
        data_type_owner,
	data_length,
	DECODE(nullable,'N','NO','YES') nullable
FROM 
	dba_tab_columns a, dba_objects b 
WHERE
	a.owner not in ('SYS','SYSTEM') AND
	a.owner=UPPER('&owner') AND
	a.owner=b.owner AND
	a.table_name LIKE UPPER('%&table%') AND
	a.table_name=b.object_name AND
	object_type IN ('TABLE','VIEW','CLUSTER')
ORDER BY 
	owner, 
	object_type,
	table_name, 
	column_id
/
SPOOL OFF
TTITLE OFF
SET LINES 80 PAGES 22 FEEDBACK ON VERIFY ON

