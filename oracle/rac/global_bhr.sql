/*
===============================================================================
SCRIPT: global_bhr.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_grid_scripts/global_bhr.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Apresentar razão histórica de atividade de cache global sobre gets locais.

FUNCIONAMENTO DETALHADO
  Soma global cache gets, converts, CR blocks received e current blocks received, dividindo por consistent gets+db block gets por instância.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$SYSSTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Nomes de estatísticas global cache são legados; confirmar existência e unidades na versão RAC. INNER JOIN omite instâncias se alguma estatística não existir. Contadores acumulados, não métricas do último intervalo. O nome hit ratio não é definição canônica de buffer cache hit: numerador combina atividades distintas que podem se sobrepor. Não usar isoladamente para dimensionar cache.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @global_bhr.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Instance e GLOBAL CACHE HIT RATIO como fração segundo fórmula original.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  E.VALUE+F.VALUE protegido por NULLIF; fórmula original preservada e ressalvada. 
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

-- global_bhr.sql

SELECT
  a.inst_id "Instance",
  (A.VALUE+B.VALUE+C.VALUE+D.VALUE)/nullif(E.VALUE+F.VALUE,0) "GLOBAL CACHE HIT RATIO"
FROM
  GV$SYSSTAT A,
  GV$SYSSTAT B,
  GV$SYSSTAT C,
  GV$SYSSTAT D,
  GV$SYSSTAT E,
  GV$SYSSTAT F
WHERE
  A.NAME='global cache gets'
  AND B.NAME='global cache converts'
  AND C.NAME='global cache cr blocks received'
  AND D.NAME='global cache current blocks received'
  AND E.NAME='consistent gets'
  AND F.NAME='db block gets'
  AND B.INST_ID=A.INST_ID
  AND C.INST_ID=A.INST_ID
  AND D.INST_ID=A.INST_ID
  AND E.INST_ID=A.INST_ID
  AND F.INST_ID=A.INST_ID;