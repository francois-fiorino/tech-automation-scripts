/*
===============================================================================
SCRIPT: o_kept.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / misc_scripts/o_kept.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar objetos marcados KEPT no library cache.

FUNCIONAMENTO DETALHADO
  Filtra DB_OBJECT_CACHE por KEPT=YES e exclui quatro tipos; soma SHARABLE_MEM no relatório.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$DB_OBJECT_CACHE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não chama DBMS_SHARED_POOL.KEEP nem prova que cada parte jamais será envelhecida. PACKAGE BODY/SEQUENCE excluídos limitam cobertura; soma não mede memória recuperável física.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @o_kept.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Objeto/namespace/tipo, bytes e contadores com KEPT.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta preservada; spool específico. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem FUNCTION: Report Stored Object Statistics
rem
column owner format a11 heading Schema
column name format a30 heading Object|Name
column namespace format a15 heading Name|Space
column type format a10 heading Object|Type
column kept format a4 heading Kept
column sharable_mem format 9,999,999 heading Shared|Memory
column executions format 999,999 heading Executes
break on report
compute sum of sharable_mem on report
set lines 132 pages 47 feedback off
ttitle 'Oracle Kept Objects Report'
break on owner on namespace on type on report
spool o_kept.lst
select  
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
	type not in ('NOT LOADED','NON-EXISTENT','SEQUENCE','PACKAGE BODY')
	and kept='YES'
order by owner,namespace,type,executions desc;
spool off
set lines 80 pages 22 feedback on
clear columns
clear breaks
clear computes
clear breaks
ttitle off
rem        and owner not in ('SYS','SYSTEM','DBAUTIL')
