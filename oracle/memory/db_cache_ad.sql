/*
===============================================================================
SCRIPT: db_cache_ad.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/db_cache_ad.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar cenários do advisor de buffer cache DEFAULT com bloco padrão.

FUNCIONAMENTO DETALHADO
  Filtra V$DB_CACHE_ADVICE por NAME, BLOCK_SIZE do parâmetro e ADVICE_STATUS=ON.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$DB_CACHE_ADVICE, V$PARAMETER

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Sem dados coletados/ADVICE ON pode não retornar linhas. Não recomenda alteração automática; não cobre caches de outros tamanhos ou KEEP/RECYCLE.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @db_cache_ad.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  SIZE_EST em MB conforme view, BUF_EST, EST_RF e EST_PR estimados.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta e créditos preservados; variante db_cache_ad9i será mapeada à mesma fonte exata. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
Rem db_cache_ad.sql
Rem from Oracle9i tuning
Rem Mike Ault Initial creation
Rem
col size_est   format 999,999,999,999 heading 'Cache Size (m)'
col buf_est    format 999,999,999     heading 'Buffers'
col est_rf format 999.90       heading 'Estd Phys|Read Factor'
col est_pr format 999,999,999     heading 'Estd Phys| Reads'
SET LINES 80 PAGES 55
ttitle 'DB Cache Advisor Report'
spool db_cache_ad.lst
SELECT 
   size_for_estimate size_est, 
   buffers_for_estimate buf_est,
   estd_physical_read_factor est_rf, 
   estd_physical_reads est_pr
 FROM V$DB_CACHE_ADVICE
 WHERE name = 'DEFAULT'
   AND block_size = (SELECT value FROM V$PARAMETER 
                     WHERE name = 'db_block_size')
   AND advice_status='ON';
SPOOL OFF
SET PAGES 22
TTITLE OFF
