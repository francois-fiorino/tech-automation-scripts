/*
===============================================================================
SCRIPT: except_list.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/except_list.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Localizar linhas de fonte com PRAGMA EXCEPTION_INIT.

FUNCIONAMENTO DETALHADO
  Consulta DBA_SOURCE com busca case-insensitive textual e exclusões de quatro owners.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_SOURCE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não é parser PL/SQL: comentários/strings podem corresponder e pragmas em várias linhas podem faltar. Sem LINE/TYPE na saída; proteger fonte sensível.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @except_list.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OWNER, NAME e TEXT sem espaços iniciais.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta e comentário histórico preservados. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col owner format a10 head 'Owner'
col name format a30 head 'Object Name'
col text format a60 head 'Exception Text'
ttitle 'User Defined Exceptions'
set lines 132 pages 47
spool except_list.lst
select owner,name,ltrim(text) text from dba_source 
where upper(text) like '%PRAGMA EXCEPTION_INIT%'
--and owner not in ('DISCO_ADMIN','DISCO_ADMIN_CM','DIS_DWRPT_ADMIN','DIS_DWRPT_ADMIN_V4',
and owner not in ('MRAULT','PERFSTAT','SYS','SYSTEM')
/
spool off
ttitle off
set lines 80 pages 22

