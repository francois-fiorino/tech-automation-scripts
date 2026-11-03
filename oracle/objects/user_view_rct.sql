/*
===============================================================================
SCRIPT: user_view_rct.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/user_view_rct.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar texto de recriação de views do próprio schema por padrão de nome.

FUNCIONAMENTO DETALHADO
  Consulta USER_VIEWS e imprime CREATE OR REPLACE com owner USER e texto LONG, gravando arquivo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  USER_VIEWS, V$PARAMETER

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  SET LONG 5000 pode truncar definições maiores; não exporta grants/column aliases/edições/configurações. Nomes quoted e formatos de CLOB/LONG exigem revisão. Não confiar como backup único.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @user_view_rct.sql
  -- Informar fragmento view_name; revisar saída antes de usar.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Arquivo SQL de DDL textual; nenhum CREATE é executado pelo gerador.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Spool local de arquivo .sql preservado como artefato gerado; código/limite LONG histórico mantidos e sinalizados. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
REM NAME        :view_rct.sql
REM FUNCTION:recreate database views by owner
REM USE         	:Generate a report on database views
REM Limitations :If your view definitions are greater than 5000 characters
REM              	 then increase the set long. This can be determined by
REM              	 querying the DBA_VIEWS table's text_length column for the
REM              	 max value: select max(text_length) from dba_views;
REM
set pages 59 lines 79 feedback off echo off verify off
define cr='chr(10)'
column text 		format a80 word_wrapped
column view_name 	format a20
column dbname new_value db noprint
undef owner_name
undef view_name
select value dbname from v$parameter where name='db_name';
set long 5000 heading off
spool user_view_rct_generated.sql
select 
	'rem Code for view: '||v.view_name||'
CREATE OR REPLACE VIEW '||user||'.'||v.view_name||' as '||&&cr,
	v.text
from 
	user_views v 
where 
	view_name like upper('%&&view_name%')
;
spool off
set heading on pages 22 lines 80 feedback on echo on
clear columns
ttitle off
Pause Press enter to continue

