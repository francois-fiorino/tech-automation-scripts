/*
===============================================================================
SCRIPT: get_sql_text.sql
CATEGORIA: Oracle / performance/sql
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/get_sql_text.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar métricas médias arredondadas de SQL cujo texto contém fragmento.

FUNCIONAMENTO DETALHADO
  Filtra SQLAREA por LIKE e divide contadores por GREATEST(EXECUTIONS,1), aplicando CEIL.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SQLAREA

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  EXECUTIONS=0 usa divisor um e não constitui média de execução concluída. Tempos não estão em segundos; acumulados do cursor e CEIL perde frações. LIKE pode incluir próprio relatório, comentários e literais.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE sub_str = SELECT
  @get_sql_text.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Texto, execuções, tempos CPU/elapsed em microssegundos por divisor, I/O/gets/linhas/sorts/parse e bytes de memória.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada; unidades e divisor explicitados. 
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
col sql_text format a40 word_wrapped heading 'SQL|Text'
col executions heading 'Executions'
col ave_cpu_time heading 'AVE|CPU|TIME'
col ave_elapsed_time heading 'AVE|ELAP|TIME'
col ave_disk_reads heading 'AVE|Disk|Reads'
col per_mem heading 'Per.|Mem'
col run_mem heading 'Run.|Mem'
col ave_sorts heading 'AVE|Sorts'
col ave_parse_calls heading 'AVE|Parse|Calls'
col ave_buffer_gets heading 'AVE|Buff|Gets'
col ave_row_proc heading 'AVE|Row|Proc.'
set lines 132 pages 1000
SELECT
sql_text, executions,
ceil(cpu_time/greatest(executions,1)) ave_cpu_time,
ceil(elapsed_time/greatest(executions,1)) ave_elapsed_time,
ceil(disk_reads/greatest(executions,1)) ave_disk_reads,
persistent_mem per_mem, runtime_mem run_mem,
ceil(sorts/greatest(executions,1)) ave_sorts,
ceil(parse_calls/greatest(executions,1)) ave_parse_calls,
ceil(Buffer_gets/greatest(executions,1)) ave_buffer_gets,
ceil(rows_processed/greatest(executions,1)) ave_row_proc
FROM
v$sqlarea
WHERE
Sql_text like '%&sub_str%'
/
