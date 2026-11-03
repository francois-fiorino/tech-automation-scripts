/*
===============================================================================
SCRIPT: see_jobs.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/SEE_JOBS.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir estado e agendamento de jobs legados do DBMS_JOB.

FUNCIONAMENTO DETALHADO
  Consulta DBA_JOBS e mostra código WHAT, falhas, próximas/últimas datas, expressão INTERVAL e flag BROKEN traduzida.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_JOBS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não cobre jobs de DBMS_SCHEDULER. NEXT_DATE não garante execução e WHAT pode expor código/dados sensíveis; proteger spool.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @see_jobs.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  JOB, WHAT, FAILURES, NEXT_DATE, LAST_DATE, INTERVAL e BROKEN.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
column what format a35 heading 'Job Content'
column job format 99999 heading 'Job #'
column next_date format a15 heading 'Next Date'
column last_date format a15 heading 'Last Date'
column interval format a20 heading 'Interval'
column broken format a5 heading 'Broke?'
column failures heading 'Failures'
set lines 132
ttitle 'Current Job Status'
spool see_jobs.lst
select 
	job,
	what,
	failures,
	to_char(next_date,'dd-mon-yy hh24:mi') next_date,
        to_char(last_date,'dd-mon-yy hh24:mi') last_date,
        interval,
	decode(broken,'N','No','Y','Yes',broken) broken 
from 
	dba_jobs
/
spool off
ttitle off

