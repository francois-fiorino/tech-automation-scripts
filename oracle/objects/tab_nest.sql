/*
===============================================================================
SCRIPT: tab_nest.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/TAB_NEST.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Inventariar armazenamento de nested tables e sua coluna/tabela pai.

FUNCIONAMENTO DETALHADO
  Consulta DBA_NESTED_TABLES e apresenta tipo, parent table/column, storage spec e return type.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_NESTED_TABLES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Depende de suporte objeto-relacional e colunas disponíveis na versão. Não conta elementos nem espaço; nomes longos podem ser truncados.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @tab_nest.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, storage table, tipo, tabela/coluna pai e opções.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta e comentários históricos preservados. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem NAME: tab_nest.sql
rem PURPOSE: Report on Nested Tables
rem HISTORY: MRA 6/14/97 Created
rem
COLUMN owner 			FORMAT a10 HEADING 'Owner'
COLUMN table_name 		FORMAT a15 HEADING 'Store Table'
COLUMN table_type_owner 	FORMAT a10 HEADING 'Type|Owner'
COLUMN table_type_name 	FORMAT a15 HEADING 'Type|Name'
COLUMN parent_table_name 	FORMAT a25 HEADING 'Parent|Table'
COLUMN parent_table_column 	FORMAT a12 HEADING 'Parent|Column'
COLUMN storage_spec             FORMAT a15  HEADING 'Storage|Spec'
COLUMN return_type              FORMAT a7  HEADING 'Return|Type'
SET PAGES 58 LINES 132 VERIFY OFF FEEDBACK OFF
ttitle 'Nested Tables'
BREAK ON owner
spool tab_nest.lst
SELECT
	owner,
	table_name,
	table_type_owner,   
	table_type_name,    
	parent_table_name,    
	parent_table_column,
        LTRIM(storage_spec) storage_spec,
        LTRIM(return_type) return_type
FROM sys.dba_nested_tables
ORDER BY owner;
SPOOL OFF
