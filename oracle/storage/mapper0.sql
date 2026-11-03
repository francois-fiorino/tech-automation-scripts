/*
===============================================================================
SCRIPT: mapper0.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/mapper0.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Mapear extents livres e ocupados de um tablespace em um arquivo específico.

FUNCIONAMENTO DETALHADO
  Combina DBA_FREE_SPACE e DBA_EXTENTS filtradas por TS e FILE_ID; mostra posições, blocos e MiB; ordenação original prioriza nome do objeto e depois posição.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_FREE_SPACE, DBA_EXTENTS, DBA_TABLESPACES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não é mapa de disco físico e a ordenação não é estritamente por posição. Extents em ambientes offline/LMT seguem a visibilidade da view. Preserva créditos de Kevin Loney e Mike Ault/Trecom/RevealNet.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE ts = USERS
  DEFINE file_id = 4
  @mapper0.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OWNER/OBJECT, FILE_ID, BLOCK_ID, BLOCKS e MEG; free space identifica extents não alocados.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  BLOCK_SIZE obtido do tablespace informado em DBA_TABLESPACES, corrigindo estimativa em tablespaces com bloco não padrão. 
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
rem Mike Ault 7/19/96 Trecom/RevealNet
rem
set pages 47 lines 132 verify off feedback off
column file_id heading 'File|id'
column value new_value dbblksiz noprint
column meg format 9,999.99
select block_size value from dba_tablespaces where tablespace_name=upper('&&ts');
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
and file_id=&&file_id
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
and file_id=&&file_id
order by 2,3,4;
spool off
undef ts
undef file_id
set pages 22 lines 80 verify on feedback on
clear columns
ttitle off
