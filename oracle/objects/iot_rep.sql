/*
===============================================================================
SCRIPT: iot_rep.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/iot_rep.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar tabelas index organized e seus overflows.

FUNCIONAMENTO DETALHADO
  UNION das views de tabelas e object tables com IOT_TYPE não nulo e fragmento de owner.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES, DBA_OBJECT_TABLES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  UNION remove apenas linhas idênticas; não detalha índices/partições ou bytes. Prefixo de owner é solicitado após UNDEF.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @iot_rep.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, tabela/tablespace, IOT_NAME, logging, partição e IOT_TYPE.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta preservada; spool local. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
REM     Name:      tab_iot.sql
REM     FUNCTION:  Document table extended parameters
REM     Use:       From SQLPLUS 
REM	MRA 6/13/97 Created for ORACLE8
REM
column owner 		format a10 heading 'Owner'
column table_name 	format a30 heading 'Table'
column tablespace_name 	format a20 heading 'Tablespace'
column iot_name 	format a26 heading 'IOT|Overflow'
column iot_type 	format a12 heading 'IOT or|Overflow'
undef owner
set lines 130 verify off feedback off pages 58
ttitle 'IOT Table Report'
spool iot_rep.lst
select
	OWNER,                          
	TABLE_NAME,                     
	TABLESPACE_NAME,                              
	IOT_NAME,                       
	LOGGING,                                      
	PARTITIONED,                    
	IOT_TYPE
from 
	dba_tables 
where 
	owner like upper('%&&owner%')
        and iot_type is not null
UNION 
select
	OWNER,                          
	TABLE_NAME,                     
	TABLESPACE_NAME,                              
	IOT_NAME,                       
	LOGGING,                                      
	PARTITIONED,                    
	IOT_TYPE
from 
	dba_object_tables 
where 
	owner like upper('%&&owner%')
        and iot_type is not null;           
spool off
set verify on lines 80 pages 22 feedback on
ttitle off
undef owner
clear columns
