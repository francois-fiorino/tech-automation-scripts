/*
===============================================================================
SCRIPT: recycle_pool_obj.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/recycle_pool_obj.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar tabelas e índices configurados para RECYCLE com estimativa de tamanho por estatísticas.

FUNCIONAMENTO DETALHADO
  Obtém DB_BLOCK_SIZE; combina via UNION tabelas BUFFER_POOL=RECYCLE com BLOCKS e índices com LEAF_BLOCKS; calcula MiB e totaliza no cliente.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$PARAMETER, DBA_TABLES, DBA_INDEXES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Usa tamanho padrão de bloco; omite OWNER e tipo, UNION pode colapsar homônimos. LEAF_BLOCKS exclui parte dos blocos do índice; estatísticas podem estar desatualizadas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @recycle_pool_obj.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OBJECT e MEG estimados por estatísticas; não são buffers residentes ou espaço alocado preciso.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  SQL original preservado; SPOOL local com nome recycle_pool_obj evita nome histórico keep_pool_obj confuso. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col value noprint new_value block_size
select value from v$parameter where name='db_block_size';
ttitle 'RECYCLE Pool Objects'
break on report
compute sum of meg on report
spool recycle_pool_obj.lst
select table_name object, blocks*&&block_size/(1024*1024) meg from dba_tables where buffer_pool='RECYCLE'
union
select index_name object, leaf_blocks*&&block_size/(1024*1024) meg from dba_indexes where buffer_pool='RECYCLE'
/
spool off
ttitle off
clear computes
clear breaks
