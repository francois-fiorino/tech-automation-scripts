/*
===============================================================================
SCRIPT: fkeylist.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/FKEYLIST.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relacionar colunas de foreign keys com colunas das chaves referenciadas.

FUNCIONAMENTO DETALHADO
  Associa constraints C/R por owner/nome referenciado e colunas CC/RC por posição; exclui SYS/SYSTEM do lado FK.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_CONSTRAINTS, DBA_CONS_COLUMNS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não mostra status, validação ou DELETE_RULE. Homônimos exigem considerar owners, inclusive R_OWNER que não é exibido.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @fkeylist.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tabela/constraint/coluna da FK e tabela/coluna referenciada; owners usados na quebra.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  AND duplicado removido; TABLE_NAME incluído nas junções às colunas sem alterar pareamento por POSITION. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Título convertido em TTITLE local.
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


rem  **************************************************************************
rem  NAME: FKEYLIST.sql     
rem
rem  comment: This routine prints a report of all foreign keys defined in the data dictionary (for owners other than SYS and SYSTEM).  As  written, it must be run by a DBA.  By changing the query to run against ALL_CONSTRAINTS, etc. it could be used by any user to see the foreign keys which are "available" to them.
rem  **************************************************************************
SET LINES 130 PAGES 56
rem
COLUMN OWNER  				FORMAT A10  NOPRINT NEW_VALUE OWNER_VAR
COLUMN TABLE_NAME    			FORMAT A24  HEADING'TABLE NAME'
COLUMN REF_TABLE         			FORMAT A24  HEADING'REF TABLE'
COLUMN R_OWNER           			FORMAT A10  NOPRINT
COLUMN CONSTRAINT_NAME  		FORMAT A30  HEADING 'CONST NAME'
COLUMN R_CONSTRAINT_NAME		FORMAT A30  NOPRINT
COLUMN COLUMN_NAME       			FORMAT A20  HEADING'COLUMN'
COLUMN REF_COLUMN       			FORMAT A20  HEADING'REF COLUMN'
rem
ttitle "FOREIGN KEY REPORT"
rem
BREAK ON OWNER SKIP PAGE ON TABLE_NAME SKIP 1 -
            ON CONSTRAINT_NAME ON REF_TABLE
spool fkeylist.lst
rem
SELECT 
	C.OWNER, 
	C.TABLE_NAME, 
	C.CONSTRAINT_NAME,
  	CC.COLUMN_NAME,
      	R.TABLE_NAME REF_TABLE, 
	RC.COLUMN_NAME REF_COLUMN
  FROM 
	DBA_CONSTRAINTS C, 
      	DBA_CONSTRAINTS R, 
        	DBA_CONS_COLUMNS CC,
         	DBA_CONS_COLUMNS RC
 WHERE 
	C.CONSTRAINT_TYPE = 'R' 
	AND C.OWNER NOT IN ('SYS','SYSTEM')
   	AND C.R_OWNER = R.OWNER 
   	AND C.R_CONSTRAINT_NAME = R.CONSTRAINT_NAME
   	AND C.CONSTRAINT_NAME = CC.CONSTRAINT_NAME
   	AND C.OWNER = CC.OWNER
        AND C.TABLE_NAME=CC.TABLE_NAME 
   	AND R.CONSTRAINT_NAME = RC.CONSTRAINT_NAME
   	AND R.OWNER = RC.OWNER
        AND R.TABLE_NAME=RC.TABLE_NAME 
	AND CC.POSITION = RC.POSITION
ORDER BY 
	C.OWNER, 
	C.TABLE_NAME, 
	C.CONSTRAINT_NAME, 
	CC.POSITION;
SPOOL OFF
clear breaks
clear columns
ttitle off
set lines 80 pages 22
