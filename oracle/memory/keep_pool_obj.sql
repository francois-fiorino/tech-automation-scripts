/*
===============================================================================
SCRIPT: keep_pool_obj.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/keep_pool_obj.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar tabelas e índices configurados para KEEP com estimativa baseada em estatísticas.

FUNCIONAMENTO DETALHADO
  Obtém DB_BLOCK_SIZE em V$PARAMETER; consulta tabelas BUFFER_POOL=KEEP usando BLOCKS e índices usando LEAF_BLOCKS; combina por UNION e totaliza MEG no cliente.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$PARAMETER, DBA_TABLES, DBA_INDEXES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  BLOCKS/LEAF_BLOCKS dependem de estatísticas; índice considera folhas, não todo segmento. Usa bloco padrão para todos, omite OWNER/tipo e UNION pode colapsar homônimos; total não deve dimensionar KEEP sozinho.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @keep_pool_obj.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OBJECT e MEG em MiB estimados; não é ocupação residente no KEEP cache.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  SQL e metodologia históricos preservados com limitações documentadas. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
ttitle 'KEEP Pool Objects'
break on report
compute sum of meg on report
spool keep_pool_obj.lst
select table_name object, blocks*&&block_size/(1024*1024) meg from dba_tables where buffer_pool='KEEP'
union
select index_name object, leaf_blocks*&&block_size/(1024*1024) meg from dba_indexes where buffer_pool='KEEP'
/
spool off
ttitle off
clear computes
clear breaks
