/*
===============================================================================
SCRIPT: awr_get_keep_pool.sql
CATEGORIA: Oracle / Performance / Buffer Cache
ORIGEM: Coleção Oracle 2015

OBJETIVO
  Gerar comandos ALTER TABLE e ALTER INDEX sugerindo BUFFER_POOL KEEP para
  tabelas pequenas observadas em planos históricos com TABLE ACCESS FULL.

FUNCIONAMENTO
  Relaciona DBA_HIST_SQL_PLAN, DBA_HIST_SQLSTAT, DBA_TABLES e DBA_SEGMENTS
  para selecionar tabelas com menos de 50 blocos e buffer pool diferente de
  KEEP; em seguida, gera comandos para os índices das tabelas selecionadas.

PRÉ-REQUISITOS
  Permissões de consulta a DBA_HIST_SQL_PLAN, DBA_HIST_SQLSTAT,
  DBA_TABLES, DBA_SEGMENTS e DBA_INDEXES. Confirmar licenciamento
  aplicável ao acesso ao AWR/Diagnostics Pack.

EXECUÇÃO
  SQL> @awr_get_keep_pool.sql

SAÍDA ESPERADA
  Texto contendo instruções ALTER TABLE / ALTER INDEX; o script apenas
  imprime os comandos e NÃO os executa automaticamente.

RISCOS E LIMITAÇÕES
  Os comandos gerados ALTERAM atributos de armazenamento caso executados.
  A escolha do KEEP pool não deve ser feita apenas por tamanho de segmento;
  avaliar configuração DB_KEEP_CACHE_SIZE, uso real e impacto na memória.
  A consulta usa junções legadas e pode multiplicar linhas; revisar resultados.
  A sintaxe original foi preservada. Compatibilidade não homologada.

AVISO DE RESPONSABILIDADE
  Revisar o código e testar em ambiente controlado antes de executar.
  Fornecido AS IS, sem garantias; uso por conta e risco do executor.
  Os mantenedores não assumem responsabilidade por perdas ou danos
  decorrentes do uso, nos limites permitidos pela legislação aplicável.

STATUS: análise estática; não executado em banco Oracle.
===============================================================================
*/

 /*  */
select 
   'alter table '||p.owner||'.'||p.name||' storage (buffer_pool keep);'
from 
   dba_tables   t,
   dba_segments s,
   dba_hist_sqlstat a,
   (select distinct 
     pl.sql_id,
     pl.object_owner owner, 
     pl.object_name name
   from 
      dba_hist_sql_plan pl
   where 
      pl.operation = 'TABLE ACCESS'
      and
      pl.options = 'FULL') p
where 
   a.sql_id = p.sql_id
   and
   t.owner = s.owner
   and
   t.table_name = s.segment_name
   and
   t.table_name = p.name
   and
   t.owner = p.owner
   and
   t.owner not in ('SYS','SYSTEM')
   and
   t.buffer_pool <> 'KEEP'
having
   s.blocks < 50
group by 
   p.owner, p.name, t.num_rows, s.blocks
UNION
-- ***********************************************************
 
-- Next, get the index names
 
-- ***********************************************************
select 
   'alter index '||owner||'.'||index_name||' storage (buffer_pool keep);'
from 
   dba_indexes
where
   owner||'.'||table_name in
(
select 
   p.owner||'.'||p.name
from 
   dba_tables        t,
   dba_segments      s,
   dba_hist_sqlstat  a,
   (select distinct 
     pl.sql_id,
     pl.object_owner owner, 
     pl.object_name name
   from 
      dba_hist_sql_plan pl
   where 
      pl.operation = 'TABLE ACCESS'
      and
      pl.options = 'FULL') p
where 
   a.sql_id = p.sql_id
   and
   t.owner = s.owner
   and
   t.table_name = s.segment_name
   and
   t.table_name = p.name
   and
   t.owner = p.owner
   and
   t.owner not in ('SYS','SYSTEM')
   and
   t.buffer_pool <> 'KEEP'
having
   s.blocks < 50
group by 
   p.owner, p.name, t.num_rows, s.blocks
)
