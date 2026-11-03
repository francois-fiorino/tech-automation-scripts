/*
===============================================================================
SCRIPT: get_alters.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / misc_scripts/get_alters.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar textos SQL em cache com fragmentos ALTER MAT/ALTER SUM por usuário de parse.

FUNCIONAMENTO DETALHADO
  Une V$SQLAREA a DBA_USERS pelo PARSING_USER_ID, filtra textos e exclui MRAULT; spool temporal.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SQLAREA, DBA_USERS, DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não é auditoria e não comprova comando executado no momento; pode incluir comentários/literais. Não lê texto completo CLOB nem histórico. Timestamp tem precisão de minuto.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @get_alters.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  USERNAME e SQL_TEXT de prefixo em cache.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Spool local mantém NOW no nome; corpo SQL preservado. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col username format a20
col sql_text format a60
col date_now new_value now noprint
set lines 132 pages 59 feedback off echo off
select to_char(sysdate,'ddmonyyyyhh24mi') date_now from dual;
ttitle 'Users Issuing ALTER Commands'
spool get_alters_&&now..lst
select username,sql_text from v$sqlarea, dba_users 
where (upper(sql_text) like '%ALTER MAT%' or
upper(sql_text) like '%ALTER SUM%') and
parsing_user_id=user_id and username !='MRAULT'
/
spool off
set lines 80 pages 24
ttitle off
