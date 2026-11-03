/*
===============================================================================
SCRIPT: o_cache2.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / misc_scripts/O_CACHE2.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar cem entradas de cache NOT LOADED/NON-EXISTENT em ordem por owner.

FUNCIONAMENTO DETALHADO
  Filtra dois tipos e limita inline view ordenada por owner/namespace/tipo e execuções descendentes.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$DB_OBJECT_CACHE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Tipos não provam corrupção ou defeito apesar do comentário bad objects. Não é top cem global de execução porque owner vem primeiro na ordem.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @o_cache2.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Metadados e contadores de cem entradas selecionadas.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem FUNCTION: Report on "bad" objects
rem
rem
column owner format a10 heading Schema
column name format a20 heading Object|Name
column namespace heading Name|Space format a10
column type heading Object|Type format a10
column kept format a4 heading Kept
column sharable_mem format 999,999 heading Shared|Memory
column executions format 9,999 heading Executes
set lines 132 pages 47 feedback off
ttitle 'Oracle Objects Report'
break on owner on namespace on type
spool o_cache2.lst
select * from (select  
	OWNER, 
	NAMESPACE,
	TYPE,
	NAME,
	SHARABLE_MEM,
	LOADS,  
	EXECUTIONS,   
	LOCKS,    
	PINS,
	KEPT
from 
	v$db_object_cache
where 
	type in ('NOT LOADED','NON-EXISTENT')
order by owner,namespace,type,executions desc) 
where rownum<101;
spool off
clear columns
clear breaks
set lines 80 pages 22 feedback on
