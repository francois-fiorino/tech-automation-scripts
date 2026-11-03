# Relatório de revisão e publicação da coleção Oracle 2015

Atualizado em 03/11/2026. **Projeto em andamento: revisão estática e publicação de implementações novas; homologação Oracle e propostas administrativas continuam pendentes.**

## Estado atual reconciliado

| Medida | Total | Critério |
|---|---:|---|
| Origens inventariadas | 697 | 693 SQL e quatro auxiliares |
| Implementações únicas na main | 452 | 432 anteriores + 20 novas |
| Implementações somente na branch/PR #2 | 175 | 175 anteriores + 0 novos geradores |
| Origens variantes/canônicas compartilhadas | 33 | 32 anteriores + 1 novas correspondências compartilhadas |
| Fontes sem implementação funcional | 5 | placeholders/referências sem código; não publicadas ficticiamente |
| Requisitos das 49 fontes retidas atendidos por código novo | 21 | 20 implementações novas com conteúdo publicado e verificado |
| Requisitos ainda aguardando nova implementação publicada | 28 | fila de requisitos, sem republicar código original |
| Fontes originais restritas republicadas | 0 | os 49 originais permanecem retidos |
| Pendências de main | 203 | 175 propostas no PR + 28 requisitos restantes |
| Compilações/execuções efetivas em Oracle | 0 | parser local e fixtures não são homologação Oracle |

Os oito scripts anteriores à campanha continuam incluídos nas 432 implementações preservadas. Novas implementações não são contadas como correções do código original, nem como licença ou autorização de redistribuição. Cada cabeçalho descreve as diferenças funcionais, dependências, parâmetros, riscos, referências e limites de validação.

## Continuidade e rastreabilidade

