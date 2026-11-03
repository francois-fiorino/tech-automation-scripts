# Biblioteca de scripts Oracle

Coleção histórica Oracle Script Collection 2015 organizada e documentada em português brasileiro. **Revisão estática: nenhum script foi compilado ou executado em Oracle neste trabalho.** Consulte o cabeçalho individual antes de qualquer uso.

[Inventário por origem e arquivo publicado](collection/inventory.csv) · [Relatório detalhado e commits](collection/REPORT.md) · [Histórico](collection/PROGRESS.md) · [Aviso original da coleção](collection/ORIGINAL_README.txt)

A main contém **432 implementações únicas** da coleção, incluindo oito anteriores preservadas. Há **174 propostas de maior risco no [PR #2](https://github.com/francois-fiorino/tech-automation-scripts/pull/2)**, fora desta contagem, além de 49 fontes retidas para esclarecimento de licença e uma por credencial. Trinta e duas variantes apontam a arquivos canônicos e cinco origens não possuem implementação funcional. Todos os 697 arquivos de origem foram classificados; o projeto permanece aberto pelos impedimentos registrados.

## Consultar por categoria

As contagens são de arquivos diretamente classificados em cada categoria, sem duplicar o total de subpastas.

| Categoria | Arquivos na main |
|---|---:|
| [administration](administration/) | 30 |
| [asm](asm/) | 2 |
| [backup-recovery](backup-recovery/) | 3 |
| [memory](memory/) | 43 |
| [monitoring](monitoring/) | 64 |
| [objects](objects/) | 65 |
| [objects/indexes](objects/indexes/) | 11 |
| [performance](performance/) | 31 |
| [performance/ash](performance/ash/) | 11 |
| [performance/awr](performance/awr/) | 25 |
| [performance/sql](performance/sql/) | 22 |
| [performance/statspack](performance/statspack/) | 1 |
| [rac](rac/) | 40 |
| [rac/grid](rac/grid/) | 1 |
| [security](security/) | 19 |
| [storage](storage/) | 32 |
| [troubleshooting](troubleshooting/) | 32 |

## Execução e interpretação

Leia objetivo, pré-requisitos, views/pacotes, exemplos, unidades, limitações e riscos no cabeçalho de cada arquivo. Execute em SQL*Plus/SQLcl com os grants e parâmetros documentados, primeiro em desenvolvimento/homologação. Scripts históricos podem depender de versões, estruturas internas ou tabelas de aplicação que não existem no ambiente atual. Contadores acumulados, estatísticas e estimativas não devem ser interpretados automaticamente como taxas ou recomendações de alteração.

Não há instalador para executar a coleção inteira. As propostas administrativas possuem DDL/DML, jobs, autenticação, backups e geradores com contratos alternativos; permanecem em revisão, não homologadas para implantação. AWR/ASH exige verificar o direito de uso aplicável.

Os arquivos adicionais que já existiam no repositório foram preservados integralmente e não foram incluídos ficticiamente nas contagens da coleção.

## Responsabilidade

Conteúdo fornecido AS IS para fins técnicos, educacionais e administrativos, sem garantia de funcionamento, compatibilidade, desempenho ou adequação. O usuário deve analisar integralmente o código, compreender seus efeitos e testar em ambiente controlado antes de utilizar. A execução ocorre por sua conta e risco; os mantenedores não assumem responsabilidade por danos, perdas de dados, indisponibilidade ou outros impactos, nos limites legais aplicáveis. Os avisos e créditos históricos de cada fonte continuam preservados.
