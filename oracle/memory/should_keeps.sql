/*
===============================================================================
SCRIPT: should_keeps.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/should_keeps.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar candidatos heurísticos de library cache ainda não kept.

FUNCIONAMENTO DETALHADO
  Filtra V$DB_OBJECT_CACHE por tipos, EXECUTIONS>LOADS, EXECUTIONS>1 e KEPT=NO; ordena por identificação e execuções.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$DB_OBJECT_CACHE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não chama DBMS_SHARED_POOL.KEEP. Critério histórico não prova benefício de pinning; alterações exigem análise de memória, aging e carga. Tipos/contadores variam.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @should_keeps.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner/tipo/nome, memória, loads/execuções, locks/pins e KEPT.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta preservada; título should keep tratado como hipótese, não recomendação automática. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem comment: Report On Objects Which Should Be Kept
rem
column owner format a11 heading Schema
column name format a22 heading 'Should Keep|Object Name'
column namespace format a15 heading Name|Space
column type heading Object|Type format a15
column kept format a4 heading Kept
column sharable_mem format 999,999 heading Shared|Memory
column executions format 9,999,999 heading Executes
set lines 132 pages 47 feedback off
ttitle 'Oracle Should Keep Report'
break on owner on namespace on type
spool should_keeps.lst
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
	type not in ('NOT LOADED','NON-EXISTENT','VIEW','TABLE','INVALID TYPE','CURSOR')
	and executions>loads and executions>1 and kept='NO'
order by owner,namespace,type,executions desc;
spool off
set lines 80 pages 22 feedback on
clear columns
clear breaks
ttitle off
