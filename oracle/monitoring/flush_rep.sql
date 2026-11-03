/*
===============================================================================
SCRIPT: flush_rep.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/flush_rep.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Contar eventos históricos de flush registrados em tabela customizada.

FUNCIONAMENTO DETALHADO
  Agrupa DBA_RUNNING_STATS por dia, filtra janela inclusiva e dias de semana; COMPUTE AVG resume apenas dias retornados.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_RUNNING_STATS (customizada)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Janela entre data e data+N é inclusiva (N+1 datas). Dias sem linhas não entram na média. Registro do coletor não garante auditoria completa; recomendações antigas de aumentar shared pool não são automáticas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @flush_rep.sql
  -- Informar data dd-mon-yy e quantidade controlada de dias.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Contagem de linhas Flush% por dia e média dos dias com registros.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Idioma ENGLISH explicitado para filtro SAT/SUN; SQL não faz flush nem chama FLUSH_IT. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem flush_rep.sql
rem MRA 7/21/98
rem Reports based on count of entries per day in the 
rem DBA_RUNNING_STATS table the number of flushes
rem of the shared pool. If average is excessive
rem increase the size of the shared pool or increase the 
rem ratio in the flush_it procedure.
rem
column flushes heading 'Flushes|of|Shared Pool'
column meas_date heading 'Date|of|Flushes'
set verify off feedback off
break on report
compute avg of flushes on report
accept min_date prompt 'Enter date (dd-mon-yy) to start from:'
accept no_days prompt 'Enter number of days for report:'
ttitle 'Shared Pool Flushes'
spool flush_rep.lst
select count(*) flushes, trunc(meas_date) meas_date 
from dba_running_stats 
where trunc(meas_date)>=to_date('&min_date','dd-mon-yy') and
trunc(meas_date)<=to_date('&min_date','dd-mon-yy')+to_number('&no_days')
and name like 'Flush%'
and upper(to_char(meas_date,'DY','NLS_DATE_LANGUAGE=ENGLISH')) not in ('SAT','SUN')
group by trunc(meas_date)
/
spool off
clear computes
clear breaks
undef min_date
undef no_days
set verify on feedback on


