/*
===============================================================================
SCRIPT: sql_stats.sql
CATEGORIA: Oracle / performance/sql
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/sql_stats.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Selecionar dez SQL de maior elapsed médio entre os que excedem limiares.

FUNCIONAMENTO DETALHADO
  Calcula CEIL de médias por GREATEST(EXECUTIONS,1), filtra por leitura/CPU/elapsed e limita após ordenação.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SQLAREA

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  GREATEST com zero gera proxy, não média de execução. Valores são desde carga; top dez sem desempate pode variar. Entradas de tempos são microssegundos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE disk_reads = 1000
  DEFINE cpu_time = 1000000
  DEFINE elapsed_time = 1000000
  @sql_stats.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Texto e médias CPU/elapsed em microssegundos, reads/sorts/gets/parse/linhas/aborts e bytes.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Ordenação ascendente de totais trocada por médias calculadas decrescentes para coerência com top SQL médio; todos os campos preservados. 
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
col ave_parse_calls heading 'Ave|Parse|calls' 
col ave_disk_reads heading 'Ave|Disk|Reads' 
col ave_buffer_gets heading 'Ave|Buffer|Gets' 
col ave_row_proc heading 'Ave|Rows|proc' 
col ave_ser_aborts heading 'Ave|Ser|Aborts' 
col ave_cpu_time heading 'Ave|CPU|Time' 
col ave_elapsed_time heading 'Ave|Elapsed|Time' 
col per_mem heading 'Per|Mem'
col run_mem heading 'Run|Mem'
col ave_sorts heading 'Ave|Sorts'

set lines 160 pages 55
SELECT * FROM(
SELECT
sql_text, 
ceil(cpu_time/greatest(executions,1)) ave_cpu_time, 
ceil(elapsed_time/greatest(executions,1)) ave_elapsed_time,
ceil(disk_reads/greatest(executions,1)) ave_disk_reads,
persistent_mem per_mem, runtime_mem run_mem, 
ceil(sorts/greatest(executions,1)) ave_sorts, 
ceil(parse_calls/greatest(executions,1)) ave_parse_calls,
ceil(Buffer_gets/greatest(executions,1)) ave_buffer_gets, 
ceil(rows_processed/greatest(executions,1)) ave_row_proc,
ceil(Serializable_aborts/greatest(executions,1)) ave_ser_aborts
FROM
v$sqlarea
WHERE
Disk_reads/greatest(executions,1)>&&disk_reads
OR
Cpu_time/greatest(executions,1)>&&cpu_time
OR
Elapsed_time/greatest(executions,1)>&&elapsed_time
order by ave_elapsed_time desc, ave_cpu_time desc, ave_disk_reads desc)
where rownum<11
/
