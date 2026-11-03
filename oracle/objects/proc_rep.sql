/*
===============================================================================
SCRIPT: proc_rep.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/PROC_REP.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relacionar status de módulos a contagem de linhas de fonte customizada.

FUNCIONAMENTO DETALHADO
  Une DBA_OBJECTS a PROC_COUNT por owner/tipo/nome e exclui SYS/SYSTEM.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_OBJECTS, PROC_COUNT (view customizada)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DDL de PROC_COUNT não acompanha o relatório; confirmar contrato. Contagem de linhas não mede complexidade ou instruções executáveis. PROC_REP2 inclui variante sem view intermediária.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @proc_rep.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner/tipo/nome/status, data de DDL e linhas de fonte.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código integral preservado com dependência explícita. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem FUNCTION: Report on Object status
rem
set pages 53 lines 80 verify off feedback off echo off
column owner format a10
column name format a30
column type format a9 word_wrapped
column status format a7
column lines format 9,999
break on owner skip page on type
ttitle "Report on Stored Code"
spool proc_rep.lst
select 
	b.owner owner,
	b.object_type type,
	b.object_name name,
	b.status status,
	b.last_ddl_time Modified,
	lines 
from dba_objects b, proc_count a
where b.owner not in ('SYS','SYSTEM')
and b.owner=a.owner 
and b.object_type=a.type 
and b.object_name=a.name
order by 1,2,3
/
spool off
pause Press enter to continue
set pages 22 lines 80 verify on feedback on echo on
clear breaks
clear columns
ttitle off
