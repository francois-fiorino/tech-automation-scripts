/*
===============================================================================
SCRIPT: logs.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _i_o_scripts/LOGS.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar histórico legado de sequências de redo por thread desde uma data.

FUNCIONAMENTO DETALHADO
  Solicita ST_DATE em DD-MON-RR, consulta SYS.V_$LOGHIST e ordena por THREAD#/SEQUENCE#; apresenta FIRST_CHANGE#, FIRST_TIME e SWITCH_CHANGE#.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$LOGHIST

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  View V$LOGHIST legada; não equivale a histórico permanente nem confirma arquivamento/backup. Validar colunas e retenção na versão alvo; mês depende de NLS_DATE_LANGUAGE.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @logs.sql
  -- Ao solicitar data, informe 01-NOV-26 (mês conforme NLS_DATE_LANGUAGE).
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Uma linha por sequência registrada desde o início informado, incluindo SCNs e hora inicial.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Removido TO_DATE sobre FIRST_TIME, que já é DATE; ST_DATE convertido explicitamente em DD-MON-RR elimina dependência de NLS_DATE_FORMAT. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem Name:     log.sql
rem
rem FUNCTION: Provide a report on redo log history
rem 
rem
break on thread#
prompt enter report start date (dd-mon-yy):
accept st_date
ttitle 'Redo Log Activity Report'
set lines 80 pages 60 feedback off verify off
spool logs.lst
select thread#,sequence#,first_change#,first_time first_time,switch_change#  from sys.v_$loghist
where first_time >= to_date('&st_date','dd-mon-rr') 
order by thread#,sequence#
/
spool off
clear breaks 
undef st_date
set pages 22 feedback on verify on
pause Press enter to continue

