/*
===============================================================================
SCRIPT: obj_stat.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/OBJ_STAT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar status de objetos por padrão de tipo.

FUNCIONAMENTO DETALHADO
  Consulta DBA_OBJECTS com OBJECT_TYPE LIKE UPPER da variável TYPE e ordena owner/tipo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_OBJECTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Status VALID não garante sucesso funcional e não é estado de disponibilidade do banco. Não recompila objetos. Sem filtro de owner e sem histórico.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE type = %
  @obj_stat.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, tipo, nome e STATUS.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta e PAUSE preservados. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Título convertido em TTITLE local.
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
rem  NAME       :  obj_stat.sql
rem
rem  FUNCTION   :  Report on all objects and their status
rem
column  owner           format a17      heading "Owner"
column  object_name     format a23      heading "Object"
column object_type      format a20      heading "Type of Object"
column status           format a10      heading "Status"
rem
set verify off  feedback off lines 80 pages 58 heading off
rem 
break on owner on  object_type
ttitle "Database Object Status"
spool obj_stat.lst
rem
prompt Enter % for all objects
rem
select  owner,
	object_type,
	object_name,
	status
from dba_objects 
where object_type like upper('&type')
order by 1,2;
spool off
set verify on  feedback on lines 80 pages 22 heading on
clear columns
clear breaks
undef type
pause Press enter to continue
