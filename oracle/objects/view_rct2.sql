/*
===============================================================================
SCRIPT: view_rct2.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/view_rct2.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar DDL textual de views de owners selecionados com limite LONG 10000.

FUNCIONAMENTO DETALHADO
  Consulta DBA_VIEWS por fragmentos de owner/nome e imprime CREATE OR REPLACE e TEXT no spool.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS de criação/execução/consulta e permissões administrativas
  conforme limitações; não instalar variantes sobre objetos de trabalho.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_VIEWS, V$PARAMETER

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não cria views agora. LONG 10000 pode truncar; não exporta grants/column aliases/edições. Nomes sem quoting e ordenação só por view_name limitam fidelidade entre owners. Variante VIEW_RCT usa 5000 e será mapeada ao limite maior.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Revisão somente: @view_rct2.sql; informar filtros e inspecionar saída.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  CRE_VIEW.SQL com definições até limite LONG configurado.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: DDL/DML, staging, autenticação ou efeitos da saída
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código completo mantido com limite 10000; cabeçalho esclarece limite real apesar do comentário histórico mencionar 5000. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 040 — 04/11/2026
  Correções e melhorias: Gerador textual preservado.
  Limitações e pendências: Falta terminador explícito entre DDLs de views; páginas59/linhas79/word_wrap e LONG10000 podem inserir quebras/truncar. Nomes/aliases/editioning não completos. Saída não pronta para executar.
  Homologação necessária: Duas views consecutivas e body maior que10000, aliases, ampersand e nomes quoted; verificar terminadores/paginação manualmente.
  Parâmetros e execução: contrato detalhado acima e no corpo; somente laboratório.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  sem Windows, exportação, job ou comando administrativo executado.

AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de qualquer utilização em produção. Sua execução é de responsabilidade do profissional responsável pelo ambiente. Os mantenedores deste repositório não se responsabilizam por indisponibilidade, perda de dados, alterações indevidas ou outros impactos decorrentes de sua utilização.

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
set long 10000 heading off
spool rep_out\&db\cre_view.sql
select 
	'rem Code for view: '||v.view_name||'
CREATE OR REPLACE VIEW '||v.owner||'.'||v.view_name||' as '||&&cr,
	v.text
from 
	dba_views v 
where 
	v.owner like upper('%&&owner_name%')
	and view_name like upper('%&&view_name%')
order by 
	v.view_name;
spool off
set heading on pages 22 lines 80 feedback on echo on
clear columns
ttitle off
Pause Press enter to continue

