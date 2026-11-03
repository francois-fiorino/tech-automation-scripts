/*
===============================================================================
SCRIPT: co_lo_ind2.sql
CATEGORIA: Oracle / objects/indexes
ORIGEM: Oracle Script Collection 2015 / _index_scripts/co_lo_ind2.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar índices no tablespace da tabela, incluindo PERFSTAT quando atende ao filtro.

FUNCIONAMENTO DETALHADO
  Compara tablespaces de DBA_INDEXES e DBA_TABLES por TABLE_OWNER/TABLE_NAME e preserva a lista de owners excluídos da variante 2.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_INDEXES, DBA_TABLES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Variante funcional distinta de co_lo_ind: PERFSTAT não é excluído. Não representa topologia física nem recomenda separar dados/índices sem diagnóstico. Partições requerem análise própria.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @co_lo_ind2.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, índice, tablespace, tabela e tipo.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  I.TABLE_OWNER corrige vínculo de tabela em outro schema; ORDER BY qualificado sem alterar exclusões. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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

-- comment:  Indexes Co-Located With Data
col owner format a10
col tablespace_name format a10
col table_name format a30
set lines 132 pages 47
ttitle 'Indexes Co-Located With Data'
spool co_lo_ind2.lst
select i.owner, i.index_name, i.tablespace_name,i.table_name,i.index_type
from dba_indexes i, dba_tables t where
i.owner not in
('SYS','SYSTEM','DBAUTIL','OUTLN','SCOTT','RMAN','WEBDB','DBSNMP','OAS_PUBLIC','PUBLIC','CTXSYS')
and (i.table_name=t.table_name and i.table_owner=t.owner and i.tablespace_name=t.tablespace_name)
order by i.owner,i.index_name
/
spool off
ttitle off
set lines 80
