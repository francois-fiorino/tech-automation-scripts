/*
===============================================================================
SCRIPT: sort_segment.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / misc_scripts/sort_segment.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Resumir alocações temporárias por números de arquivo de segmento.

FUNCIONAMENTO DETALHADO
  Consulta V$SORT_USAGE e relaciona TABLESPACE a DBA_TABLESPACES para converter BLOCKS usando BLOCK_SIZE; soma extents/MiB por SEGRFNO#/SEGFILE#.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SORT_USAGE, DBA_TABLESPACES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  V$SORT_USAGE é interface histórica para alocação temporária; não calcula ocupação física de disco nem identifica cada sessão/segmento. Validar container.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @sort_segment.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  FILE_NO relativo, SORT_SEG (SEGFILE#, não número do segmento), extents e MEG.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Constante 8192 substituída pelo tamanho do bloco do tablespace; aliases qualificam as colunas. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
ttitle 'Sort Segment List'
spool sort_segment.lst
select segrfno# File_no,segfile# sort_seg,sum(u.extents) extents, sum(u.blocks*t.block_size)/(1024*1024) meg
from v$sort_usage u join dba_tablespaces t on t.tablespace_name=u.tablespace group by segrfno#,segfile#
/
spool off

