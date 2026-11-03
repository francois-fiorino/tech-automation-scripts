/*
===============================================================================
SCRIPT: brown.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _index_scripts/BROWN.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar/coletar estatísticas estruturais de índices e relatar deleted leaf bytes.

FUNCIONAMENTO DETALHADO
  Gera INDEX_SZ.SQL com DROP/CTAS/TRUNCATE STAT_TEMP, ANALYZE VALIDATE por USER_INDEXES, INSERT/COMMIT; executa e insere staging TEMP_SIZE_TABLE.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$PARAMETER, USER_INDEXES, INDEX_STATS, STAT_TEMP, TEMP_SIZE_TABLE, DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DDL destrutivo, ANALYZE pode bloquear/consumir I/O, commits por índice. Campos de INDEX_STATS e DB_BLOCK_SIZE precisam validação por tablespace. Percentual browned não justifica rebuild automático; DISTINCTIVENESS é heurística.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente revisão em schema descartável sem STAT_TEMP valiosa.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Arquivos gerados, staging persistente e razão de bytes leaf deletados.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Comentário #accept convertido em REM para evitar execução inválida; fluxo administrativo preservado. 
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

-- comment: index fragmemtation report
rem  **************************************************************************
rem
rem  NAME: brown.sql
rem  INPUTS:  owner = Table owner name.
rem  **************************************************************************

column value noprint new_value blocksize
define cr=chr(10)
define quote=chr(39)
select value from v$parameter where name='db_block_size';
REM accept tab_owner prompt 'Enter Table Owner for Indexes:'
set heading off verify off termout off pages 0 recsep 0 feedback off
spool index_sz.sql
select 
        'drop table stat_temp;'||&&cr||
	'create table stat_temp as select * from index_stats;'||&&cr||
	'truncate table stat_temp;'  
from dual;
select	
	'analyze index '||index_name||
        ' validate structure;'||&&cr||
	'insert into stat_temp select * from index_stats;'||&&cr||
	'commit;'
from user_indexes;
spool off
set feedback on termout on lines 80
start index_sz.sql
insert into temp_size_table select name,trunc(used_space/&&blocksize)
from stat_temp;
rem drop table stat_temp;
clear columns
set lines 132 pages 55
column del_lf_rows_len format 999,999,999 heading 'Deleted Bytes'
column lf_rows_len format 999,999,999 heading 'Filled Bytes'
column browning format 999.90 heading 'Percent|Browned'
ttitle "Index Browning Report"
spool brown.lst
select 
	name,del_lf_rows_len,lf_rows_len,
	(del_lf_rows_len/decode((lf_rows_len+del_lf_rows_len),0,1,
       lf_rows_len+del_lf_rows_len))*100 browning
            , (LF_ROWS-DISTINCT_KEYS)*100/ decode(LF_ROWS,0,1,LF_ROWS) DISTINCTIVENESS 
from 
	stat_temp 
where 
	del_lf_rows_len>0;
spool off
