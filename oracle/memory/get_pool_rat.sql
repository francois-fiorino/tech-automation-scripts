/*
===============================================================================
SCRIPT: get_pool_rat.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/get_pool_rat.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Calcular razão histórica entre gets lógicos e soma de gets mais leituras físicas por pool.

FUNCIONAMENTO DETALHADO
  Em V$BUFFER_POOL_STATISTICS calcula (DB_BLOCK_GETS+CONSISTENT_GETS)/(DB_BLOCK_GETS+CONSISTENT_GETS+PHYSICAL_READS).

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$BUFFER_POOL_STATISTICS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  A fórmula não equivale ao hit ratio convencional 1-physical_reads/logical_gets. Contadores acumulados; não usar isoladamente para dimensionar cache.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @get_pool_rat.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  NAME e HIT_RATIO como fração segundo fórmula histórica.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Soma denominadora protegida com NULLIF; fórmula e comentário originais preservados. 
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
rem h_ratio := ((db_gets+con_gets)/(db_gets+con_gets+p_reads)); 

select name,((db_block_gets+consistent_gets)/nullif(db_block_gets+consistent_gets+physical_reads,0)) hit_ratio
from v$buffer_pool_statistics;