- [Inventário por origem](inventory.csv): 697 linhas, com SHA-256 da fonte preservado e destino efetivo de cada requisito.
- [Mapeamento de implementações novas](INDEPENDENT_IMPLEMENTATIONS.md): origens, caminhos, commits e blobs; diferenças técnicas e roteiro de homologação.
- [Verificação das implementações novas](INDEPENDENT_VERIFICATION.json): apenas entradas com publicação confirmada.
- [Reconciliação anterior](RECONCILIATION.json) e [snapshot inicial](VERIFICATION.json): registros históricos, não totais atuais.
- [Histórico de lotes](PROGRESS.md) e [relatório anterior ao desenvolvimento novo](https://github.com/francois-fiorino/tech-automation-scripts/blob/b99c3cf9f317f0115ece1ec71f287b07ed88ede4/oracle/collection/REPORT.md): preservam os lotes 001–032, correções e evidências anteriores.
- [Aviso original](ORIGINAL_README.txt) preservado. A fonte original com credencial continua retida; somente a proposta sanitizada de link está no PR.

## Lotes de implementações novas

| Lote | Arquivos únicos | Destino | Commit de conteúdo |
|---|---:|---|---|
| 033 | 20 | main | [334b807a51](https://github.com/francois-fiorino/tech-automation-scripts/commit/334b807a5142f5f4e31b04607f7d2e1391f932d1) |

Cada lote tem no máximo 20 implementações; a correspondência pode atender mais de uma origem equivalente. Publicação confirmada por caminho e SHA de blob Git. Não foram sobrescritos scripts existentes ou integrados PRs.

## Categorias atuais

| Categoria | Main | Somente PR |
|---|---:|---:|
| `administration/` | 30 | 92 |
| `administration/legacy-linux/` | 0 | 1 |
| `administration/windows/` | 0 | 1 |
| `asm/` | 2 | 0 |
| `backup-recovery/` | 3 | 8 |
| `memory/` | 43 | 1 |
| `monitoring/` | 64 | 0 |
| `objects/` | 65 | 47 |
| `objects/indexes/` | 11 | 0 |
| `performance/` | 31 | 2 |
| `performance/ash/` | 17 | 0 |
| `performance/awr/` | 36 | 0 |
| `performance/sql/` | 23 | 1 |
| `performance/statspack/` | 1 | 0 |
| `rac/` | 40 | 1 |
| `rac/grid/` | 1 | 0 |
| `security/` | 19 | 19 |
| `storage/` | 34 | 0 |
| `troubleshooting/` | 32 | 2 |

Os novos scripts ficam em subpastas `independent/` dentro da categoria. Contagens por categoria incluem essas subpastas, sem contar variantes duas vezes.

## Achados e diferenças técnicas

Muitos nomes históricos divergiam do conteúdo. As novas implementações usam nomes funcionais: catálogo, amostras de espera, séries de deltas, presença de planos, I/O, buckets ASSM e advisory de cache. Métricas de presença/amostra/estimativa são identificadas como tais. As diferenças não foram escondidas como equivalência integral.

As consultas de planos usam SQLSTAT agregado e EXISTS ou conjuntos DISTINCT de referências para não multiplicar métricas por passos. DBID, instância e snapshot são chaves explícitas; plano e container entram nas associações correspondentes. Deltas de contadores isolam reinícios e evitam divisão por zero. Tamanho de segmento é atual, não reconstrução histórica. Datas usam chaves cronológicas ou dia ISO.

As implementações de exportação e coalescência geram texto administrativo para revisão: nenhuma saída foi aplicada. O relatório ASSM é bloco anônimo, sem DROP/CREATE de tipos ou função persistente. Scripts AWR/ASH continuam sujeitos ao direito de uso do recurso Oracle, independentemente da autoria do SQL.

## Validação e limites

As 697 origens foram reconferidas por SHA-256 na retomada. Os 607 destinos anteriores foram conferidos por caminho/blob, sem alteração de código; a errata de GET_COND no inventário aponta ao commit correto. Os novos arquivos são comparados ao blob Git esperado antes de serem registrados como publicados.

No conjunto novo preparado: 44 consultas passaram pelo parser local SQLGlot (dialeto Oracle), dois blocos PL/SQL tiveram revisão manual, declarações de binds foram conferidas e fixtures relacionais passaram para reinício/instância, gap de snapshot, denominador zero, ponderação e deduplicação de planos. Não houve compilação, execução, plano de execução ou teste de recuperação/exportação em Oracle. O parser local não prova validade de colunas ou comportamento no runtime Oracle.

Filtro de container exige validação no ambiente: views históricas podem armazenar métricas agregadas em CON_ID=0 mesmo com sessão root=1. A consulta usa o container da sessão e pode retornar vazio nesse caso; ajustar conscientemente o escopo em cópia de laboratório. Retenção AWR/ASH, privilégios, custo e versões precisam de validação individual. Cabeçalhos não alegam homologação 11g–23ai.

## PRs e impedimentos

- [PR #1](https://github.com/francois-fiorino/tech-automation-scripts/pull/1): documentação preliminar histórica, oito commits/cinco arquivos. O SQL proposto já tem canônico na main; não mesclar automaticamente nem substituir totais atuais por seu inventário antigo.
- [PR #2](https://github.com/francois-fiorino/tech-automation-scripts/pull/2): 175 propostas, incluindo DDL/DML, autenticação, backups e geradores administrativos. Permanecem em Draft. Falhas conhecidas, dependências customizadas, contratos e homologação estão descritos nos cabeçalhos. Não equivalem a scripts aprovados para implantação.
- Os 49 originais com avisos restritivos continuam retidos. A fila técnica avança por implementações novas dos requisitos, sem alegar autorização para republicar o acervo original.
- Cinco origens sem implementação funcional e auxiliares sem código seguem classificados no inventário; não são pendências fictícias de publicação de SQL.

## Próximo ponto de retomada

Publicar as implementações preparadas dos lotes seguintes, selecionando somente os requisitos ainda não mapeados no inventário. Não repetir os lotes já confirmados.

Nenhum merge automático está autorizado. O projeto não é declarado concluído enquanto as propostas e homologações pendentes permanecerem abertas. Não há execução em segundo plano.
