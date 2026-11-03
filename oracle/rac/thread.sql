/*
===============================================================================
SCRIPT: thread.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / misc_scripts/THREAD.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar metadados de redo threads do control file.

FUNCIONAMENTO DETALHADO
  SELECT * de V_$THREAD com ordenação THREAD# e formatação de colunas conhecidas.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$THREAD

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  SELECT * varia por versão e largura pode ser insuficiente. Thread não é processo ou número fixo de instância; não verifica arquivamento/Data Guard nem executa switch.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @thread.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Uma linha por thread com estado, grupo/sequence/checkpoints e demais colunas da versão.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem FUNCTION: Provide data on Redo Log Threads
rem
rem name:     thread.sql 
rem
column current_group#       heading Current|Group#
column Checkpoint_change#   heading Checkpoint|Change#
column checkpoint_time      heading Checkpoint|Time
column open_time            heading Open|Time
column thread#              heading Thread#
column status               heading Status
column enabled              heading Enabled
column groups               heading Groups
column Instance             heading Instance
column sequence#            heading Sequence#
set lines 132 pages 59
ttitle 'Redo Thread Report'
spool thread.lst
select * from sys.v_$thread
order by thread#;
spool off
pause Press enter to continue
set lines 80 pages 22
ttitle off
clear columns

