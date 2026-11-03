/*
===============================================================================
SCRIPT: tab_rep.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/TAB_REP.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar atributos estendidos de tabelas relacionais e object tables.

FUNCIONAMENTO DETALHADO
  UNION de DBA_TABLES com DBA_OBJECT_TABLES; primeiro ramo usa N/A para atributos de tipo, segundo mostra tipo real.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES, DBA_OBJECT_TABLES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  UNION não elimina versões com N/A versus tipo real, podendo haver duas linhas da mesma object table. Campos de storage podem ser NULL conforme organização.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @tab_rep.sql
  -- Informar fragmento do owner após UNDEF.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, tabela/tablespace, IOT, logging/partição, tipo, temporária e nested.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Dois ramos preservados; duplicidade semântica documentada. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
REM
REM     Name:      tab_rep.sql
REM     FUNCTION:  Document table extended parameters
REM     Use:       From SQLPLUS 
REM	MRA 6/13/97 Created for ORACLE8
REM
column owner 		format a10 heading 'Owner'
column table_name 	format a15 heading 'Table'
column tablespace_name 	format a13 heading 'Tablespace'
column table_type_owner format a10 heading 'Type|Owner'
column table_type 	format a13 heading 'Type'
column iot_name 	format a10 heading 'IOT|Overflow'
column iot_type 	format a12 heading 'IOT or|Overflow'
COLUMN nested 		format a6  heading 'Nested'
undef owner
set lines 130 verify off feedback off pages 58
ttitle 'Extended Table Report'
spool tab_rep.lst
select
	OWNER,                          
	TABLE_NAME,                     
	TABLESPACE_NAME,                              
	IOT_NAME,                       
	LOGGING,                                      
	PARTITIONED,                    
	IOT_TYPE,
        'N/A' table_type_owner,
        'N/A' table_type,                       
	TEMPORARY,                      
	NESTED 
from 
	dba_tables 
where 
	owner like upper('%&&owner%')    
UNION 
select
	OWNER,                          
	TABLE_NAME,                     
	TABLESPACE_NAME,                              
	IOT_NAME,                       
	LOGGING,                                      
	PARTITIONED,                    
	IOT_TYPE,                       
	TABLE_TYPE_OWNER,               
	TABLE_TYPE,                                     
	TEMPORARY,                      
	NESTED 
from 
	dba_object_tables 
where 
	owner like upper('%&&owner%');           
spool off
set verify on lines 80 pages 22 feedback on
ttitle off
undef owner
clear columns
