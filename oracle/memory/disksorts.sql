/*
===============================================================================
SCRIPT: disksorts.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/disksorts.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Estimar tamanho médio alocado por linha de segmento de sort em cada tablespace.

FUNCIONAMENTO DETALHADO
  Obtém DB_BLOCK_SIZE e agrupa V$SORT_SEGMENT por TABLESPACE_NAME, calculando SUM(TOTAL_BLOCKS)/COUNT(*) vezes tamanho padrão de bloco.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$PARAMETER, V$SORT_SEGMENT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não é média por operação de sort nem espaço livre atual. V$ local; unidade do tamanho usa bloco padrão, validar adequação ao ambiente. Contagem depende do modelo de segmentos temporários da versão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @disksorts.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  TABLESPACE_NAME, AREAS (linhas contadas na view) e AVG_SORT_BYTES.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Nome de parâmetro incorreto db block size corrigido para db_block_size; consulta do valor passa a encontrar a linha padrão. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Wrapper externo substituído por TTITLE local.
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
REM FUNCTION: Generate a summary of Disk Sort Area Usage
REM
REM disksort.sql 
REM
COLUMN value NEW_VALUE bs NOPRINT
SELECT value FROM v$parameter WHERE name='db_block_size';
ttitle "Instance Disk Area Average Sizes"
spool disksorts.lst
SELECT
	Tablespace_name,
	COUNT(*) areas,
	(SUM(total_blocks)/COUNT(*))*&&bs avg_sort_bytes
FROM v$sort_segment
GROUP BY tablespace_name;
SPOOL OFF
