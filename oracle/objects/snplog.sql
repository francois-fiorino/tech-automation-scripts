/*
===============================================================================
SCRIPT: snplog.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/SNPLOG.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Inventariar snapshot logs pelo catálogo legado.

FUNCIONAMENTO DETALHADO
  Consulta DBA_SNAPSHOT_LOGS por LOG_OWNER com master, log table/trigger e CURRENT_SNAPSHOTS.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_SNAPSHOT_LOGS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  View/colunas são legadas e podem não existir em releases atuais. CURRENT_SNAPSHOTS não é data de last refresh; não valida fast refresh ou consistência da MV.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @snplog.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, master, log table, trigger e current snapshots.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Heading Last Refresh incorreto substituído por Current Snapshots; restante preservado. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem Name:       snplog.sql
rem FUNCTION:   Report on database Snapshot Logs
rem Use:        From an account that accesses DBA_ views
rem
rem
set pages 56 lines 130 feedback off
ttitle "Snapshot Log Report"
spool snplog.lst
rem
column log_owner        format a15      heading "Owner"
column master           format a27      heading "Master"
column log_table        format a27      heading "Snapshot"
column log_trigger      format a20      heading "Trigger Name"
column current_snapshots                heading "Current|Snapshots"
rem
select 
	log_owner, 
	master, 
	log_table, 
	log_trigger, 
	current_snapshots
from 
dba_snapshot_logs
order by 1;
rem
spool off
pause Press enter to continue
set pages 22 lines 80 feedback on
clear columns
ttitle off
