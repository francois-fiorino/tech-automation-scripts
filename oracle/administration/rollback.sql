/*
===============================================================================
SCRIPT: rollback.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/ROLLBACK.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar storage e estatística de rollback segments atualmente presentes.

FUNCIONAMENTO DETALHADO
  Une DBA_ROLLBACK_SEGS e ROLLSTAT por SEGMENT_ID/USN e ordena owner/tablespace.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_ROLLBACK_SEGS, SYS.V_$ROLLSTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  INNER JOIN omite segmentos sem estatísticas locais; modelo de undo manual legado, não recomendação para AUM. Não altera estado, tamanho ou uso.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @rollback.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner/tablespace/segmento, initial/next/min/max, extents e OPTSIZE.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta e crédito M. Ault preservados. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem Name: rollback.sql
rem Purpose: Generate soft documentation for rollback segments on database
rem Limitations: User must have access to dba_rollback_segs
rem:
rem History:
rem Who:	What:		When:
rem M. Ault	Initial Creation	4/18/96
rem
column owner format a10 heading 'Owner'
column tablespace_name format a15 heading 'Tablespace|Name'
column segment_name format a30 heading 'Rollback|Segment Name'
column initial_extent heading 'Initial|Extent'
column next_extent heading 'Next|Extent'
column min_extents heading 'Minimum|Extents'
column max_extents heading 'Maximum|Extents'
column extents heading 'Current|Extents'
column optsize heading 'Optimal|Setting'
set pages 48 lines 130
break on owner on tablespace_name
ttitle "Rollback Segment Report"
spool rollback.lst
select 
	owner,
	tablespace_name,
	segment_name ,
	initial_extent,
	next_extent,
	min_extents,
	max_extents,
	extents,
	optsize
from 
	dba_rollback_segs a, sys.v_$rollstat b
where 
	a.segment_id=b.usn
order by 
	owner,
	tablespace_name
/
spool off
set pages 22 lines 80
clear columns
clear breaks
ttitle off
pause Press enter to continue

