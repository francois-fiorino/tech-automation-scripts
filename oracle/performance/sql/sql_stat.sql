/*
===============================================================================
SCRIPT: sql_stat.sql
CATEGORIA: Oracle / performance/sql
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/sql_stat.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Classificar SQL por leituras físicas por linha segundo heurística histórica.

FUNCIONAMENTO DETALHADO
  Filtra DISK_READS por limiar; formata gets/reads por linha, totais e proporção DISK/(DISK+GETS+1).

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SQLAREA

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Rows=0 usa divisor um. DISK_READS/(DISK_READS+BUFFER_GETS+1) não é cache miss ratio, pois gets/reads não são conjuntos disjuntos. Contadores acumulados; texto é prefixo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE disk_reads = 1000
  @sql_stat.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Razões, totais, linhas, execuções, primeiro load e texto.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Terminador SQL restaurado antes do SPOOL OFF; ORDER BY usa razão numérica em vez de TO_CHAR para não ordenar lexicalmente. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col "buf/row" format A12
col "buffer" format A14
col "disk/row" format A12
col "disk" format a14
col "%disk" format a5
col "rows" format a10
col executions format 999,990 head "Executes"
col sql_text format a30 word_wrapped
set lines 132 pages 55
ttitle 'SQL Statistics'
spool sql_stat.lst
select
to_char(round(buffer_gets/(decode(rows_processed,0,1,
rows_processed))),'999,999,990') "buf/row",
  to_char(buffer_gets,'9,999,999,990') "buffer",
to_char(round(disk_reads/(decode(rows_processed,0,1,
rows_processed))),'999,999,990') "disk/row",
  to_char(disk_reads,'9,999,999,990') "disk",
  to_char(round(disk_reads/(disk_reads+buffer_gets+1)*100))||' %' 
"%disk",
  to_char(rows_processed,'9,999,990') "rows",
  executions,
  first_load_time "1st time",
  sql_text
from
  v$sqlarea
where disk_reads >&disk_reads
order by disk_reads/decode(rows_processed,0,1,rows_processed) desc; -- by 1 desc;
spool off
ttitle off
set lines 80
