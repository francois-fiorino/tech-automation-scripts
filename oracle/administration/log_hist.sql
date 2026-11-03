/*
===============================================================================
SCRIPT: log_hist.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/Log_hist.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar histórico de redo no dia anterior ao último switch capturado.

FUNCIONAMENTO DETALHADO
  Filtra V$LOG_HISTORY por FIRST_TIME maior que máximo FIRST_TIME das linhas com maior NEXT_CHANGE# menos um dia.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$LOG_HISTORY

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Janela é ancorada no histórico de switch, não SYSDATE. Retenção do controlfile limita dados; sem ORDER BY externo. RAC pode ter vários threads no mesmo SCN.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @log_hist.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  THREAD#, SEQUENCE#, FIRST_CHANGE#/NEXT_CHANGE# e data.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  MAX(B.FIRST_TIME) garante subconsulta escalar mesmo com mais de um thread no SCN máximo. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Dependência de título externo substituída por TTITLE local.
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
REM
REM NAME   :log_hist.sql 
REM PURPOSE:Provide info on logs for last 24 hour since last log switch
REM USE    : From SQLPLUS
REM Limitations 	: None
REM
column thread# 		format 999 	heading 'Thrd#'
column sequence# 	format 99999 	heading 'Seq#'
column low_change# 			heading 'Low#'
column high_change# 			heading 'High#'
column first_time 		 	heading 'Accessed'
set lines 80
ttitle "Log History Report"
spool log_hist.lst
rem
select thread#, sequence#,
   first_change#,next_change#,
   to_char(a.first_time,'dd-mon-yyyy hh24:mi:ss') time
from 
	v$log_history a 
where
 	a.first_time >
  	(select max(b.first_time)-1
  	from v$log_history b where b.next_change# =
   	(select max(c.next_change#) from v$log_history c));
spool off
set lines 80 
clear columns 
ttitle off
pause Press enter to continue

