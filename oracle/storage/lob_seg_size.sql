/*
===============================================================================
SCRIPT: lob_seg_size.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _table_scripts/lob_seg_size.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar bytes alocados e extents de segmentos LOB.

FUNCIONAMENTO DETALHADO
  Consulta DBA_SEGMENTS com filtro LOB% e exclusões de owners; retorna BYTES sem conversão.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_SEGMENTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Difere de lob_seg.sql: esta saída está em bytes. Não mede comprimento dos dados LOB ou espaço recuperável; uso de SecureFiles precisa de análise própria.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @lob_seg_size.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OWNER, SEGMENT_NAME, SEGMENT_TYPE, TABLESPACE_NAME, EXTENTS e BYTES.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col owner format a12 heading 'Owner'
col segment_name format a27 heading 'Segment|Name'
col tablespace_name format a15 heading 'Tablespace|Name'
col extents format 999,999,999 heading 'Extents'
col bytes format 999,999,999,999 heading 'Bytes'
set lines 132 pages 50 verify off feedback off
ttitle 'Lob Segment Sizes'
spool lob_seg_size.lst
select owner,segment_name,segment_type,tablespace_name,extents,bytes from dba_segments
where owner not in ('SYS','SYSTEM','PRECISE','MAULT','PATROL','QDBA','OUTLN','XDB','WMSYS','MDSYS','CTXSYS','ODM','SYSMAN') and segment_type LIKE 'LOB%'
/
spool off
set lines 80 pages 22 feedback on
ttitle off
