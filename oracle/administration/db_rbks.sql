/*
===============================================================================
SCRIPT: db_rbks.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/DB_RBKS.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Inventariar rollback segments e parâmetros de storage.

FUNCIONAMENTO DETALHADO
  Consulta DBA_ROLLBACK_SEGS sem joins, com tipo privado/público derivado do OWNER.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_ROLLBACK_SEGS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Modelo legado de rollback manual; valores não representam diagnóstico completo de AUM. INSTANCE_NUM é textual e display curto pode truncar.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @db_rbks.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Segmento/tablespace, extents/min/max/pct/status/instância e tipo.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  DECODE agora mostra PUBLIC para owner PUBLIC, em vez de NULL; SYS continua PRIVATE conforme modelo legado. Referência: docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_ROLLBACK_SEGS.html. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem FUNCTION: Create list of all database rollback segments
rem FUNCTION: and their storage defaults
rem
column rollback_seg format a8 heading 'Rollback|Segment'
column tablespace format a10 heading 'Rbks|Tablespace'
column pct format 9990 heading 'Pct|Inc'
column init format 99,999,999 heading 'Init|Ext'
column next format 99,999,999 heading 'Next|Ext'
column min format 999 heading 'Min|Ext'
column max format 9,999 heading 'Max|Ext'
column instance format a3 heading 'Int|Num'
column type heading 'Rbks|Type'
column status heading 'Rbks|Status'
set pages 59 lines 132 feedback off echo off
ttitle 'Rollback Storage Parameter Report'
spool db_rbks.lst
select segment_name rollback_seg,tablespace_name tablespace, 
initial_extent init,
next_extent next, min_extents min, max_extents max, 
pct_increase pct, status, instance_num Instance,
decode(owner,'SYS','PRIVATE','PUBLIC','PUBLIC',owner) type
from dba_rollback_segs;
spool off
pause press enter/return to continue
clear columns
set pages 22 lines 80 feedback on echo on
ttitle off
