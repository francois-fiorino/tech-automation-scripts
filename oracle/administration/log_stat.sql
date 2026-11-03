/*
===============================================================================
SCRIPT: log_stat.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/LOG_STAT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir estado atual dos grupos de redo online.

FUNCIONAMENTO DETALHADO
  Consulta V_$LOG por thread/grupo e formata FIRST_TIME; mostra tamanho, membros e status.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$LOG

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não inclui todos os standby redo logs nem prova de backup. BYTES é tamanho do grupo, não multiplicado pelos membros; status e sequência mudam dinamicamente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @log_stat.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  THREAD#, GROUP#, SEQUENCE#, BYTES, MEMBERS, ARCHIVED, STATUS e FIRST_CHANGE#/FIRST_TIME.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  SQL preservado. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem Name:     log_stat.sql
rem
rem FUNCTION: Provide a current status for redo logs
rem 
rem
column first_change# format 999,999,999  heading Change#
column group#        format 9,999     heading Grp#
column thread#       format 999       heading Th#
column sequence#     format 999,999   heading Seq#
column members       format 999       heading Mem
column archived      format a4        heading Arc?
COLUMN first_time    format a25       HEADING First|Time
break on thread#
set pages 60 lines 132 feedback off 
ttitle 'Current Redo Log Status'
spool log_stat.lst
select thread#, group#, sequence#,
bytes, members,archived,status,first_change#,
to_char(first_time,'dd-mon-yyyy hh24:mi') first_time
 from sys.v_$log
order by thread#, group#;
spool off
pause Press Enter to continue
set pages 22 lines 80 feedback on
clear breaks 
clear columns
ttitle off
