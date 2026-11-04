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
  DROP/CREATE/TRUNCATE e ANALYZE são destrutivos/custosos; commits do fluxo mantidos. Requer SELECT adicional DBA_TABLESPACES. Índices particionados/ausentes e nome de INDEX_STATS precisam validação. TRUNC preserva a aproximação original de bytes usados por blocos; não é tamanho real alocado nem recomendação de rebuild. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

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
  Revisão complementar 038 (2026-11-04): Arquivo gerado dedicado evita sobrescrever o helper index_sz.sql. ANALYZE usa owner/índice citados. Conversão USED_SPACE/bytes por bloco usa DBA_TABLESPACES do índice, não DB_BLOCK_SIZE global; metadado ausente preserva linha com NULL. Casos de homologação: Dois tablespaces com blocos diferentes; nomes quoted; índice particionado; erro de ANALYZE; staging existente; arquivo gerado preexistente; parâmetros/colunas INDEX_STATS no alvo. Comentários/créditos históricos preservados. Não aprovado para implantação.

REFERÊNCIAS DA REVISÃO038
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/INDEX_STATS.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_TABLESPACES.html

AVISO DE RESPONSABILIDADE
AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de
qualquer utilização em produção. Sua execução é de responsabilidade do
profissional responsável pelo ambiente. Os mantenedores deste repositório não
se responsabilizam por indisponibilidade, perda de dados, alterações indevidas
ou outros impactos decorrentes de sua utilização.

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
set define on
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
spool brown_index_analysis_generated.sql
select 
        'drop table stat_temp;'||&&cr||
	'create table stat_temp as select * from index_stats;'||&&cr||
	'truncate table stat_temp;'  
from dual;
select	
	'analyze index "'||REPLACE(USER,'"','""')||'"."'||REPLACE(index_name,'"','""')||'"'||
        ' validate structure;'||&&cr||
	'insert into stat_temp select * from index_stats;'||&&cr||
	'commit;'
from user_indexes;
spool off
set feedback on termout on lines 80
set define off
set sqlcase mixed
start brown_index_analysis_generated.sql
insert into temp_size_table
select s.name,trunc(s.used_space/nullif(t.block_size,0))
from stat_temp s left join user_indexes i on i.index_name=s.name
left join dba_tablespaces t on t.tablespace_name=i.tablespace_name;
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
