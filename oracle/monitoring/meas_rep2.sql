/*
===============================================================================
SCRIPT: meas_rep2.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / misc_scripts/meas_rep2.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar medições positivas entre duas datas exclusivas.

FUNCIONAMENTO DETALHADO
  Filtra DBA_RUNNING_STATS por DATE1/DATE2, exclui tipos de objetos e calcula média visual por nome.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_RUNNING_STATS (customizada)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  NLS_DATE_LANGUAGE afeta mês. Somente valores >0 participam; não calcula delta/taxa. Tabela e coletor precisam existir com contrato esperado.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE date1 = "01-NOV-26 00:00:00"
  DEFINE date2 = "02-NOV-26 00:00:00"
  @meas_rep2.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Nome, valor e timestamp da janela aberta.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Variáveis de data colocadas entre aspas nos TO_DATE; ORDER BY data real qualificada. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
column name format a30 heading 'Statistic'
column meas_date format a22 heading 'Statistic|Measurement|Date'
column value heading 'Measurement|Value'
break on name SKIP 1
COMPUTE AVG OF value ON name
set lines 75 pages 47 verify off feedback off
ttitle 'Collected Statistics'
spool meas_rep2.lst
select name,value,to_char(meas_date,'dd-mon-yy hh24:mi:ss') meas_date
from dba_running_stats r 
where meas_date>to_date('&date1','dd-mon-yy hh24:mi:ss')
 and meas_date<to_date('&date2','dd-mon-yy hh24:mi:ss') and value>0
and name not in ('TABLE','VIEW','INDEX','SEQUENCE','TABLESPACE','CLUSTER','PACKAGE',
'PACKAGE BODY','PROCEDURE','FUNCTION','SYNONYM','TRIGGER')
order by name,r.meas_date
/
spool off
set verify on feedback on pages 22
