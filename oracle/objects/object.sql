/*
===============================================================================
SCRIPT: object.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/OBJECT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar datas de criação e último DDL de objetos selecionados.

FUNCIONAMENTO DETALHADO
  Filtra DBA_OBJECTS por fragmentos de owner/nome e apresenta datas e tipo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_OBJECTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  LAST_DDL_TIME não é data da última mudança de dados nem auditoria completa; grants e operações dependentes podem influenciar. Filtro usa UPPER, não cobre nomes quoted mistos automaticamente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE owner = HR
  DEFINE object_name = EMP
  @object.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, nome, CREATED, LAST_DDL_TIME e tipo.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Máscaras HH trocadas por HH24 para eliminar ambiguidade de horário. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem FUNCTION: Report on objects creation and modification dates
rem
column owner format a10
column created format a19
column modified format a19
column object_type format a10
column object_name format a15
break on owner on object_type
set verify off feedback off lines 131 pages 57
ttitle 'Object Modification and Creation Dates'
spool object.lst
select owner, object_name, to_char(created, 'dd-mon-yy hh24:mi:ss') created,
to_char(last_ddl_time,'dd-mon-yy hh24:mi:ss') modified, object_type from dba_objects
where 
owner like upper('%&owner%') and object_name like upper('%&object_name%')
order by owner,object_type
/
spool off
undef owner
undef object_name
clear columns
clear breaks
set verify on feedback on pages 22
