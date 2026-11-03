/*
===============================================================================
SCRIPT: fk_indexes.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/fk_indexes.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar correspondências por coluna entre foreign keys e índices.

FUNCIONAMENTO DETALHADO
  Relaciona DBA_CONSTRAINTS, DBA_CONS_COLUMNS e DBA_IND_COLUMNS pelo schema, tabela e coluna, restringindo constraints R e excluindo owners históricos do original.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_CONSTRAINTS, DBA_CONS_COLUMNS, DBA_IND_COLUMNS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não comprova cobertura de FK composta nem posição líder no índice; não identifica FKs sem índice. Exigir análise por lista/posição de colunas para concluir cobertura. Filtro de schemas mantido.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @fk_indexes.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OWNER, CONSTRAINT_NAME, INDEX_NAME e CONSTRAINT_TYPE; uma associação por coluna, podendo repetir uma constraint.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Incluídas igualdades de OWNER/TABLE_NAME da constraint e TABLE_OWNER do índice; outer join parcial contraditório trocado por inner join que corresponde às demais condições existentes. 
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
set lines 132 pages 64 verify off feedback off
ttitle 'Foreign Key Indexes'
spool fk_indexes
select b.owner, b.constraint_name, c.index_name, a.constraint_type
from dba_constraints a, dba_cons_columns b, dba_ind_columns c
where a.constraint_type='R'
and a.owner not in ('SYS','SYSTEM','SCOTT','SYSMAN','ORDSYS','CTXSYS','ODM',
 'XDB','RMAN','ODSYS','CTXSYS','MDSYS','WKSYS','WMSYS')
and a.owner=b.owner
and a.table_name=b.table_name
and a.constraint_name=b.constraint_name
and b.column_name=c.column_name
and b.owner=c.table_owner
and a.table_name=c.table_name
/
spool off
set lines 80 verify on feedback on
