/*
===============================================================================
SCRIPT: db_tgrnt.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / misc_scripts/DB_TGRNT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relacionar grants diretos de objetos a tipo por fragmento de grantee.

FUNCIONAMENTO DETALHADO
  Une TAB_PRIVS a OBJECTS por owner/nome e exclui corpos que não são alvos autônomos de grants.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TAB_PRIVS, DBA_OBJECTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Nomes sem owner na saída podem ser ambíguos. Não expande roles nem avalia privilégios efetivos; filtro inclui usuários e roles por texto.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @db_tgrnt.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Grantee, nome de objeto, privilégio e tipo.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  PACKAGE BODY/TYPE BODY excluídos da associação para não duplicar grant do objeto especificação. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem FUNCTION: Report on database table or procedure grants
rem
column table_name format a16 heading 'Table or|Procedure'
column grantee format a16 heading 'Role or|User'
column privilege format a10 heading 'Granted|Privilege'
column object_type heading 'Type of|Object'
accept user prompt 'Enter user name: '
set lines 80 feedback off verify off
ttitle 'Table and Procedure Grants by User/Role'
break on object_type on grantee on table_name
spool db_tgrnt.lst
select grantee,table_name,privilege,object_type 
from dba_tab_privs a, dba_objects b
where grantee like upper('%&user%')
and a.owner=b.owner
and a.table_name=b.object_name
and b.object_type not in ('PACKAGE BODY','TYPE BODY')
order by 4,1,2
/
spool off
set feedback on verify on
clear columns
clear breaks
ttitle off
