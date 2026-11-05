/*
===============================================================================
SCRIPT: user_blocks_used_v_alloc.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/user_blocks_used_v_alloc.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Coletar contagens de tabelas e INDEX_STATS para comparar alocado/usado.

FUNCIONAMENTO DETALHADO
  Limpa staging, gera/START INDEX_SZ com CREATE STAT_TEMP e ANALYZE/INSERT/COMMIT, gera/executa FILL_SZ e apaga arquivo SO; limpa staging ao final.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS de criação/execução/consulta e permissões administrativas
  conforme limitações; não instalar variantes sobre objetos de trabalho.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_SEGMENTS, DBA_INDEXES, INDEX_STATS, STAT_TEMP, TEMP_SIZE_TABLE, V$PARAMETER, DBMS_ROWID

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DDL/commits parciais, bloqueios ANALYZE e I/O de scans. Relatório não filtra owner e chaves de staging sem owner podem multiplicar dados. ROWID restrito e DB_BLOCK_SIZE padrão não dão tamanho exato multiblock.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema descartável Windows; não executar sobre dados/índices reais.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tabelas de staging alteradas, estatística estrutural e relatório.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: DDL/DML, staging, autenticação ou efeitos da saída
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Arquivo HOST DEL corrigido de fill_size_table.sql para fill_sz.sql e NULLIF no percentual; todo fluxo preservado. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 044 — 04/11/2026
  Correções e melhorias: Interrupção SQL no script e no INDEX_SZ gerado antes de CREATE/TRUNCATE STAT_TEMP.
  Limitações e pendências: DELETEinicial e DDL podem confirmar dados; chavessemowner, ROWIDrestrito e blocksizepadrão misturam identidade. Nomes/macros semescaping e STARTautomático continuam impedindo uso seguro.
  Homologação necessária: STAT_TEMPpreexistente deve interromper antes deTRUNCATE; ownershomônimos, multiblocksize e arquivoSQLpreexistente; não usar resultado para shrink.
  Parâmetros/execução: contratos descritos acima e no corpo; somente laboratório.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  submissão de jobs, backup/recovery, Shell/Windows/VMS ou coleta de credenciais.

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


rem  comment:  Will show actual block used vs allocated for all tables for a user.
 
rem  INPUTS:  owner = Table owner name.
rem  requires temp_size_table table_name (varchar2(64), blocks number)be created.
rem  **************************************************************************
accept owner prompt 'Enter table owner name: '
set heading off feedback off verify off echo off recsep off pages 0
column db_block_size new_value blocksize noprint
ttitle off
define cr='chr(10)'
define qt='chr(39)'
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
delete temp_size_table;
select value db_block_size from v$parameter where name='db_block_size';
SPOOL fill_sz.sql
SELECT 'INSERT INTO temp_size_table'||&&cr||
	 'SELECT '||&&qt||segment_name||&&qt||&&cr||
	 ',COUNT( DISTINCT( SUBSTR( dbms_rowid.rowid_to_restricted(ROWID,1),1,8))) blocks'||&&cr||
        'FROM &&owner..'||segment_name, ';'
  FROM dba_segments
 WHERE segment_type ='TABLE' AND owner = upper('&owner');
SPOOL OFF
spool index_sz.sql
select 'whenever sqlerror exit failure rollback' from dual;
select 'create table stat_temp storage (initial 1m next 1m) as select * from index_stats ;'||&&cr||
'truncate table stat_temp;'  
from dual;
select	
'analyze index '||owner||'.'||index_name||' validate structure;'||&&cr||
'insert into stat_temp select * from index_stats;'||&&cr||
'commit;'
from dba_indexes
where owner=upper('&owner');
spool off
set feedback on termout on lines 132
start index_sz.sql
insert into temp_size_table select name,trunc(used_space/&&blocksize)
from stat_temp;
rem drop table stat_temp;
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
start title132 "Actual Size Report for &owner"
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
delete temp_size_table;
set termout on feedback 15 verify on pagesize 20 linesize 80 space 1
undef qt
undef cr
ttitle off
clear columns 
clear computes
pause press enter to continue

