/*
===============================================================================
SCRIPT: cons_rep2.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/cons_rep2.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar colunas de primary/foreign keys do usuário atual.

FUNCIONAMENTO DETALHADO
  Une USER_CONSTRAINTS e USER_CONS_COLUMNS por owner/nome/tabela, filtra P/R e ordena colunas pela posição.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  USER_CONSTRAINTS, USER_CONS_COLUMNS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não mostra colunas da chave referenciada nem status/validação. USER_CONSTRAINTS tem OWNER; acesso é ao schema corrente. FK composta precisa de ordem de posição para interpretar corretamente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @cons_rep2.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tabela, constraint, tipo, DELETE_RULE e COLUMN_NAME.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  TABLE_NAME adicionado ao join e ORDER BY inclui CONSTRAINT_NAME/POSITION; restante preservado. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Wrapper externo substituído por TTITLE local.
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
set pages 0 verify off feedback off 
column table_name format a20
column constraint_name format a25
column type format a15
column delete_rule format a15
column column_name format a15
ttitle "Constraint Report"
spool cons_rep2.lst
select a.table_name,a.constraint_name,decode (constraint_type,'P', 'Primary',
'R', 'Foreign Key') type, delete_rule, column_name from
user_constraints a, user_cons_columns b where
constraint_type in ('P','R') and
a.owner=b.owner and
a.constraint_name=b.constraint_name
and a.table_name=b.table_name
order by a.table_name,a.constraint_type,a.constraint_name,b.position
/
spool off

