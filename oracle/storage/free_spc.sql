/*
===============================================================================
SCRIPT: free_spc.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _tablespace_scripts/FREE_SPC.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Resumir extents livres por tablespace sem coluna FSFI.

FUNCIONAMENTO DETALHADO
  Consulta FREE_SPACE por arquivo e agrega quantidade/bytes/blocos e razão soma dos máximos/soma livre.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  FREE_SPACE (customizada, colunas TABLESPACE/PIECES/FREE_BYTES/FREE_BLOCKS/LARGEST_BYTES/LARGEST_BLKS)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Arquivos cheios podem não existir na view; contagem não é todos os datafiles. Ratio não é percentual livre do total alocado nem um extent contíguo global. Depende de instalação revisada da view.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @free_spc.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tablespace, arquivos presentes, peças, livre, soma dos maiores extents e ratio.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF no denominador e spool específico local. 
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
rem Name:     free_spc.sql
rem
rem FUNCTION: Provide data on tablespace extent status
rem FUNCTION: this report uses the free_space view
rem
SET FEED OFF
SET FLUSH OFF
SET VERIFY OFF
set pages 58 LINES 130
column tablespace      heading Name              format a30
column file_id         heading File#             format 99999
column pieces          heading Frag              format 9999
column free_bytes      heading 'Free Byte'
column free_blocks     heading 'Free Blk'
column largest_bytes   heading 'Biggest Bytes'
column largest_blks    heading 'Biggest Blks'
column ratio           heading 'Percent'         format 999.999
ttitle "FREE SPACE REPORT"
define 1 = 'free_spc.lst'
spool &1
select tablespace,count(*) files,sum(pieces) pieces,sum(free_bytes) free_bytes,
sum(free_blocks) free_blocks,sum(largest_bytes) largest_bytes,
sum(largest_blks) largest_blks, sum(largest_bytes)/nullif(sum(free_bytes),0)*100 ratio 
from free_space
group by tablespace;
spool off
clear columns
pause Press Enter to Continue
SET FEED ON
SET FLUSH ON
SET VERIFY ON
set pages 22 LINES 80
clear columns
ttitle off
