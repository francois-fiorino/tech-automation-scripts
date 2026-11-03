/*
===============================================================================
SCRIPT: daily_stat.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / misc_scripts/daily_stat.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Resumir medições diárias customizadas em horário comercial.

FUNCIONAMENTO DETALHADO
  Obtém baseline mínimo de table fetch by rowid 07..17, resume diferenças positivas 08..16, users e contagem Flush%.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_RUNNING_STATS, HIT_RATIOS (customizadas), DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  AVG de valor menos mínimo não é taxa nem delta médio entre amostras; restart invalida baseline. Horário comercial fixo e dias/zeros sem coleta são omitidos. Tabelas/coletor precisam existir.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @daily_stat.sql
  -- Informar start_date dd-mon-yy.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  AVG/MAX relativo a baseline, users AVG/MAX/MIN e contagem de registros de flush.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  OUTPUT local com data; GROUP BY 1 redundante removido dos três ramos literais para compatibilidade, sem eliminar nenhum resumo. Chamadas externas title80/title132 substituídos por TTITLE local.
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
REM: Grabs specific stats from DBA_RUNNING_STATS with deltas
REM
clear columns
undef minus_value
ttitle off
column min_value new_value minus_value noprint
column temp_date new_value rep_date noprint
column name format a40
set pages 0 verify off feedback off
accept start_date prompt 'Enter Date for Statistics Run (dd-mon-yy): '
rem
select nvl(min(value),0) min_value from dba_running_stats where
name='table fetch by rowid' 
and to_char(meas_date,'hh24') between 7 and 17
and trunc(meas_date)=to_date('&&start_date','dd-mon-yy');
rem
select to_char(to_date('&&start_date','dd-mon-yy'),'ddmonyy') temp_date from dual;
ttitle 'Average Values Report'
define output = daily_stat_&&rep_date..lst
ttitle on
spool &&output
select name||'(avg)' name, round(avg(value-&minus_value),0) value, trunc(meas_date) meas_date1
from dba_running_stats
where name='table fetch by rowid' 
and trunc(meas_date)=to_date('&&start_date','dd-mon-yy')
and to_char(meas_date,'hh24') between 8 and 16
and round(value-&&minus_value,0)>0
group by name, trunc(meas_date)
union
select name||'(max)' name, round(max(value-&minus_value),0) value, trunc(meas_date) meas_date1
from dba_running_stats
where name='table fetch by rowid' 
and trunc(meas_date)=to_date('&&start_date','dd-mon-yy')
and to_char(meas_date,'hh24') between 8 and 16
and round(value-&&minus_value,0)>0
group by name, trunc(meas_date)
union
select 'USERS (avg)' name, round(avg(users),0) value, check_date meas_date1
from hit_ratios where
check_date=trunc(to_date('&&start_date','dd-mon-yy'))
and check_hour between 8 and 16
group by check_date
union
select 'USERS (max)' name, max(users) value, check_date meas_date1
from hit_ratios where
check_date=trunc(to_date('&&start_date','dd-mon-yy'))
and check_hour between 8 and 16
group by check_date
union
select 'USERS (min)' name, min(users) value, check_date meas_date1
from hit_ratios where
check_date=trunc(to_date('&&start_date','dd-mon-yy'))
and check_hour between 8 and 16
group by check_date
union
select name, count(value) value, trunc(meas_date) meas_date1
from dba_running_stats
where name like 'Flush%'
and trunc(meas_date)=to_date('&&start_date','dd-mon-yy')
and to_char(meas_date,'hh24') between 8 and 16
and round(value,0)>0
group by name, trunc(meas_date)
order by 1,3
;
spool off
undef start_date
ttitle off
