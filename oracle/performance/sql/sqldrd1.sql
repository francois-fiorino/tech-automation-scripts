/*
===============================================================================
SCRIPT: sqldrd1.sql
CATEGORIA: Oracle / performance/sql
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/sqldrd1.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar SQL com DISK_READS acima de 10000 e texto completo disponível.

FUNCIONAMENTO DETALHADO
  Mantém filtro de owners e junção SQLAREA/USERS; usa SQL_FULLTEXT diretamente no lugar de função externa inexistente.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SQLAREA, DBA_USERS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Oracle 10g+ para SQL_FULLTEXT. SET LONG limita exibição a um milhão de caracteres e aumenta volume/risco de exposição. Nenhum SQL do texto é executado.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @sqldrd1.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Usuário, execuções, sorts/comando, leituras e CLOB SQL_FULLTEXT.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  GET_TEXT não fornecida substituída por SQL_FULLTEXT, preservando finalidade de texto completo; SET LONG acrescentado. Filtros e ordenação mantidos. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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

set long 1000000 longchunksize 32767
/*  */
REM Name: sqldrd.sql
REM Function: return the sql statements from the shared area with
REM Function: highest disk reads
REM History: Presented in paper 35 at IOUG-A 1997, converted for
REM use 6/24/97 MRA
REM
DEFINE access_level = 10000 (NUMBER)
COLUMN username FORMAT a10 HEADING 'User Name'
COLUMN executions 	FORMAT 999,999 	 HEADING 'Exec'
COLUMN sorts 		FORMAT 99999 	 HEADING 'Sorts'
COLUMN command_type 	FORMAT 99999 	 HEADING 'CmdT'
COLUMN disk_reads 	FORMAT 999,999,999 HEADING 'Block Reads'
COLUMN sql_text 	FORMAT a70 	HEADING 'Statement' WORD_WRAPPED
SET LINES 130 VERIFY OFF FEEDBACK OFF pages 50 trimspool on
ttitle 'SQL Statements With High Reads'
spool sqldrd1.lst
SELECT
 b.username, a.executions,
 a.sorts,a.command_type,
 a.disk_reads, a.sql_fulltext sql_text
FROM
 v$sqlarea a, dba_users b
WHERE
        a.parsing_user_id=b.user_id
        and b.username not in ('SYS','SYSTEM','DBAUTIL','OUTLN','SCOTT','RMAN','WEBDB','DBSNMP','OAS_PUBLIC','PUBLIC')
        and a.disk_reads > &&access_level
order by disk_reads desc
/
SPOOL OFF
SET LINES 80 VERIFY ON FEEDBACK ON
