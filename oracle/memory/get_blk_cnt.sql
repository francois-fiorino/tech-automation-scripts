/*
===============================================================================
SCRIPT: get_blk_cnt.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _segment_scripts/get_blk_cnt.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Contar buffers associados a extents de segmentos em um arquivo informado.

FUNCIONAMENTO DETALHADO
  Relaciona V$BH a DBA_EXTENTS por FILE# e faixa inclusiva BLOCK_ID até BLOCK_ID+BLOCKS-1; agrupa por arquivo/nome do segmento.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$BH, DBA_EXTENTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  V$BH pode ser onerosa; join por faixas em todos os extents do arquivo exige avaliar plano. Filtros de B tornam o outer join efetivamente interno, sem linhas UNUSED; nomes homônimos podem se agregar. Validar CON_ID no contexto multitenant.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE file_id = 4
  @get_blk_cnt.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  FILE#, SEGMENT_NAME, BLOCKS (headers de buffer) e DISTINCT_BLOCKS.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  GROUP BY corrigido para SEGMENT_NAME, compatível com SELECT; limite do extent reduzido em um bloco; COUNT DISTINCT usa BLOCK# pois arquivo já está no agrupamento. 
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

-- COMMENT:  segment extent report
SELECT a.file#,decode(b.segment_name,null,'UNUSED',b.segment_name) segment_name,
       COUNT(a.block#) Blocks,
       COUNT (DISTINCT a.block#) Distinct_blocks
   FROM V$BH a, dba_extents b
   WHERE a.file#=b.file_id(+)
   and b.file_id=&file_id
   and a.block# between b.block_id and b.block_id+b.blocks-1
   GROUP BY a.file#,decode(b.segment_name,null,'UNUSED',b.segment_name)
/
