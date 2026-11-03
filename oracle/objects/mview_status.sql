/*
===============================================================================
SCRIPT: mview_status.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/mview_status.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar estado de materialized views com identificação temporal do relatório.

FUNCIONAMENTO DETALHADO
  Obtém SYSDATE para NEW_VALUE NOW e consulta DBA_MVIEWS; spool tem timestamp do cliente de relatório.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DUAL, DBA_MVIEWS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não executa refresh/compile. STALENESS não comprova consistência de negócio. Timestamp com precisão de minuto pode colidir em execuções repetidas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @mview_status.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, materialized view, STALENESS e COMPILE_STATE; arquivo com data/hora no nome.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Spool local preserva sufixo temporal; consulta mantida. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col owner format a20
col mview_name format a32
col right_now new_value now noprint
set lines 132 pages 47
ttitle 'Materialized View Status'
select to_char(sysdate,'ddmonyyyyhh24mi') right_now from dual;
spool mview_status_&&now..lst
select owner,mview_name,staleness,compile_state from dba_mviews
/
spool off
set lines 80 pages 24
clear columns
ttitle off
