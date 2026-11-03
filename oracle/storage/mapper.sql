/*
===============================================================================
SCRIPT: mapper.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/MAPPER.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Mapear extents alocados e livres de um tablespace pela posição no arquivo.

FUNCIONAMENTO DETALHADO
  Combina DBA_FREE_SPACE e DBA_EXTENTS por UNION; filtra TS, apresenta FILE_ID, BLOCK_ID e BLOCKS, calcula MiB por BLOCK_SIZE do tablespace e ordena arquivo/bloco.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_FREE_SPACE, DBA_EXTENTS, DBA_TABLESPACES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Dados são consultados dinamicamente e podem mudar; não são mapa físico de storage/ASM. Identificadores exibidos são truncados a 20/32 caracteres. Preserva créditos de Kevin Loney e Mike Ault.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE ts = USERS
  @mapper.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Linhas free space e segmentos, com posição e tamanho de cada extent.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Tamanho de bloco obtido em DBA_TABLESPACES para o TS informado, em vez de DB_BLOCK_SIZE global, corrigindo tablespaces com bloco não padrão. 
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
rem Name: mapper.sql
rem Function: create an extent map for a specific tablespace
rem 
rem this procedure is from Kevin Loney's DBA book
rem
rem Mike Ault 7/19/96 Burleson Consulting
rem
set pages 47 lines 132 verify off feedback off
column file_id heading 'File|id'
column value new_value dbblksiz noprint
column meg format 9,999.99
select block_size value from dba_tablespaces where tablespace_name=upper('&&ts');
ttitle '&&ts Mapping Report'
spool ts_map
select
'free space' owner,
'      ' object,
file_id,
block_id,
blocks,
(blocks*&dbblksiz)/(1024*1024) meg
from dba_free_space
where tablespace_name=upper('&&ts')
union
select
substr(owner,1,20),
substr(segment_name, 1,32),
file_id,
block_id,
blocks,
(blocks*&dbblksiz)/(1024*1024) meg
from dba_extents
where tablespace_name = upper('&&ts')
order by 3,4;
spool off
undef ts
set pages 22 lines 80 verify on feedback on
clear columns
ttitle off
