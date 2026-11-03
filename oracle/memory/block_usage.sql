/*
===============================================================================
SCRIPT: block_usage.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/block_usage.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Contar buffers e números de blocos distintos em cache por arquivo e tablespace.

FUNCIONAMENTO DETALHADO
  LEFT OUTER JOIN de V$BH a DBA_DATA_FILES por FILE#; agrupa por arquivo e tablespace, rotulando sem correspondência como UNUSED e contando buffers e blocos distintos.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$BH, DBA_DATA_FILES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Leitura de V$BH pode ser onerosa em cache grande. UNUSED significa sem mapeamento no join, não comprova buffer livre; validar CON_ID em CDB e mapear arquivos adequadamente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @block_usage.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  TS_NAME, FILE_NUMBER, BLOCKS e DISTINCT_BLOCKS; versões CR podem produzir mais buffers que blocos distintos.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  COUNT(DISTINCT BLOCK#) substitui concatenação FILE#||BLOCK#, pois FILE# já compõe GROUP BY; evita representação textual concatenada sem necessidade. Wrappers title80/title132 ausentes substituídos por TTITLE local.
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
rem block_usage.sql
rem comment: show block usage inside SGA
rem MRA
rem
break on report
compute sum of distinct_blocks on report
compute sum of blocks on report
ttitle 'Block Usage Inside SGA Block Buffers'
spool block_usage
SELECT decode(b.tablespace_name,null,'UNUSED',b.tablespace_name) ts_name,
       a.file# file_number,
       COUNT(a.block#) Blocks,
       COUNT (DISTINCT a.block#) Distinct_blocks
   FROM V$BH a, dba_data_files b
   WHERE a.file#=b.file_id(+)
   GROUP BY a.file#,decode(b.tablespace_name,null,'UNUSED',b.tablespace_name)
/
spool off
ttitle off


