/*
===============================================================================
SCRIPT: inv_obj.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/INV_OBJ.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar objetos atualmente marcados como inválidos no dicionário.

FUNCIONAMENTO DETALHADO
  Seleciona DBA_OBJECTS com STATUS=INVALID e apresenta proprietário, nome, tipo e data do último DDL. Mantém créditos de Mike Ault.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_OBJECTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Invalidade não identifica causa; consultar erros e dependências antes de recompilar. Não há ALTER/DDL automático.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @inv_obj.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OWNER, OBJECT_NAME, OBJECT_TYPE e LAST_TIME; LAST_DDL_TIME não é a hora comprovada da invalidação.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  HH substituído por HH24 na data para evitar ambiguidade de meio dia. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem Name: inv_obj.sql
rem Purpose: Show alll invalid objects in database
rem Mike Ault 7/2/96 Created
rem Mike Ault 11/7/01 Verified on Oracle9i
rem
column object_name 	format A20 heading 'Object|Name'
column owner 		format a10 heading 'Object|Owner'
column last_time 	format a20 heading 'Last Change|Date'
column object_type      format a12 heading 'Object|Type'
set lines 80 feedback off pages 57 verify off
ttitle 'Invalid Database Objects'
spool inv_obj.lst
select 
	owner, 
	object_name,
	object_type, 
	to_char(last_ddl_time,'DD-MON-YY hh24:mi:ss') Last_time
from dba_objects where status='INVALID'
/
spool off
pause Press enter to continue
set lines 80 feedback on pages 22 verify on
clear columns
ttitle off
