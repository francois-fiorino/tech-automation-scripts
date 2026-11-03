/*
===============================================================================
SCRIPT: view_rep.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/VIEW_REP.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar texto e validade de views por padrão de proprietário.

FUNCIONAMENTO DETALHADO
  Une DBA_VIEWS e DBA_OBJECTS por owner/nome/tipo VIEW; filtra OWNER LIKE UPPER(%OWNER_NAME), mostra TEXT e STATUS.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_VIEWS, DBA_OBJECTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Filtro é sufixo porque % aparece só antes do parâmetro. SET LONG 2000 limita texto: não usar relatório como backup completo da definição. Pode expor SQL sensível.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE owner_name = HR
  @view_rep.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, nome, texto e status de compilação; sem DDL executada.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta e aviso histórico de limite preservados. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Wrapper externo substituído por TTITLE local.
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
REM NAME         : view_rep.sql
REM FUNCTION     : report on database views by owner
REM USE          : Generate a report on database views
REM
REM Limitations    If your view definitions are greater than 2000 characters
REM                then increase the set long. This can be determined by
REM                querying the DBA_VIEWS table's text_length column for the
REM                max value: select max(text_length) from dba_views;
REM
set pages 59 lines 131 feedback off echo off
column text             format a75
column owner            format a20
column view_name        format a20
column status           format a7
set long 2000
ttitle "Database Views Report"
spool view_rep.lst
select 
	v.owner,
	v.view_name,
	v.text,
	o.status 
from 
	dba_views v, 
	dba_objects o
where 
	v.owner like upper('%&owner_name') and
	o.owner = v.owner and
	o.object_type = 'VIEW' and
	o.object_name = v.view_name
order by 
	o.status, 
	v.view_name;
spool off
set pages 22 lines 80 feedback on echo on
clear columns
ttitle off
Pause Press enter to continue
