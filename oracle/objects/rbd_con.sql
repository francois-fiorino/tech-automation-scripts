/*
===============================================================================
SCRIPT: rbd_con.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/RBD_CON.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar três scripts de drop/recriação de checks, chaves e FKs com índices.

FUNCIONAMENTO DETALHADO
  Consulta CONS_TEMP e USER_INDEXES para CK/PK/FK_RCT; gera drops, ALTER e CREATE INDEX conforme atributos coletados.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e privilégios administrativos conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  CONS_TEMP (customizada), USER_INDEXES, V$DATABASE, variável TABLESPACE_NAME

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CONS_TEMP deve existir com contrato correto. Default não é tipo de constraint de tabela recriável por CHECK genérico. Presume índice com nome da constraint; drops podem afetar integridade. Referência exige owner além de nome para homônimos; buffers/quoting/estado não cobrem todos os recursos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente revisão; validar staging por owner e nunca executar saída em produção.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Três arquivos de DDL destrutiva para constraints/índices.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: pode gerar ou executar DDL/DML, expor hashes/segredos
  do banco consultado ou alterar sessão conforme descrito acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Owner referenciado incluído no join final a CONS_TEMP para evitar FK apontar à chave homônima de outro schema; outros riscos preservados para homologação. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 042 — 04/11/2026
  Correções e melhorias: Pipeline de três arquivos integral preservado.
  Limitações e pendências: Contrato CONS_TEMP vem de variantes distintas; CHECK contendo NULL é omitido. Índice presumido por nome, owner e criação de FK renomeada exigem revisão; DROP INDEX pode falhar ou afetar objeto errado.
  Homologação necessária: Staging com dois owners, índice de nome distinto, FK cross-schema e CHECK legítimo com NULL; não aplicar saídas.
  Parâmetros e execução: contratos descritos acima e no corpo histórico.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  backup/recovery, comandos Windows/Unix ou uso de credenciais reais.

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
set heading off feedback off pages 0 termout on echo on
set recsep off verify off
set embedded on
define cr='chr(10)'
column x word_wrapped
column dbname new_value db noprint
select name dbname from v$database;
spool rep_out\&db\ck_rct.sql
select 'alter table '||a.table_name||&&cr||
'drop constraint '||a.constraint_name||';'||&&cr||
'alter table '||a.table_name||' add constraint '||a.constraint_name||&&cr||
constraint_type||'( '||a.search_condition||' )'||&&cr||
';' x
from cons_temp a where constraint_type in ( 'Check','Default' ) and
search_condition not like '%NULL%'
/
spool off
spool rep_out\&db\pk_rct.sql
select 'alter table '||a.table_name||&&cr||
'drop constraint '||a.constraint_name||';'||&&cr||
'drop index '||a.constraint_name||';'||&&cr||
'alter table '||a.table_name||' add constraint '||a.constraint_name||&&cr||
constraint_type||'( '||a.constraint_columns||' )'||&&cr||
'using index tablespace '||b.tablespace_name||&&cr||
'pctfree '||b.pct_free||&&cr||
'initrans '||b.ini_trans||&&cr||
'maxtrans '||b.max_trans||&&cr||
'storage ('||&&cr||
'initial '||b.initial_extent||&&cr||
'next '||b.next_extent||&&cr||
'minextents '||b.min_extents||&&cr||
'maxextents '||b.max_extents||&&cr||
'pctincrease '||b.pct_increase||&&cr||')'||&&cr||
';' x
from cons_temp a, user_indexes b where
a.constraint_type in ('Primary Key','Unique') and
a.constraint_name=b.index_name 
/
spool off
spool rep_out\&db\fk_rct.sql
select 'alter table '||a.table_name||&&cr||
'drop constraint '||a.constraint_name||&&cr||
';'||&&cr||
'drop index '||a.constraint_name||';'||&&cr||
'alter table '||a.table_name||' add constraint '||'FK_'||a.table_name||'_'||a.con_number||&&cr||
a.constraint_type||'( '||&&cr||
a.constraint_columns||' )'||&&cr||
'references '||a.referenced_owner||'.'||b.table_name||' ( '||&&cr||
b.constraint_columns||' ) '||&&cr||
decode (a.delete_rule,'CASCADE','on delete cascade','')||&&cr||
';'||&&cr||
'create index '||'FK_'||a.table_name||'_'||a.con_number||' on '||a.table_name||'( '||&&cr||
a.constraint_columns||') '||&&cr||
'tablespace &tablespace_name'||&&cr||
';' x
from cons_temp a, cons_temp b
where a.constraint_type = 'Foreign Key' and
a.referenced_constraint=b.constraint_name and a.referenced_owner=b.owner
/
spool off
set verify on
set feedback on
set termout on
set echo on
set pagesize 22
clear columns
clear breaks
undef cr
