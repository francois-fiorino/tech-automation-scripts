/*
===============================================================================
SCRIPT: block_pin.sql
CATEGORIA: Oracle / RAC / Global Cache
ORIGEM: Coleção Oracle 2015

OBJETIVO
  Apresentar razões de tempos acumulados de global cache por bloco current
  servido, separadas por instância RAC.

FUNCIONAMENTO
  Cruza quatro referências a GV$SYSSTAT por INST_ID, usando as estatísticas
  global cache current block build time, flush time, send time e
  global cache current blocks served. Divide cada tempo pelo número de blocos.

PRÉ-REQUISITOS
  Permissão de consulta a GV$SYSSTAT e estatísticas relevantes para RAC.

EXECUÇÃO (SOMENTE APÓS TESTES)
  SQL> @block_pin.sql

SAÍDA ESPERADA
  Instance, Current Block Pin, Log Flush Wait, Send Time.
  Os valores são razões de contadores acumulados, não latências instantâneas.

RISCOS E LIMITAÇÕES
  A versão original não protegia contra divisão por zero quando a estatística
  global cache current blocks served valia 0; podia ocorrer ORA-01476.
  CORREÇÃO: NULLIF(D.value, 0) retorna NULL quando não há blocos servidos,
  evitando ORA-01476. Não altera as estatísticas nem o banco.
  Validar unidades de tempo na versão Oracle e interpretar diferenças RAC.
  Compatibilidade e impacto operacional não foram homologados.

AVISO DE RESPONSABILIDADE
  Revise integralmente e teste em ambiente controlado antes do uso.
  Fornecido AS IS, sem garantias; uso por conta e risco do executor.
  Os mantenedores não se responsabilizam por danos decorrentes do uso,
  nos limites permitidos pela legislação aplicável.

ALTERAÇÕES DESTA VERSÃO
  2026-11-03: proteção contra divisão por zero nas três razões de tempo.
  Original preservado no histórico Git do arquivo.

STATUS: revisão estática; correção não testada em banco Oracle.
===============================================================================
*/

-- block_pin.sql

SELECT
   A.inst_id "Instance",
   (A.value/NULLIF(D.value,0)) "Current Block Pin",
   (B.value/NULLIF(D.value,0)) "Log Flush Wait",
   (C.value/NULLIF(D.value,0)) "Send Time"
FROM
  GV$SYSSTAT A,
  GV$SYSSTAT B,
  GV$SYSSTAT C,
  GV$SYSSTAT D
WHERE
  A.name = 'global cache current block build time' AND
  B.name = 'global cache current block flush time' AND
  C.name = 'global cache current block send time' AND
  D.name = 'global cache current blocks served' AND
  B.inst_id=a.inst_id AND
  C.inst_id=a.inst_id AND
  D.inst_id=a.inst_id
ORDER BY
  A.inst_id;
