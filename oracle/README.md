# Biblioteca de scripts Oracle

Acervo de scripts Oracle e implementações novas, com documentação técnica em português no próprio código. **Revisão estática; nenhum script foi compilado ou executado em Oracle neste trabalho.**

[Inventário de 697 origens](collection/inventory.csv) · [Relatório atualizado](collection/REPORT.md) · [Implementações novas](collection/INDEPENDENT_IMPLEMENTATIONS.md) · [Histórico](collection/PROGRESS.md) · [Aviso original](collection/ORIGINAL_README.txt)

A main contém **476 implementações únicas** (44 novas nesta etapa). O [PR #2](https://github.com/francois-fiorino/tech-automation-scripts/pull/2) mantém **177 propostas administrativas** em revisão. Dos 49 requisitos de fontes retidas, **49** já têm código novo publicado, em **46** implementações; **0** aguardam publicação. Os originais restritos continuam retidos. As diferenças funcionais estão nos cabeçalhos e no mapeamento; três requisitos equivalentes compartilham destinos quando a fila estiver completa.

## Consultar por categoria

| Categoria | Main | Somente PR |
|---|---:|---:|
| `administration/` | 30 | 93 |
| `administration/legacy-linux/` | 0 | 1 |
| `administration/windows/` | 0 | 1 |
| `asm/` | 2 | 0 |
| `backup-recovery/` | 3 | 9 |
| `memory/` | 48 | 1 |
| `monitoring/` | 67 | 0 |
| `objects/` | 65 | 47 |
| `objects/indexes/` | 12 | 0 |
| `performance/` | 31 | 2 |
| `performance/ash/` | 17 | 0 |
| `performance/awr/` | 47 | 0 |
| `performance/sql/` | 23 | 1 |
| `performance/statspack/` | 1 | 0 |
| `rac/` | 40 | 1 |
| `rac/grid/` | 1 | 0 |
| `security/` | 19 | 19 |
| `storage/` | 37 | 0 |
| `troubleshooting/` | 33 | 2 |

Os novos arquivos estão nas subpastas `independent/`. Leia cada cabeçalho para configurar parâmetros, grants, escopo de instância/container e custos. AWR/ASH exige direito de uso aplicável. Contagens ASH são amostras; associação de SQL a plano/objeto não representa contagem exata de execuções de operadores.

## Utilização

Execute individualmente em SQL*Plus/SQLcl, primeiro em laboratório. Não existe instalador da coleção. DDL/DML, autenticação, backup/recovery e aplicação de comandos gerados exigem revisão do impacto e homologação específica. Nenhuma proposta de PR foi incorporada automaticamente.

## Responsabilidade

AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de qualquer utilização em produção. Sua execução é de responsabilidade do profissional responsável pelo ambiente. Os mantenedores deste repositório não se responsabilizam por indisponibilidade, perda de dados, alterações indevidas ou outros impactos decorrentes de sua utilização.
