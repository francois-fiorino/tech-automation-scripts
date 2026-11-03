/*
===============================================================================
SCRIPT: cpu.sql
CATEGORIA: Oracle / performance/sql
ORIGEM: Oracle Script Collection 2015 / _os_scripts/cpu.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir vinte áreas SQL com maior CPU acumulada.

FUNCIONAMENTO DETALHADO
  Ordena V$SQLAREA por CPU_TIME e DISK_READS e aplica ROWNUM<21; converte CPU_TIME/ELAPSED_TIME para segundos.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SQLAREA

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Acumulado de parse/exec/fetch de todas as execuções; não mede CPU instantânea do host. Tempo paralelo pode somar trabalho de processos. Texto é prefixo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @cpu.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Texto, CPU_TIME e ELAPSED_TIME em segundos, leituras, gets e linhas processadas.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Divisor 1000000000 incorreto trocado por 1000000, pois as colunas são microssegundos. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem cpu.sql
rem 7/nov  Mike Ault Initial creation
rem
column sql_text format a40 word_wrapped heading 'SQL|Text'
column cpu_time heading 'CPU|Time'
column elapsed_time heading 'Elapsed|Time'
column disk_reads heading 'Disk|Reads'
column buffer_gets heading 'Buffer|Gets'
column rows_processed heading 'Rows|Processed'
set pages 55 lines 132
ttitle 'SQL By CPU Usuage'
spool cpu.lst
select * from 
(select sql_text,cpu_time/1000000 cpu_time,elapsed_time/1000000 elapsed_time, 
disk_reads, buffer_gets, rows_processed 
from v$sqlarea order by cpu_time desc, disk_reads desc) 
where rownum<21
/
spool off
set pages 22 lines 80
ttitle off
