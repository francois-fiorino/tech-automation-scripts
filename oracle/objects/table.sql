/*
===============================================================================
SCRIPT: table.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/TABLE.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar atributos de tabelas fora de SYS/SYSTEM.

FUNCIONAMENTO DETALHADO
  Consulta DBA_TABLES, com flags de particionamento, IOT/nested/temporária e storage histórico.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_TABLES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Tabela particionada/IOT pode ter tablespace/extent NULL. NEXT/PCT_INCREASE são históricos e não comandam crescimento em todos os LMT. Não mede espaço real.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @table.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, tablespace, tabela, extents e flags.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  SQL preservado; spool específico do arquivo. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Título convertido em TTITLE local.
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
REM NAME        : TABLE.SQL
REM FUNCTION    : GENERATE TABLE REPORT
REM Limitations : None
clear COLUMNs
COLUMN owner		 FORMAT a15	HEADING 'Table | Owner'
COLUMN table_name        FORMAT a18     HEADING Table
COLUMN tablespace_name   FORMAT A13 	HEADING Tablespace
COLUMN pct_increase 			HEADING 'Pct|Increase'
COLUMN init				HEADING 'Initial|Extent'
COLUMN next				HEADING 'Next|Extent'
COLUMN partitioned	 FORMAT a4	HEADING 'Par?'
COLUMN iot_type          FORMAT a4      HEADING 'Iot?'
COLUMN nested            FORMAT a5      HEADING 'Nest?'
COLUMN temporary         FORMAT a5      HEADING 'Temp?'
BREAK ON owner ON tablespace_name
SET PAGES 48 LINES 132
ttitle "ORACLE TABLE REPORT"
spool table.lst
SELECT 
	owner,
	tablespace_name,
	table_name,
	initial_extent Init,
	next_extent Next,
	pct_increase,
	partitioned,
        DECODE(iot_type,NULL,'No','Yes') iot_type,
        nested,
	DECODE(temporary,'N','No','Yes') temporary
FROM 
	sys.dba_tables
WHERE 
	owner NOT IN  ('SYSTEM','SYS')
ORDER BY 
	owner,
	tablespace_name,
	table_name;
SPOOL OFF
CLEAR COLUMNS
PAUSE Press enter to continue
SET PAGES 22 LINES 80
TTITLE OFF
CLEAR COLUMNS
CLEAR BREAKS

