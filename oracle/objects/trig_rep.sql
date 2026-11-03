/*
===============================================================================
SCRIPT: trig_rep.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/TRIG_REP.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar triggers de um proprietário e seu estado de habilitação.

FUNCIONAMENTO DETALHADO
  Consulta DBA_TRIGGERS por TRIGGER_OWNER e mostra tipo/evento, tabela e STATUS.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TRIGGERS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  STATUS da view descreve ENABLED/DISABLED e não substitui validade de compilação em DBA_OBJECTS/DBA_ERRORS. Triggers de schema/banco podem não ter tabela. Não executa ALTER TRIGGER.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE trigger_owner = HR
  @trig_rep.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, trigger, tipo, evento, Table e STATUS.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta preservada. Wrapper externo substituído por TTITLE local.
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
rem
rem  NAME       :  trig_rep.sql
rem  FUNCTION   :  Report on all triggers and their status
rem
column owner            format a10
column trigger_name     format a20      heading "Trigger"
column trigger_type     format a20      heading "Type"
column triggering_event format a10      heading "Event"
column table            format a40      heading "Trigger Table"
rem
break on owner
set verify off  feedback off lines 130 pages 58 
ttitle "Trigger Status Report"
spool  rep_out\&db\trg_stat
rem
Select  owner, 
	trigger_name,
	trigger_type,
	triggering_event,
	table_owner||'.'||table_name "Table", 
	status 
from dba_triggers
where owner=upper('&trigger_owner')
order by 1,5,2;
spool off
clear columns 
clear breaks
set verify on  feedback on lines 80 pages 22
ttitle off
