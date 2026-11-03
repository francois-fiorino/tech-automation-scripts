/*
===============================================================================
SCRIPT: init_rct.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/INIT_RCT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar rascunho de parâmetros não default no formato init.ora.

FUNCIONAMENTO DETALHADO
  UNION de comentários e NAME=VALUE de V$PARAMETER; grava arquivo local.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$PARAMETER, V$DATABASE, DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não é exportação homologada de SPFILE: sem quoting correto de listas/strings e pode omitir estado persistente/instâncias. UNION pode reordenar comentários; nomes/caminhos e parâmetros sensíveis expostos. Não faz startup.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Revisão somente: @init_rct.sql; não iniciar instância com a saída sem validar.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Rascunho init.ora com valores não default e créditos.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  OUTPUT local init_generated.ora para não colidir com configuração ativa; conteúdo completo preservado. 
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
REM NAME        : init_ora_rct.sql 
REM FUNCTION    : Recreate the instance init.ora file 
REM USE         : GENERAL
REM Limitations : None
REM
SET NEWPAGE 0 VERIFY OFF
SET ECHO OFF feedback off termout off PAGES 300 lines 80 heading off 
column name  format a80 word_wrapped
column dbname new_value db noprint
select name dbname from v$database;
define output = init_generated.ora
SPOOL &OUTPUT
SELECT '# Init.ora file from v$parameter' name from dual
union
select '# generated on:'||sysdate name from dual
union 
select '# script by MRA 11/7/95 REVEALNET' name from dual
union
select '#' name from dual
UNION
SELECT name||' = '||value name  FROM V$PARAMETER
WHERE value is not null and ISDEFAULT='FALSE';
SPOOL OFF
CLEAR COLUMNS
SET NEWPAGE 0 VERIFY OFF
SET ECHO ON termout on PAGES 22 lines 80 heading on 
set termout on
undef output
pause Press enter to continue
