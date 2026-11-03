/*
===============================================================================
SCRIPT: extents.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _table_scripts/EXTENTS.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar segmentos com pelo menos a quantidade informada de extents.

FUNCIONAMENTO DETALHADO
  Consulta DBA_SEGMENTS com EXTENTS>=entrada e OWNER LIKE %OWNER%; mostra tamanho e máximo de extents.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_SEGMENTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Muitos extents em LMT não comprovam fragmentação problemática. Entrada deve ser inteiro não negativo; MAX_EXTENTS pode ser limite histórico e não capacidade física.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE owner = HR
  @extents.sql
  -- No prompt, informar limiar mínimo de extents.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tablespace, segmento, extents/max_extents, bytes, proprietário e tipo.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Prompt max corrigido para minimum conforme predicado; OUTPUT externo substituído por extents.lst local. Wrapper externo substituído por TTITLE local.
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


REM FUNCTION            : Generate extents report
REM USE                 : From SQLPlus or other front end
REM Limitations         : None
REM
CLEAR COLUMNS
column segment_name     heading 'Segment'     format a30
column tablespace_name  heading 'Tablespace'  format a20
column owner            heading 'Owner'       format a10
column segment_type	heading 'Type'		format a10
column size		heading 'Size'		format 9,999,999,999,999
set pagesize 40 NEWPAGE 0
SET LINESIZE 130 feedback off echo off newpage 0 verify off
accept extents prompt 'Enter minimum number of extents: '
BREAK ON TABLESPACE_NAME SKIP PAGE on owner
ttitle "EXTENTS REPORT"
DEFINE OUTPUT = extents.lst
spool &OUTPUT
select  TABLESPACE_NAME,
	segment_name,
	EXTENTS "Extents",
	max_extents "Max Extents",
	BYTES "Size",
	OWNER "Owner",
	segment_type
FROM    DBA_SEGMENTS 
where extents >= &extents and owner like upper('%&owner%')
order by tablespace_name,owner,segment_type,segment_name;
SPOOL OFF
clear columns
clear breaks
set termout on feedback on verify on 
undef extents
undef owner
ttitle off
undef output
pause Press enter to continue

