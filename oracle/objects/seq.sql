/*
===============================================================================
SCRIPT: seq.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/SEQ.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar configuração e LAST_NUMBER de sequências selecionadas.

FUNCIONAMENTO DETALHADO
  Filtra DBA_SEQUENCES por owner/nome LIKE e exibe min/max/increment/cycle/order/cache.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_SEQUENCES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  LAST_NUMBER em sequência com cache não é último número entregue nem próximo garantido. Não chama NEXTVAL/CURRVAL nem reinicia sequência. ORDER não garante ausência de gaps.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @seq.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Configuração e LAST_NUMBER persistido no dicionário.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Heading de LAST_NUMBER esclarecido; consulta preservada. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem  NAME: Seq.sql
rem
rem  FUNCTION: Generate a report on sequences for an account
rem		
rem  INPUTS:
rem
rem			1 - Sequence Owner or Wild Card
rem			2 - Sequence Name or Wild Card
rem
rem  **************************************************************************
SET HEADING OFF VERIFY OFF PAUSE OFF
rem
PROMPT ** Sequence Report **
PROMPT
PROMPT Percent signs are wild
rem
ACCEPT sequence_owner prompt 'Enter Oracle account to report on (or wild):';
ACCEPT sequence_name prompt 'Enter object name to report on (or wild): ';
PROMPT
PROMPT Report file name is sequence_dbname.lis
rem
SET HEADING ON	
SET LINESIZE 130 PAGESIZE 56 NEWPAGE 0 TAB OFF SPACE 1 
SET TERMOUT OFF
BREAK ON SEQUENCE_OWNER SKIP 2
rem
COLUMN SEQUENCE_OWNER 	FORMAT A10	HEADING 'Sequence Owner'
COLUMN SEQUENCE_NAME		FORMAT A30	HEADING 'Sequence Name'
COLUMN MIN_VALUE					HEADING 'Minimum'
COLUMN MAX_VALUE					HEADING 'Maximum'
COLUMN INCREMENT_BY		FORMAT 9999	HEADING 'Incr.'
COLUMN CYCLE_FLAG        				HEADING 'Cycle'
COLUMN ORDER_FLAG					HEADING 'Order'
COLUMN CACHE_SIZE		FORMAT 99999	HEADING 'Cache'
COLUMN LAST_NUMBER					HEADING 'Last Value'
rem
ttitle "SEQUENCE REPORT"
spool seq.lst
rem
SELECT  
	SEQUENCE_OWNER, 
	SEQUENCE_NAME, 
	MIN_VALUE, 
	MAX_VALUE,
	INCREMENT_BY, 
	DECODE(CYCLE_FLAG,'Y','YES','N','NO') CYCLE_FLAG,
	DECODE(ORDER_FLAG,'Y','YES','N','NO') ORDER_FLAG,
	CACHE_SIZE, 
	LAST_NUMBER
FROM 	
	DBA_SEQUENCES
WHERE  
	SEQUENCE_OWNER LIKE UPPER('&SEQUENCE_OWNER') AND
	SEQUENCE_NAME LIKE UPPER('&SEQUENCE_NAME')
ORDER BY  
	1,2;
SPOOL OFF
pause Press Enter to continue
set echo on heading on verify on feedback on tab on lines 80 pages 22
set termout on
clear columns
ttitle off
                                                                                                                    
