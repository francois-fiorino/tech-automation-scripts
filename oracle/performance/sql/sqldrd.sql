/*
===============================================================================
SCRIPT: sqldrd.sql
CATEGORIA: Oracle / performance/sql
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/sqldrd.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar SQL de usuários não excluídos com DISK_READS acima de 500.

FUNCIONAMENTO DETALHADO
  Une SQLAREA/USERS pelo usuário de parse, exclui owners históricos e ordena leituras decrescentes.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SQLAREA, DBA_USERS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Leituras acumuladas não significam latência nem I/O por execução. Lista de exclusão é histórica e pode ocultar carga relevante. Não é top N.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @sqldrd.sql
  -- DEFINE access_level no arquivo é 500; revisar cópia de laboratório para outro limiar.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Username, execuções, sorts, comando, leituras de blocos e prefixo SQL.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  ORDER BY descendente reflete intenção de maiores leituras; crédito IOUG-A 1997/MRA preservado. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
REM Name: sqldrd.sql
REM Function: return the sql statements from the shared area with
REM Function: highest disk reads
REM History: Presented in paper 35 at IOUG-A 1997, converted for
REM use 6/24/97 MRA
REM
DEFINE access_level = 500 (NUMBER)
COLUMN username FORMAT a10 HEADING 'User Name'
COLUMN executions 	FORMAT 999,999 	 HEADING 'Exec'
COLUMN sorts 		FORMAT 99999 	 HEADING 'Sorts'
COLUMN command_type 	FORMAT 99999 	 HEADING 'CmdT'
COLUMN disk_reads 	FORMAT 999,999,999 HEADING 'Block Reads'
COLUMN sql_text 	FORMAT a70 	HEADING 'Statement' WORD_WRAPPED
SET LINES 130 VERIFY OFF FEEDBACK OFF pages 50 trimspool on
ttitle 'SQL Statements With High Reads'
spool sqldrd.lst
SELECT 
	username, executions,
	sorts,command_type,
	disk_reads,sql_text
FROM 
	v$sqlarea, dba_users
WHERE 
        parsing_user_id=user_id and 
        username not in ('SYS','SYSTEM','DBAUTIL','OUTLN','SCOTT','RMAN','WEBDB','DBSNMP','OAS_PUBLIC','PUBLIC')
	and disk_reads > &&access_level
ORDER BY 
	disk_reads desc;
SPOOL OFF
SET LINES 80 VERIFY ON FEEDBACK ON
undef access_level

