/*
===============================================================================
SCRIPT: auto_chain.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _table_scripts/auto_chain.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar e executar CHAINING para tabelas de um owner.

FUNCIONAMENTO DETALHADO
  Spool AUTO_CHN.GQL com START CHAINING, executa lista sob spool e remove intermediário via HOST DEL.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES, V$PARAMETER, CHAINING.SQL, SQL*Plus HOST/START

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Helper pode ANALYZE/listar chained rows/modificar staging, e cabeçalho exige modificação manual para argumentos. Não assumir read-only. Varre todas as tabelas e nomes não escapados são inseguros; arquivos locais sobrescritos/apagados.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório Windows com CHAINING revisado no mesmo SQLPATH.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Lista gerada, relatório e remoção do arquivo intermediário.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  conforme descritos. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Fluxo e dependências preservados; não executado. 
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
rem  **************************************************************************
rem
rem  NAME: AUTO_CHN.sql     
rem
rem  FUNCTION: Run CHAINING.sql for all of a specified users tables. 
rem
rem  NOTES:    Requires a minor mod to CHAINING.sql. See CHAINING.sql header.
rem
rem  INPUTS:
rem            tabown = Name of owner.
rem
rem  **************************************************************************

accept tabown prompt 'Enter table owner: '

set termout off feedback off verify off echo off heading off pages 999 
set embedded on
column value new_value db noprint
select value from v$parameter where name='db_name';
spool rep_out\auto_chn.gql

select 'start chaining &tabown '||table_name
  from dba_tables
 where owner = upper('&tabown')
/

spool off
spool rep_out\&db\chaining 
start rep_out\auto_chn.gql
spool off 
undef tabown
set termout on feedback 15 verify on pagesize 20 linesize 80 space 1
set embedded off
ho del rep_out\auto_chn.gql
pause Press enter to continue

 
