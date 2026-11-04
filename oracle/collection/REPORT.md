# Relatório de revisão e publicação da coleção Oracle 2015

Atualizado em 04/11/2026. **Projeto em andamento: revisão estática e publicação de implementações novas; homologação Oracle e propostas administrativas continuam pendentes.**

## Estado atual reconciliado

| Medida | Total | Critério |
|---|---:|---|
| Origens inventariadas | 697 | 693 SQL e quatro auxiliares |
| Implementações únicas na main | 476 | 432 anteriores + 44 novas |
| Implementações somente na branch/PR #2 | 177 | 175 anteriores + 2 novos geradores |
| Origens variantes/canônicas compartilhadas | 35 | 32 anteriores + 3 novas correspondências compartilhadas |
| Fontes sem implementação funcional | 5 | placeholders/referências sem código; não publicadas ficticiamente |
| Requisitos das 49 fontes retidas atendidos por código novo | 49 | 46 implementações novas com conteúdo publicado e verificado |
| Requisitos ainda aguardando nova implementação publicada | 0 | fila de requisitos, sem republicar código original |
| Fontes originais restritas republicadas | 0 | os 49 originais permanecem retidos |
| Pendências de main | 177 | 177 propostas no PR + 0 requisitos restantes |
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
| 034 | 20 | main | [4f2cbcf7ba](https://github.com/francois-fiorino/tech-automation-scripts/commit/4f2cbcf7bac0bb41e804281a0eff41be186823b4) |
| 035 | 4 | main | [134ab289fd](https://github.com/francois-fiorino/tech-automation-scripts/commit/134ab289fd9c3654515f9182ce26aa65ab18e9c4) |
| 035 | 2 | oracle/review-legacy-admin-20261103 | [c00e04d00c](https://github.com/francois-fiorino/tech-automation-scripts/commit/c00e04d00c9b76e58a325fbfbeeb6b481b26b007) |

Cada lote tem no máximo 20 implementações; a correspondência pode atender mais de uma origem equivalente. Publicação confirmada por caminho e SHA de blob Git. Não foram sobrescritos scripts existentes ou integrados PRs.

## Categorias atuais

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
- [PR #2](https://github.com/francois-fiorino/tech-automation-scripts/pull/2): 177 propostas, incluindo DDL/DML, autenticação, backups e geradores administrativos. Permanecem em Draft. Falhas conhecidas, dependências customizadas, contratos e homologação estão descritos nos cabeçalhos. Não equivalem a scripts aprovados para implantação.
- Os 49 originais com avisos restritivos continuam retidos. A fila técnica avança por implementações novas dos requisitos, sem alegar autorização para republicar o acervo original.
- Cinco origens sem implementação funcional e auxiliares sem código seguem classificados no inventário; não são pendências fictícias de publicação de SQL.

## Revisão administrativa complementar — lote 036

Foram reavaliados 20 scripts do PR #2: 16 receberam alterações de código e quatro tiveram as pendências detalhadas com corpo preservado. Commit: [0c6e9ce71d](https://github.com/francois-fiorino/tech-automation-scripts/commit/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a). Os 20 arquivos e o teste auxiliar foram conferidos após publicação; nenhum foi executado em Oracle.

Correções incluem INSERT SELECT válido, validação de SID/SERIAL, quoting e invoker rights em rotinas sensíveis, coluna STARTUP_TIME documentada, datafiles sem extents livres, conversões/duração, chamadas LogMiner sem SQL concatenado, buffers/quoting de sequências e binds DATE/ROWID na atualização por lotes. Permanecem as limitações e dependências individuais, sem aprovação de implantação.

[Revisão e testes por script](ADMIN_REVIEW.md) · [Hashes e fila de continuidade](ADMIN_REVIEW_VERIFICATION.json). Após o lote 036 restavam **157 de 177** scripts para esta revisão complementar; homologação Oracle continua pendente nos 177. O arquivo auxiliar `oracle/collection/tests/review036_lab.sql` não aumenta a contagem de implementações da coleção. Os totais permanecem **476 main e 177 revisão**.

Ajuste final da revisão 036: [parâmetros internos do cursor UPDATE_IT desambiguados](https://github.com/francois-fiorino/tech-automation-scripts/commit/256f3206a5c43e46ccff203a13ff3fe3fa99ac48); não altera a quantidade de scripts revisados. Branch administrativa confirmada em `256f3206a5c43e46ccff203a13ff3fe3fa99ac48`.

## Revisão administrativa complementar — lote 037

Mais 20 scripts reavaliados: 11 alterações de código e nove corpos preservados com pendências explícitas. Commit confirmado: [5c46898439](https://github.com/francois-fiorino/tech-automation-scripts/commit/5c46898439576d594ef844d4575660995fb4fadf). O gerador de links usa metadados sem leitura de senha e gera saída bloqueada; o ciclo da tabela de reparo evita purge/drop de evidências; o template de cluster inclui índice/mapeamento correto; a amostragem de subconjunto tem proteção de visita e emissão de percentual sem dependência de NLS; shared pool recebe validação/cleanup; HITRATIO trata denominador zero sem inserir segunda coleta artificial.

Acumulado desta fase: **40 de 177** scripts reavaliados (**27 alterações de código e 13 revisões documentais**). Após o lote 037 restavam **137** na fila complementar, além de homologação dos 177. Os 20 arquivos do lote 037 foram confirmados por caminho/conteúdo/blob. Parser local e fixtures passaram; nenhum Oracle/Windows foi executado. Detalhes em [ADMIN_REVIEW.md](ADMIN_REVIEW.md) e [ADMIN_REVIEW_VERIFICATION.json](ADMIN_REVIEW_VERIFICATION.json). Totais permanecem 476 main e 177 propostas; nenhum merge.

## Revisão administrativa complementar — lote 038 (04/11/2026)

Mais 20 scripts: **nove alterações de código e 11 revisões documentais**. Publicação confirmada no commit [169cc5270f](https://github.com/francois-fiorino/tech-automation-scripts/commit/169cc5270f3af21fc0a336badeda46c314beb09c). Corrigidos gerador de identidade ROWID, colisão de nomes no staging de índices, quoting/buffers, CTAS externo, lista IN e guardas contra TRUNCATE após CREATE falho. O Shell legado agora tem barreira incondicional antes de hdparm/escritas em /proc; valores/comandos históricos permanecem abaixo para revisão, sem execução.

Todos os 1.290 INSERTs de FILL_SZ foram conferidos por parser e estrutura; corpo integral preservado. Fixtures locais e `sh -n` passaram. Não houve compilação/execução Oracle nem ajuste de kernel/disco; não foram declarados homólogos os algoritmos preservados. As pendências por script constam em [ADMIN_REVIEW.md](ADMIN_REVIEW.md).

Acumulado após lote 038: **60/177 scripts reavaliados**, **36 alterações de código e 24 revisões documentais**, com **117** na fila complementar. Os 20 arquivos deste lote foram conferidos por conteúdo/caminho/blob após publicação. Totais da coleção permanecem **476 main e 177 propostas**; nenhum merge. [Checkpoint e próxima fila](ADMIN_REVIEW_VERIFICATION.json).

## Revisão administrativa complementar — lote 039 (04/11/2026)

20 scripts revisados: cinco alterações de código e 15 revisões documentais. Commit confirmado: [4c88d359890cc82a98e6ae3f1a5307a1072a3266](https://github.com/francois-fiorino/tech-automation-scripts/commit/4c88d359890cc82a98e6ae3f1a5307a1072a3266). Corrigidos parâmetros de WRITE_OUT, interrupção em falha SQL de três geradores, exclusão da tabela de trabalho no gerador de tabelas e qualificação de colunas em TAB_STAT_COL. ROLE_RCT bloqueado antes de extração de verificadores. Pendências individuais e validações locais em ADMIN_REVIEW.md e ADMIN_REVIEW_VERIFICATION.json; sem Oracle ou merge.

Acumulado após lote 039: **80/177**, sendo **41 alterações de código e 39 revisões documentais**. Restam **97** na revisão complementar. Totais preservados: 476 implementações na main e 177 propostas. Próxima fila: 040.

## Revisão administrativa complementar — lote 040 (04/11/2026)

20 scripts revisados: oito alterações de código e 12 revisões documentais. Commit confirmado: [0c166abfb7ae7feb2b08a436ff1f36e6544141a3](https://github.com/francois-fiorino/tech-automation-scripts/commit/0c166abfb7ae7feb2b08a436ff1f36e6544141a3). Corrigidos PCTFREE/PCTUSED, direitos do invocador em L_LENGTH, interrupção SQL em cinco geradores de staging, ordem do status em dois geradores de tablespace e cleanup/quoting em AUTO_DEFRAG. Pendências individuais e validações locais em ADMIN_REVIEW.md e ADMIN_REVIEW_VERIFICATION.json; sem Oracle ou merge.

Acumulado após lote 040: **100/177**, sendo **49 alterações de código e 51 revisões documentais**. Restam **77** na revisão complementar. Totais preservados: 476 implementações na main e 177 propostas. Próxima fila: 041.

## Revisão administrativa complementar — lote 041 (04/11/2026)

20 scripts revisados: 13 alterações de código e 7 revisões documentais. Commit confirmado: [3fc3bdcee0403d9e6620375eb3fb00fc39fe3085](https://github.com/francois-fiorino/tech-automation-scripts/commit/3fc3bdcee0403d9e6620375eb3fb00fc39fe3085). Todos os caminhos/conteúdos/blobs conferidos após publicação na branch do PR #2. Pendências individuais e validações locais em ADMIN_REVIEW.md e ADMIN_REVIEW_VERIFICATION.json. Sem compilação/execução Oracle, comandos administrativos ou merge.

Acumulado após lote 041: **120/177**, sendo **62 alterações de código e 58 revisões documentais**. Restam **57** na revisão complementar, além da homologação dos 177. Totais preservados: 476 implementações main e 177 propostas. Próxima fila: 042.

## Revisão administrativa complementar — lote 042 (04/11/2026)

20 scripts revisados: 10 alterações de código e 10 revisões documentais. Commit confirmado: [03db2a43adc925940e10462a1b15dca94abbb670](https://github.com/francois-fiorino/tech-automation-scripts/commit/03db2a43adc925940e10462a1b15dca94abbb670). Todos os caminhos/conteúdos/blobs conferidos após publicação na branch do PR #2. Pendências individuais e validações locais em ADMIN_REVIEW.md e ADMIN_REVIEW_VERIFICATION.json. Sem compilação/execução Oracle, comandos administrativos ou merge.

Acumulado após lote 042: **140/177**, sendo **72 alterações de código e 68 revisões documentais**. Restam **37** na revisão complementar, além da homologação dos 177. Totais preservados: 476 implementações main e 177 propostas. Próxima fila: 043.

## Revisão administrativa complementar — lote 043 (04/11/2026)

20 scripts revisados: 11 alterações de código e 9 revisões documentais. Commit confirmado: [2c4c02ee55b1472605695a93eddb7c4b39ab5578](https://github.com/francois-fiorino/tech-automation-scripts/commit/2c4c02ee55b1472605695a93eddb7c4b39ab5578). Todos os caminhos/conteúdos/blobs conferidos após publicação na branch do PR #2. Pendências individuais e validações locais em ADMIN_REVIEW.md e ADMIN_REVIEW_VERIFICATION.json. Sem compilação/execução Oracle, comandos administrativos ou merge.

Acumulado após lote 043: **160/177**, sendo **83 alterações de código e 77 revisões documentais**. Restam **17** na revisão complementar, além da homologação dos 177. Totais preservados: 476 implementações main e 177 propostas. Próxima fila: 044.

## Revisão administrativa complementar — lote 044 (04/11/2026)

17 scripts revisados: 8 alterações de código e 9 revisões documentais. Commit confirmado: [bc277eba3fb4a3c9b45705efd1f0969dc4e19b4b](https://github.com/francois-fiorino/tech-automation-scripts/commit/bc277eba3fb4a3c9b45705efd1f0969dc4e19b4b). Todos os caminhos/conteúdos/blobs conferidos após publicação na branch do PR #2. Pendências individuais e validações locais em ADMIN_REVIEW.md e ADMIN_REVIEW_VERIFICATION.json. Sem compilação/execução Oracle, comandos administrativos ou merge.

Acumulado atual: **177/177**, sendo **91 alterações de código e 86 revisões documentais**. Restam **0** na revisão complementar, além da homologação dos 177. Totais preservados: 476 implementações main e 177 propostas. Fila estática encerrada; próxima ação: homologação individual, sem promoção automática.

## Encerramento da revisão estática complementar — 04/11/2026

Fila encerrada: **177/177 scripts revisados**, com **91 alterações de código e 86 revisões documentais**. A última etapa foi o lote 044, com 17 arquivos (oito alterações de código e nove revisões documentais). Todos os caminhos e blobs dos 177 foram confirmados no commit de revisão e no commit individual registrado. Não houve compilação/execução Oracle nem testes em Windows/OpenVMS.

A auditoria atual conferiu **697 linhas classificadas**, **476 caminhos únicos de implementações na main** e **177 caminhos únicos em revisão**, sem sobreposição entre esses conjuntos. As demais linhas representam duplicatas, fontes mapeadas, placeholders/referências ou auxiliares, com classificação individual. Há ainda um auxiliar publicado na main e um roteiro auxiliar de testes no PR que não aumentam as contagens de implementações. Blobs e caminhos da main estão no campo `publication_audit.main_files` do JSON; os arquivos RECONCILIATION/VERIFICATION/INDEPENDENT_VERIFICATION permanecem snapshots históricos.

As 49 fontes originais anteriormente retidas não foram republicadas/relicenciadas. Seus requisitos já foram mapeados a 46 implementações novas (44 main e duas no PR), conforme relatório da etapa anterior. Encerrar esta fila estática não resolve os impedimentos técnicos individuais nem equivale a homologar implantação.

**Projeto ainda não concluído:** os 177 scripts do PR #2 continuam fora da main, com pendências individuais de runtime, contratos de aplicação, privilégios, segurança, compatibilidade e/ou comportamento administrativo. Não foram promovidos automaticamente. O PR #2 permanece Draft; o PR #1 continua aberto como documentação histórica, sem merge. O próximo trabalho é homologar e resolver cada impedimento em laboratório descartável com versão/DDL/dados e resultados verificáveis, seguido de seleção individual de publicação. Não existe lote 045 pendente nesta fila, nem execução em segundo plano.

