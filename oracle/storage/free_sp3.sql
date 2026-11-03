/*
===============================================================================
SCRIPT: free_sp3.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _tablespace_scripts/FREE_SP3.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Resumir extents livres sem dependência de FREE_SPACE.

FUNCIONAMENTO DETALHADO
  Inline view agrega DBA_FREE_SPACE por arquivo, calcula FSFI histórico e agrega por tablespace.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_FREE_SPACE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não inclui arquivo totalmente ocupado ou sem linha visível. Métrica FSFI e soma dos maiores extents são heurísticas; não medem fragmentação de arquivo físico ou benefício de defrag em LMT.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @free_sp3.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Contagem de arquivos presentes, pieces/bytes/blocos, soma de máximos, ratio e média FSFI.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF em denominadores; inline view e dois níveis de agregação preservados. 
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
rem Name:     free_spc2.sql
rem
rem FUNCTION: Provide data on tablespace extent status
rem FUNCTION: this report uses the free_space2 view
rem
SET FEED OFF
SET FLUSH OFF
SET VERIFY OFF
set pages 58 LINES 145
column tablespace      heading Name              format a30
column files		heading '#Files'	format 99,999
column pieces          heading Frag              format 99,999
column free_bytes      heading 'Free|Byte'	format 999,999,999,999
column free_blocks     heading 'Free|Blk'	format 999,999,999
column largest_bytes   heading 'Biggest|Bytes'	format 999,999,999,999
column largest_blks    heading 'Biggest|Blks'	format 99,999,999
column ratio           heading 'Percent'         format 999.999
column average_fsfi	heading 'Average|FSFI'	format 999.999
ttitle "FREE SPACE REPORT"
define 1 = 'free_sp3.lst'
spool &1
select tablespace,count(*) files,sum(pieces) pieces,sum(free_bytes) free_bytes,
sum(free_blocks) free_blocks,sum(largest_bytes) largest_bytes,
sum(largest_blks) largest_blks, sum(largest_bytes)/nullif(sum(free_bytes),0)*100 ratio,
sum(fsfi)/count(*) average_fsfi 
from (select 
	tablespace_name tablespace, 
	file_id, 
	count(*) pieces,
	sum(bytes)free_bytes, 
	sum(blocks)free_blocks,
	max(bytes)largest_bytes, 
	max(blocks)largest_blks,
	sqrt(max(blocks)/nullif(sum(blocks),0))*(100/sqrt(sqrt(count(blocks)))) fsfi 
from 
	sys.dba_free_space
group by 
	tablespace_name, 
	file_id)
group by tablespace;
spool off
clear columns
ttitle off
SET FEED ON
SET FLUSH ON
SET VERIFY ON
set pages 22 LINES 80
pause Press Enter to Continue

