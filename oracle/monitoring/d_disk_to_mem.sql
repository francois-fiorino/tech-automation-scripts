/*
===============================================================================
SCRIPT: d_disk_to_mem.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/d_disk_to_mem.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Calcular razão de deltas de sorts em disco para deltas de sorts em memória.

FUNCIONAMENTO DETALHADO
  Associa DBA_RUNNING_STATS por data e nomes de sort; calcula A.DELTA/GREATEST(B.DELTA,1)*100 e aplica corte diário inclusivo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_RUNNING_STATS (objeto customizado)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  GREATEST(delta,1) impede divisão por zero mas fabrica baseline 1 para delta zero/negativo; não interpretar como percentual medido nesses casos. Razão não é fração do total de sorts; linhas duplicadas e resets do coletor podem distorcer.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE dd_mon_yy = 03-NOV-26
  @d_disk_to_mem.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Rótulo Disk_To_Memory_Sort_Percent, VALUE calculado e data.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Fórmula original preservada e limitações explícitas; não redefinida a métrica sem validar coletor. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
column value format 999.9999
column name format a30
column meas_date format a16
set pages 0 lines 80
ttitle 'Disk to Memory Sorts Percent'
spool d_disk_to_mem.lst
select 
'Disk_To_Memory_Sort_Percent', (a.delta/greatest(b.delta,1))*100 value , to_char(a.meas_date,'dd-mon-yy hh24:mi') meas_date
from dba_running_stats a, dba_running_stats b where a.name = 'sorts (disk)' and
b.name='sorts (memory)' and a.meas_date=b.meas_date
and trunc(a.meas_date)>=to_date('&dd_mon_yy','dd-mon-yy')
order by a.meas_date
/
spool off
set echo off
