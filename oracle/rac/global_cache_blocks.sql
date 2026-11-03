/*
===============================================================================
SCRIPT: global_cache_blocks.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_grid_scripts/global_cache_blocks.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir contadores de blocos global cache perdidos e corrompidos nas instâncias 1 e 2.

FUNCIONAMENTO DETALHADO
  Cruza quatro seleções GV$SYSSTAT, cada uma limitada a INST_ID e NAME específicos; retorna quatro contadores numa linha.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$SYSSTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Nomes de estatísticas global cache são legados; confirmar existência e unidades na versão RAC. INNER JOIN omite instâncias se alguma estatística não existir. Contadores acumulados, não métricas do último intervalo. Instâncias 1 e 2 são fixas; se qualquer uma ou estatística estiver ausente, não há linha. Não cobre clusters com outra numeração nem outras instâncias.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @global_cache_blocks.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  GC BLOCKS LOST 1/2 e GC BLOCKS CORRUPT 1/2.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Marca BOM removida; consulta completa preservada. BOM UTF-8 da origem normalizado sem inserir caracteres no SQL.
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

-- global_cache_blocks.sql

SELECT
      A.VALUE "GC BLOCKS LOST 1",
      B.VALUE "GC BLOCKS CORRUPT 1",
      C.VALUE "GC BLOCKS LOST 2",
      D.VALUE "GC BLOCKS CORRUPT 2"
FROM GV$SYSSTAT A, GV$SYSSTAT B, GV$SYSSTAT C, GV$SYSSTAT D
WHERE A.INST_ID=1 AND A.NAME='global cache blocks lost'
  AND B.INST_ID=1 AND B.NAME='global cache blocks corrupt'
  AND C.INST_ID=2 AND C.NAME='global cache blocks lost'
  AND D.INST_ID=2 AND D.NAME='global cache blocks corrupt';