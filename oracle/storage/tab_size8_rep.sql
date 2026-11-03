/*
===============================================================================
SCRIPT: tab_size8_rep.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _table_scripts/tab_size8_rep.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Comparar blocos alocados com contagens previamente preenchidas em staging.

FUNCIONAMENTO DETALHADO
  Filtra segmentos TABLE do owner informado, liga por nome a TEMP_SIZE_TABLE e agrega extents/bytes/blocos.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$PARAMETER, SYS.DBA_SEGMENTS, TEMP_SIZE_TABLE (customizada)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Staging não possui owner e deve conter uma linha por tabela do proprietário selecionado; duplicações multiplicam agregados. Não coleta nem limpa dados. DB_BLOCK_SIZE pode diferir do tablespace e label é só referência. Contagem de blocos com linhas não é HWM.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @tab_size8_rep.sql
  -- Informar owner correspondente à única coleta mantida em TEMP_SIZE_TABLE.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner/segmento, extents, KiB, blocos alocados/usados e percentual estimado.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Owner explicitado/filtrado para não somar homônimos entre schemas; NULLIF no denominador e heading de bloco em bytes, não K. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Título convertido em TTITLE local.
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

accept owner prompt 'Owner da coleta unica em TEMP_SIZE_TABLE: '
/*  */
column db_block_size new_value blocksize noprint
select value db_block_size from v$parameter where name='db_block_size';
define bs = '&&blocksize bytes'
COLUMN t_date NOPRINT new_value t_date
COLUMN user_id NOPRINT new_value user_id
COLUMN segment_name FORMAT A35 HEADING "SEGMENT|NAME"
COLUMN segment_type FORMAT A7 HEADING "SEGMENT|TYPE"
COLUMN extents FORMAT 9,999 HEADING "EXTENTS"
COLUMN kbytes FORMAT 999,999,999 HEADING "KILOBYTES"
COLUMN blocks FORMAT 9,999,999 HEADING "ALLOC.|&&bs|BLOCKS"
COLUMN act_blocks FORMAT 9,999,990 HEADING "USED|&&bs|BLOCKS"
COLUMN pct_block FORMAT 999.99 HEADING "PCT|BLOCKS|USED"
set lines 132
ttitle "Actual Size Report"
set pages 55
break on report on segment_type skip 1
compute sum of kbytes on segment_type report 
spool tab_size8_rep.lst
SELECT a.owner,segment_name, segment_type,sum(extents) extents, sum(bytes)/1024 kbytes, 
       sum(a.blocks) blocks,nvl(max(b.blocks),0) act_blocks, 
       (max(b.blocks)/nullif(sum(a.blocks),0))*100 pct_block
  FROM sys.dba_segments a, temp_size_table b
 WHERE a.owner=upper('&owner') and segment_name = UPPER( b.table_name ) and nvl(b.blocks,0)!=0 
       and a.blocks>10 and segment_type='TABLE'
 GROUP BY a.owner,segment_name, segment_type
 ORDER BY segment_type,kbytes;
SPOOL OFF
rem delete temp_size_table;
set termout on feedback 15 verify on pagesize 20 linesize 80 space 1
undef qt
undef cr
ttitle off
clear columns 
clear computes
pause press enter to continue
