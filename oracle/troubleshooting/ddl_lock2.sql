/*
===============================================================================
SCRIPT: ddl_lock2.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / misc_scripts/ddl_lock2.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar todos os DDL locks, incluindo modo Null.

FUNCIONAMENTO DETALHADO
  Consulta DBA_DDL_LOCKS sem filtro de MODE_HELD e ordena SID.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_DDL_LOCKS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Difere de DDL_LOCK pela inclusão de Null. Linha não prova bloqueio; não monta grafo ou detecta deadlock.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @ddl_lock2.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, sessão, objeto/tipo e modos mantido/solicitado.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta preservada; spool específico. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem Function: Document DDL Locks currently in use
rem
column owner format a15 heading 'User'
column session_id heading 'SID'
column mode_held format a20 heading 'Lock Mode|Held'
column mode_requested format a20 heading 'Lock Mode|Requested'
column type heading 'Type|Object'
column name heading 'Object|Name'
set feedback off echo off pages 59 lines 131
ttitle 'Report on All DDL Locks Held'
spool ddl_lock2.lst
select nvl(owner,'SYS') owner,session_id,name,type,
mode_held,mode_requested
from  sys.dba_ddl_locks
order by 2
/
spool off
pause press enter/return to continue 
clear columns
set feedback on echo on pages 22 lines 80
ttitle off
