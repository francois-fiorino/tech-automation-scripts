/*
===============================================================================
SCRIPT: desc_v$_views.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/desc_v$_views.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar consultas e DESCRIBEs de definições de fixed views GV.

FUNCIONAMENTO DETALHADO
  Spool de comandos SELECT VIEW_DEFINITION e DESC para nomes de V_$FIXED_VIEW_DEFINITION LIKE GV%; não executa saída.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$FIXED_VIEW_DEFINITION, DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Definições são internas e limitadas pela view/versão; não equivalem a código fonte completo do kernel. Nomes de views vêm do catálogo. Geração pode incluir views indisponíveis para DESC no contexto.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @desc_v$_views.sql
  -- Revisar desc_v$views.sql antes de execução manual.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Arquivo gerado para documentar fixed views e metadados.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código gerador integral preservado; não cria/substitui views ou executa arquivo automaticamente. 
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
set pages 8000 lines 130 embedded on heading off feedback off
spool desc_v$views.sql
select 'set pages 20000 lines 80 embedded on feedback off' from dual;
select 'column view_name format a30 heading '||chr(39)||'View Name'||chr(39) from dual;
select 'column view_definition format a60 word_wrapped heading '||chr(39)||'Definition'||chr(39) from dual;
select 'spool desc_v$_views.doc' from dual;
select 'select '||chr(39)||'Specification of Fixed View: '||view_name||chr(39)||'||chr(10)||chr(10)||'||chr(10)||
'view_name||'||chr(39)||' select statement: '||chr(39)||
'||chr(10)||chr(10),view_definition from sys.v_$fixed_view_definition'||chr(10)||
  ' where view_name = '||chr(39)||view_name||chr(39)||';'||chr(10)||'desc sys.'||view_name
from sys.v_$fixed_view_definition where view_name like 'GV%';
select 'spool off' from dual;                                                    
spool off
