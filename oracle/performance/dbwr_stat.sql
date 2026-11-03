/*
===============================================================================
SCRIPT: dbwr_stat.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / misc_scripts/dbwr_stat.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Reunir contadores DBWR e buffer pools identificando block size.

FUNCIONAMENTO DETALHADO
  UNION de SYSSTAT/WAITSTAT e três esperas por pool com hit ratio e tamanho de bloco KiB no rótulo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SYSSTAT, V$WAITSTAT, V$BUFFER_POOL_STATISTICS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não somar valores de unidades diferentes. Razão acumulada não é diagnóstico suficiente de I/O; depende de nomes/colunas na versão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @dbwr_stat.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  NAME/STAT de unidades diversas; razão percentual e contadores por pool/bloco.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF protege gets zero. Parênteses já eram corretos nesta variante; não aplicadas correções de dbwr8_stat indevidamente. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem dbwr_stat.sql
rem Mike Ault - Burleson Consulting 11/09/01 Created
rem
col name format a46 heading 'DBWR Statistic'
col stat format 9,999,999,999,999 heading 'Statistic Value'
set pages 40
ttitle 'DBWR Statistic Report'
spool dbwr_stat.lst
select a.name,a.stat 
from  (select name, value stat from v$sysstat 
       where name not like '%redo%' and name not like '%remote%') a
where (a.name like 'DBWR%' or a.name like '%buffer%' or a.name like '%write%' or name like '%summed%') 
union
select class name, count "value" from v$waitstat where class='data block'
union 
select name||' '||to_char(block_size/1024)||' hit ratio' name, 
   round(((1 - (physical_reads / nullif(db_block_gets + consistent_gets,0))) * 100),3) stat
from V$buffer_pool_statistics
union 
select name||' '||to_char(block_size/1024)||' free buffer wait' name,free_buffer_wait stat
from V$buffer_pool_statistics
union
select name||' '||to_char(block_size/1024)||' buffer busy wait' name,buffer_busy_wait stat
from V$buffer_pool_statistics
union
select name||' '||to_char(block_size/1024)||' write complete wait' name,write_complete_wait stat
from V$buffer_pool_statistics
/
spool off
set pages 22
ttitle off

