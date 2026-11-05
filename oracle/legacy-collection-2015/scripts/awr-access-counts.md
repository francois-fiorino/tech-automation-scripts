# Diagnóstico de operadores de join cartesiano

- **Arquivo de referência:** `_awr_scripts/awr_access_counts.sql`
- **Status:** Revisado estaticamente; não testado.

## Finalidade e funcionamento

Consulta `SYS.V_$SQL_PLAN` e conta `HASH_VALUE` distintos e linhas de plano com `OPERATION LIKE '%JOIN%'` e `OPTIONS='CARTESIAN'`. Não consulta AWR, apesar do diretório de origem.

## Pré-requisitos

`SELECT` sobre `SYS.V_$SQL_PLAN`; privilégios apropriados.

## Como preparar a execução

Nenhum parâmetro. Execute em SQL*Plus/SQLcl conectado ao ambiente de teste.

## Saída e interpretação

Duas contagens: instruções distintas por `HASH_VALUE` e linhas de plano. Não são execuções reais nem identificam necessariamente SQLs únicos por `SQL_ID`.

## Riscos e limitações

Somente leitura; verificar custo da consulta e o uso de `HASH_VALUE`.

## Aviso

**Segurança:** revise integralmente o SQL e teste primeiro em ambiente controlado. Uso por conta e risco do executor; conteúdo fornecido AS IS, sem garantia de funcionamento ou adequação. Os mantenedores não se responsabilizam por danos decorrentes do uso, nos limites legais.

> Esta ficha documenta o comportamento observado na inspeção estática. Não comprova compatibilidade com versões específicas do Oracle Database.
