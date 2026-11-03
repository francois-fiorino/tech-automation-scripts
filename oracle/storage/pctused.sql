/*
===============================================================================
SCRIPT: pctused.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _table_scripts/pctused.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar sugestões históricas de PCTUSED/PCTFREE com base em tamanho médio de linha.

FUNCIONAMENTO DETALHADO
  Define SPARE_ROWS=2 e DB_BLOCK_SIZE, filtra AVG_ROW_LEN e ausência de tipos LOB/RAW, imprime ALTER TABLE em pctused.lst.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES, DBA_TAB_COLUMNS, V$PARAMETER

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Heurística com divisor bloco/10 não é cálculo canônico de percentual de bytes e ignora overhead. Bloco padrão pode diferir do tablespace; PCTUSED não se aplica a ASSM. Não usar sugestão como tuning automático.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @pctused.sql
  -- Revisar pctused.lst; não executar comandos gerados automaticamente.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Texto ALTER TABLE, sem execução DDL pelo gerador.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Exclusão de tipos por nome global substituída por NOT EXISTS correlacionado em owner/tabela, evitando excluir homônimos de outros schemas. Fórmula histórica preservada para revisão. 
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
rem pctused.sql
set heading off;
set pages 9999;
set feedback off;

spool pctused.lst;
column db_block_size new_value blksz noprint
select value db_block_size from v$parameter where name='db_block_size';

define spare_rows = 2;

select
   ' alter table '||owner||'.'||table_name||
   ' pctused '||least(round(100-((&spare_rows*avg_row_len)/(&blksz/10))),95)||
   ' '||
   ' pctfree '||greatest(round((&spare_rows*avg_row_len)/(&blksz/10)),5)||
   ';'
from
   dba_tables t
where 
avg_row_len > 1
and 
avg_row_len < .5*&blksz
and
not exists
 (select 1 from dba_tab_columns b
   where b.owner=t.owner and b.table_name=t.table_name
 and b.data_type in ('RAW','LONG RAW','BLOB','CLOB','NCLOB')
 )
order by 
   owner, 
   table_name
;

spool off;
