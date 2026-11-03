/*
===============================================================================
SCRIPT: extents_chk.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _table_scripts/extents_chk.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar segmentos cujo número de extents alcança limiar informado.

FUNCIONAMENTO DETALHADO
  Calcula sugestão histórica a partir de DB_BLOCK_SIZE, aceita entrada opcional e filtra DBA_SEGMENTS por extents/owner.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$PARAMETER, DBA_SEGMENTS, DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Sugestão é heurística antiga, sem limite universal em LMT/bigfile. Muitos extents não provam problema. Não executa reorganização.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @extents_chk.sql
  -- Enter usa sugestão histórica; informar owner ou % no prompt.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tablespace, segmento, extents atuais/máximo, bytes, owner e tipo.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Entrada vazia convertida para NULL antes de NVL por TO_NUMBER entre aspas; OUTPUT local. Validar número controlado. Título convertido em TTITLE local.
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
REM
REM NAME                : EXTENTS_chk.SQL 
REM FUNCTION            : Generate extents report
REM USE                 : From SQLPlus or other front end
REM Limitations         : None
REM
CLEAR COLUMNS
ttitle off
set feedback off verify off
column segment_name     heading 'Segment'     format a30
column tablespace_name  heading 'Tablespace'  format a20
column owner            heading 'Owner'       format a20
column segment_type	heading 'Type'		format a10
column size		heading 'Size'		format 999,999,999,999
column ext new_value max_ext noprint
column ext2 new_value extents noprint
SELECT CEIL((value*.125)*.9) ext FROM v$parameter WHERE name='db_block_size';
accept inp_ext prompt 'Enter max number of extents(default:&max_ext): '
select nvl(to_number('&inp_ext'),&max_ext) ext2 from dual;
set pagesize 40 NEWPAGE 0
SET LINESIZE 130 feedback off echo off newpage 0 verify off
BREAK ON TABLESPACE_NAME SKIP PAGE on owner
ttitle "EXTENTS REPORT"
define output = extents_chk.lst
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

