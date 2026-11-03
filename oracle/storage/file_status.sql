/*
===============================================================================
SCRIPT: file_status.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/file_status.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Mostrar tamanho, estado e quantidade de blocos de cada datafile.

FUNCIONAMENTO DETALHADO
  Lê DB_BLOCK_SIZE para título histórico da coluna; consulta DBA_DATA_FILES com tamanho atual convertido para MiB e ordena FILE_ID.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$PARAMETER, SYS.DBA_DATA_FILES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não inclui tempfiles nem MAXBYTES. Título original referindo o DB_BLOCK_SIZE global era incorreto em tablespaces com bloco distinto; contagem BLOCKS permanece da view.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @file_status.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  FILE_NAME, FILE_ID, STATUS, TABLESPACE_NAME, tamanho em MiB e BLOCKS.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Título BLOCKS ajustado para Blocks, sem atribuir a todos os arquivos o tamanho padrão de bloco. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
-- comment: Generate a file storage statisitics report
rem
column file_name format a23 heading 'File|Name'
column file_id format 999999 heading 'File|Number'
column tablespace_name format a10 heading 'Tablespace'
column bytes format 999.99 heading 'Megs'
column status heading 'File|Status'
column value new_value block_size noprint
select value from sys.v_$parameter where name='db_block_size';
column blocks format 99,999 heading 'Blocks'
set feedback off echo off lines 79 pages 57
ttitle 'File Storage Statistics Report'
spool file_status.lst
select file_name,file_id,status,tablespace_name,bytes/(1024*1024) bytes,
blocks from sys.dba_data_files
order by file_id
/
spool off
pause press enter/return to continue
clear columns
ttitle off
