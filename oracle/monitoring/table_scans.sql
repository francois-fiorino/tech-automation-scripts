/*
===============================================================================
SCRIPT: table_scans.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / _table_scripts/table_scans.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar séries customizadas de scans longos e curtos.

FUNCIONAMENTO DETALHADO
  Associa DBA_RUNNING_STATS por MEAS_DATE e nomes fixos; soma valores e filtra dias após data informada.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_RUNNING_STATS (customizada), V$PARAMETER

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CACHE_SIZE_THRESHOLD é legado e pode não existir. Coleção deve fornecer séries únicas por data/nome; sem delta automático. Heading de limiar pode não descrever classificação moderna.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE dd_mon_yy = 01-NOV-26
  @table_scans.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Scans longos/curtos, soma e timestamp.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Fallback para limiar ausente e ordenação por data real, em vez de texto DD-MON-YY. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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

define size_lim = PARAMETRO_LEGADO_INDISPONIVEL
/*  */
column total_scans format 99,999,999 heading 'Total Scans'
column meas_date format a16 heading 'Measurement|Date'
column value new_value size_lim noprint
set pages 0 lines 80 feedback off verify off
ttitle off
select a.value*b.value value from v$parameter a, v$parameter b 
where a.name = 'cache_size_threshold' and b.name='db_block_size';
column long_scans format 999,999,999 heading 'Long Scans|>&&size_lim Bytes'
column short_scans format 999,999,999 heading 'Short Scans|<&&size_lim bytes'
column total_scans format 999,999,999 heading 'Total Scans'
ttitle 'Table Scans'
spool table_scans.lst
select 
a.value long_scans, b.value short_scans, a.value+b.value total_scans, 
to_char(a.meas_date,'dd-mon-yy hh24:mi') meas_date
from dba_running_stats a, dba_running_stats b 
where a.name ='table scans (long tables)' 
and b.name='table scans (short tables)' 
and trunc(a.meas_date)>to_date('&dd_mon_yy','dd-mon-yy')
and a.meas_date=b.meas_date 
order by a.meas_date
/
spool off
ttitle off
clear columns
set feedback on verify on
