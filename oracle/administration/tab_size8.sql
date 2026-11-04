/*
===============================================================================
SCRIPT: tab_size8.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _table_scripts/tab_size8.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Coletar blocos com linhas de tabelas de vários owners e comparar com segmentos.

FUNCIONAMENTO DETALHADO
  DELETE staging, gera/START FILL_SZ com COUNT por ROWID restrito, HOST DEL e relatório por nome/tipo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS de criação/execução/consulta e permissões administrativas
  conforme limitações; não instalar variantes sobre objetos de trabalho.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  TEMP_SIZE_TABLE, DBA_SEGMENTS, V$PARAMETER, DBMS_ROWID, SQL*Plus HOST

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Full scans de múltiplos schemas, nomes sem escaping e arquivo executado/apagado. Prefixo de ROWID pode colidir e staging sem owner mistura homônimos; label BLOCKSIZE K está incorreto em unidade. Não é HWM ou ocupação física exata.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente staging/tabelas descartáveis; revisar owner/nomes antes.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  INSERTs executados e relatório; staging permanece preenchido pois DELETE final está comentado.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: DDL/DML, staging, autenticação ou efeitos da saída
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF no percentual; fluxo, exceções de owners e créditos IOUG/Manton/Brouillette/Ault mantidos, com pendências de identidade explícitas. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 040 — 04/11/2026
  Correções e melhorias: Fluxo integral preservado; medição não homologada.
  Limitações e pendências: Mistura homônimos sem owner, ROWID restrito pode colidir, BLOCKSIZE K representa bytes incorretamente e macros DB/OWNER vêm de contexto externo. DELETE/START/DEL e tabela compartilhada alteram estado.
  Homologação necessária: Dois owners/arquivos, block sizes diferentes e falha de START; não usar resultado para shrink/rebuild.
  Parâmetros e execução: contrato detalhado acima e no corpo; somente laboratório.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  sem Windows, exportação, job ou comando administrativo executado.

AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de qualquer utilização em produção. Sua execução é de responsabilidade do profissional responsável pelo ambiente. Os mantenedores deste repositório não se responsabilizam por indisponibilidade, perda de dados, alterações indevidas ou outros impactos decorrentes de sua utilização.

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
rem  **************************************************************************
rem
rem  NAME: ACT_SIZE8.sql
rem
rem  HISTORY:
rem  Date             Who              What
rem  --------  -------------------  ------------------------------------------
rem  09/??/90  Maurice C. Manton    Creation for IOUG
rem  12/23/92  Michael Brouillette  Assume TEMP_SIZE_TABLE exists.Use DBA info.
rem				    Prompt for user name. Spool file = owner.
rem   07/15/96  Mike Ault	Updated for Oracle 7.x
rem   02/24/00  Mike Ault     Updated for Oracle 8.x
rem  FUNCTION:  Will show actual block used vs allocated for all tables for a
rem	        user. 
rem  INPUTS:  owner = Table owner name.
rem  requires temp_size_table table_name (varchar2(64), blocks number)be created.
rem  **************************************************************************
rem accept owner prompt 'Enter table owner name: '
set heading off feedback off verify off echo off recsep off pages 0
column db_block_size new_value blocksize noprint
ttitle off
define cr='chr(10)'
define qt='chr(39)'
delete temp_size_table;
select value db_block_size from v$parameter where name='db_block_size';
SPOOL fill_sz.sql
select 'INSERT INTO temp_size_table'||&&cr||
       'SELECT '||&&qt||segment_name||&&qt||&&cr||
       ',COUNT( DISTINCT( SUBSTR( dbms_rowid.rowid_to_restricted(ROWID,1),1,8))) blocks'||&&cr||
       'FROM '||owner||'.'||segment_name||';'
  FROM dba_segments
 WHERE segment_type ='TABLE' AND owner not in ('SYS','SYSTEM','MDSYS','CTXSYS','OUTLN','Burleson Consulting');
SPOOL OFF
DEFINE temp_var = &&qt;
START fill_sz
HOST del  fill_sz.sql
define bs = '&&blocksize K'
COLUMN t_date NOPRINT new_value t_date
COLUMN user_id NOPRINT new_value user_id
COLUMN segment_name FORMAT A25 HEADING "SEGMENT|NAME"
COLUMN segment_type FORMAT A7 HEADING "SEGMENT|TYPE"
COLUMN extents FORMAT 999 HEADING "EXTENTS"
COLUMN kbytes FORMAT 999,999,999 HEADING "KILOBYTES"
COLUMN blocks FORMAT 9,999,999 HEADING "ALLOC.|&&bs|BLOCKS"
COLUMN act_blocks FORMAT 9,999,990 HEADING "USED|&&bs|BLOCKS"
COLUMN pct_block FORMAT 999.99 HEADING "PCT|BLOCKS|USED"
set lines 132
start title132 "Actual Size Report"
set pages 55
break on report on segment_type skip 1
compute sum of kbytes on segment_type report 
SPOOL rep_out\&db\&owner
SELECT segment_name, segment_type,sum(extents) extents, sum(bytes)/1024 kbytes, 
       sum(a.blocks) blocks,nvl(max(b.blocks),0) act_blocks, 
       (max(b.blocks)/nullif(sum(a.blocks),0))*100 pct_block
  FROM sys.dba_segments a, temp_size_table b
 WHERE segment_name = UPPER( b.table_name )
 GROUP BY segment_name, segment_type
 ORDER BY segment_type,segment_name;
SPOOL OFF
rem delete temp_size_table;
set termout on feedback 15 verify on pagesize 20 linesize 80 space 1
undef qt
undef cr
ttitle off
clear columns 
clear computes
pause press enter to continue

