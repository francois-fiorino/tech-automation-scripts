/*
===============================================================================
SCRIPT: gc_blocks_lost.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_grid_scripts/gc_blocks_lost.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relacionar blocos global cache perdidos com CR/current servidos por instância.

FUNCIONAMENTO DETALHADO
  Une três GV$SYSSTAT por INST_ID, lê blocos perdidos, current servidos e CR servidos, e divide perdas pela soma servida.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$SYSSTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Nomes de estatísticas global cache são legados; confirmar existência e unidades na versão RAC. INNER JOIN omite instâncias se alguma estatística não existir. Contadores acumulados, não métricas do último intervalo. RATIO usa denominador de blocos servidos, não recebidos; não prova perda de rede nem corrupção física.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @gc_blocks_lost.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  INSTANCE, GC BLOCKS LOST, GC CUR BLOCKS SERVED, GC CR BLOCKS SERVED e RATIO.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Soma B.VALUE+C.VALUE protegida por NULLIF. 
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

-- gc_blocks_lost.sql

SELECT A.INST_ID "INSTANCE", A.VALUE "GC BLOCKS LOST",
B.VALUE "GC CUR BLOCKS SERVED",
C.VALUE "GC CR BLOCKS SERVED",
A.VALUE/nullif(B.VALUE+C.VALUE,0) RATIO
FROM GV$SYSSTAT A, GV$SYSSTAT B, GV$SYSSTAT C
WHERE A.NAME='global cache blocks lost' AND
      B.NAME='global cache current blocks served' AND
      C.NAME='global cache cr blocks served' and
      B.INST_ID=a.inst_id AND
      C.INST_ID = a.inst_id;