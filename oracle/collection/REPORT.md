# Relatório de revisão e publicação da coleção Oracle 2015

Data: 03/11/2026. **Projeto em andamento: todas as origens foram classificadas, mas há propostas administrativas e impedimentos de publicação abertos.**

## Totais reconciliados

| Medida | Total | Critério |
|---|---:|---|
| Arquivos inventariados | 697 | 693 SQL e quatro auxiliares |
| Fontes SQL com implementação examinada ou comparada | 638 | 606 implementações únicas + 32 variantes/duplicatas |
| Fontes SQL sem implementação funcional | 5 | placeholders/transcripts sem código funcional, não contabilizados como publicados |
| Fontes retidas antes de concluir análise técnica | 50 | 49 para licença/redistribuição e uma com credencial literal |
| Implementações com código/documentação na main | **432** | 424 novas e oito anteriores preservadas |
| Implementações documentadas somente no PR | **174** | não contam como concluídas na main |
| Novos arquivos documentados neste projeto | **598** | 424 main + 174 propostas; exclui oito anteriores |
| Novos arquivos main com correção/ajuste de SQL ou cliente | 366 | inclui divisões/joins, comandos SQL*Plus e normalização; não apenas correções semânticas SQL |
| Propostas com correção/ajuste de código | 92 | ainda exigem validação/revisão |
| Total com alterações de código | **458** | cabeçalho documenta cada caso; não confundir com testes Oracle aprovados |
| Origens duplicadas/variantes mapeadas | 32 | não são novas publicações; link e diferenças no inventário |
| Pendências de publicação na main | **224** | 174 propostas + 50 impedimentos; sem contar fontes vazias e variantes |
| Fontes sem classificação/análise de elegibilidade | **0** | não significa todos os scripts implantáveis ou projeto concluído |

O [inventário de 697 origens](inventory.csv) contém nome/caminho original e final, categoria, finalidade, documentação, correções, risco, publicação, link e SHA-256 do original. O [histórico de etapas](PROGRESS.md) conserva os números de cada estágio. O [README histórico](ORIGINAL_README.txt) foi preservado integralmente.

## Publicação e preservação

Os lotes 001–029 têm vinte arquivos cada. Os resíduos 030 (12 propostas) e 031 (quatro consultas) encerram a fila técnica após reconciliação de variantes. Duas propostas iniciais, anteriores aos lotes de revisão, completam os 174 arquivos do PR.

Todos os novos scripts possuem cabeçalho técnico em português com nome/categoria, objetivo, funcionamento, privilégios, objetos, compatibilidade/limitações, execução, interpretação, riscos, correções/pendências e aviso de responsabilidade. Os códigos e créditos históricos foram mantidos. Há erros conhecidos deliberadamente preservados quando corrigi-los com segurança exigiria Oracle ou regra de negócio; esses arquivos estão sinalizados no PR.

Árvores Git foram criadas a partir da árvore anterior. As atualizações das branches usaram SHA esperado e `force=false`. Após cada publicação, SHA do blob Git foi comparado com o conteúdo local. Na reconferência global, **424 novos arquivos main e 174 propostas** coincidiram com seus hashes; **todos os 15 blobs preexistentes** permaneceram inalterados, inclusive os oito scripts da coleção já publicados. [Evidência do snapshot de verificação](VERIFICATION.json).

Links: [diretório Oracle na main](https://github.com/francois-fiorino/tech-automation-scripts/tree/main/oracle), [PR administrativo #2](https://github.com/francois-fiorino/tech-automation-scripts/pull/2), [branch de revisão](https://github.com/francois-fiorino/tech-automation-scripts/tree/oracle/review-legacy-admin-20261103). O inventário vincula cada arquivo ao destino efetivamente conferido.

## Categorias técnicas utilizadas

As linhas abaixo refletem categorias efetivamente usadas; não foram criados diretórios vazios para atingir uma lista artificial. As categorias de propostas permanecem na branch até revisão.

| Categoria/caminho relativo a oracle | Main | Somente PR |
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
| `performance/ash/` | 11 | 0 |
| `performance/awr/` | 25 | 0 |
| `performance/sql/` | 22 | 1 |
| `performance/statspack/` | 1 | 0 |
| `rac/` | 40 | 1 |
| `rac/grid/` | 1 | 0 |
| `security/` | 19 | 18 |
| `storage/` | 32 | 0 |
| `troubleshooting/` | 32 | 2 |

## Principais achados e correções

- Divisores sem atividade e limites textuais: proteções NULLIF/CASE e tratamento de UNLIMITED, sem presumir que ausência de atividade significa zero de tempo médio.
- Joins por nome/endereço incompletos: owner, hash, SID/SERIAL#, XID completo, plano, DBID e instância acrescentados conforme o caso. Junções com OR que produziam produtos cartesianos foram corrigidas nos relatórios de locks/Resource Manager.
- Métricas interpretadas incorretamente: média ponderada de esperas, parênteses de hit ratio, janela de uma hora, ordenação cronológica/numérica, bloco fixo 2 KB, LAST_NUMBER de sequência, HWM de segmento e diferença entre contadores acumulados/taxas.
- Compatibilidade histórica: layouts KEY/VALUE de V$INSTANCE, tabelas X$/SYS internas, DMT/undo manual, Advanced Replication, stored outlines e scripts de cliente não têm homologação moderna. Dependências customizadas ausentes estão explícitas.
- Segurança: impressão de SQL com senha removida onde estava ativa; CONNECTs gerados deixaram de presumir senha igual ao usuário; grants de coluna/objeto foram corrigidos. Algoritmos de senha fracos, hashes legados, SQL dinâmico sem validação e definer rights permanecem assinalados nos exemplos de revisão.
- Geradores complexos: não foram substituídos por resumos. Preservaram-se algoritmos de particionamento/recriação acima de 20 KB, todos os 1290 INSERTs de FILL_SZ, 450 comandos de PK_RCT e 1043 remoções de estatísticas. COUNT_B_TEMP foi comparado integralmente: mesmo multiconjunto de 1290 INSERTs, com ordem distinta e transcript SQL*Plus; aponta ao canônico corrigido.
- Backup/recovery: REUSE, remoção de archives, BEGIN BACKUP sem cleanup garantido, cópia de redo online e arquivo copiado após END BACKUP são riscos concretos registrados. Não houve backup, restore, switch, job, trace, purge ou DDL executado.
- Errata de revisão: USER_CONSTRAINTS contém OWNER. A troca indevida proposta em GET_COND foi revertida na branch e registrada; a main não foi afetada. TITLE80/TITLE132 existem no ZIP e agora têm helpers publicados; referências antigas a ausência no histórico referem-se ao SQLPATH/dependência de execução e foram esclarecidas nas erratas.

## Validação e limites

Foi realizada leitura individual de código, comparação de variantes, revisão estática, conferência de integridade de cabeçalhos e blobs e verificações locais pontuais de aritmética/joins. Nos arquivos massivos, todos os comandos foram lidos por parser de padrões; exceções (incluindo três nomes XDB com hífen) foram examinadas e documentadas. Não houve compilação nem execução em Oracle. Fixtures locais não equivalem ao otimizador, parser ou runtime Oracle.

Antes de uso, cada arquivo requer avaliação integral e teste controlado no banco/container/versão alvo, autorização de privilégios, capacidade/custo e, onde aplicável, direito de uso de AWR/ASH. Scripts administrativos do PR permanecem fora da main, sem aprovação de implantação.

## Pendências e arquivos auxiliares

- **174 propostas:** aguardam revisão de alto risco, testes de compilação/funcionalidade/recuperação e decisão de integração no PR #2. Arquivos com falhas conhecidas não foram classificados como prontos para produção.
- **49 fontes:** avisos históricos de uso não comercial ou direitos reservados exigem esclarecer redistribuição; sua revisão técnica individual não foi declarada concluída e código não foi publicado. O inventário lista cada origem.
- **Uma fonte com credencial literal:** retida sem republicar o valor; requer tratamento seguro antes de elegibilidade.
- **Cinco fontes sem código funcional:** mantidas apenas no inventário como referência/placeholder, sem fictícia publicação de script.
- **Auxiliares:** README original publicado; BAT auxiliar duplicado aponta ao exemplo documentado no PR; arquivo Finder binário e spool de zero bytes não são código elegível e foram excluídos da publicação.

Não há processamento em segundo plano. A fila de triagem foi esgotada; os impedimentos acima continuam abertos. O projeto **não foi marcado como concluído**.

## Commits de publicação dos lotes

Os links abaixo são os commits com código. Commits adicionais do histórico atualizam/verificam inventário e relatório; não acrescentam scripts às contagens.

| Lote | Arquivos | Destino | Commit |
|---|---:|---|---|
| 001 | 20 | main | [0ed29a8bc1](https://github.com/francois-fiorino/tech-automation-scripts/commit/0ed29a8bc18010de88a4cb8ff69cb32ecf54af0d) |
| 002 | 20 | main | [aeae553fff](https://github.com/francois-fiorino/tech-automation-scripts/commit/aeae553fff3f92a6afa9be31b17f3812bc680794) |
| 003 | 20 | main | [70f71f803a](https://github.com/francois-fiorino/tech-automation-scripts/commit/70f71f803a4d7fb45f3fb9329f6caf59d906f9a4) |
| 004 | 20 | main | [2d482e66af](https://github.com/francois-fiorino/tech-automation-scripts/commit/2d482e66afe80c85ef4191bbb6263ddaff0cc08e) |
| 005 | 20 | main | [00b1493c14](https://github.com/francois-fiorino/tech-automation-scripts/commit/00b1493c145d8d3381797abe85cfe8cf856351a6) |
| 006 | 20 | main | [f58f399ab4](https://github.com/francois-fiorino/tech-automation-scripts/commit/f58f399ab4d227e86f6f112877a885e04ea86248) |
| 007 | 20 | main | [41ab033640](https://github.com/francois-fiorino/tech-automation-scripts/commit/41ab033640d39879a4e646c012b332612efcaa72) |
| 008 | 20 | main | [a4fb9ccf43](https://github.com/francois-fiorino/tech-automation-scripts/commit/a4fb9ccf43f7afdd9b77ac2f695429991e751faf) |
| 009 | 20 | main | [25e45a746d](https://github.com/francois-fiorino/tech-automation-scripts/commit/25e45a746d7c3bd0b84d3da2ad4a9ebf98de8176) |
| 010 | 20 | main | [424bd7546f](https://github.com/francois-fiorino/tech-automation-scripts/commit/424bd7546fe30a1797efa43025cfdbea854ed22a) |
| 011 | 20 | PR #2 | [436f99ad1c](https://github.com/francois-fiorino/tech-automation-scripts/commit/436f99ad1cd56b8bb7ff9465aa68e53fd624b8ef) |
| 012 | 20 | main | [4131a06e8f](https://github.com/francois-fiorino/tech-automation-scripts/commit/4131a06e8f6baca711c0f3930cc34d68d98a4dc2) |
| 013 | 20 | main | [9ca8c838ea](https://github.com/francois-fiorino/tech-automation-scripts/commit/9ca8c838ea59b2df2a6abdde3c1358e763d27456) |
| 014 | 20 | main | [387ebb84f4](https://github.com/francois-fiorino/tech-automation-scripts/commit/387ebb84f41b1146d73299d0ca731b887329f730) |
| 015 | 20 | PR #2 | [3ef049760a](https://github.com/francois-fiorino/tech-automation-scripts/commit/3ef049760afbda16da2e8ec4a59603017c8ae0c1) |
| 016 | 20 | main | [46b6d764d9](https://github.com/francois-fiorino/tech-automation-scripts/commit/46b6d764d936bb4f881c81643bd6682a4a921cf5) |
| 017 | 20 | main | [7d376e68ba](https://github.com/francois-fiorino/tech-automation-scripts/commit/7d376e68ba5f135fb6bd32c84af35af5a7ecef4f) |
| 018 | 20 | main | [4cacc4c7c2](https://github.com/francois-fiorino/tech-automation-scripts/commit/4cacc4c7c246e8041424826e806f37dfa6efe59a) |
| 019 | 20 | main | [f5dffc1747](https://github.com/francois-fiorino/tech-automation-scripts/commit/f5dffc1747f9e0834d109701654cc91544cc1119) |
| 020 | 20 | PR #2 | [bfe9b7c1c8](https://github.com/francois-fiorino/tech-automation-scripts/commit/bfe9b7c1c856c8434a3d56ce74f2a7c3383d302b) |
| 021 | 20 | main | [2cc4179021](https://github.com/francois-fiorino/tech-automation-scripts/commit/2cc417902145f25db58dce04e07863bd295898ec) |
| 022 | 20 | main | [a77e85a0c1](https://github.com/francois-fiorino/tech-automation-scripts/commit/a77e85a0c19630cc8593bbcef1344bb3065fd7c2) |
| 023 | 20 | main | [80be7f39be](https://github.com/francois-fiorino/tech-automation-scripts/commit/80be7f39bed330dedf16f63d9a950b3ed7ec77ee) |
| 024 | 20 | PR #2 | [04b93a49be](https://github.com/francois-fiorino/tech-automation-scripts/commit/04b93a49bef837fde158953d5627ce8b50cfedc1) |
| 025 | 20 | main | [321616c6f6](https://github.com/francois-fiorino/tech-automation-scripts/commit/321616c6f6c3048bd9fba2beac5b0f583af2d4b9) |
| 026 | 20 | PR #2 | [b59898337f](https://github.com/francois-fiorino/tech-automation-scripts/commit/b59898337fd6d279755d4239e1228fca6bbe3b96) |
| 027 | 20 | PR #2 | [fb9e2a2f98](https://github.com/francois-fiorino/tech-automation-scripts/commit/fb9e2a2f98d1145b36ff3cc4af498345bf67cee0) |
| 028 | 20 | PR #2 | [fe4c50194b](https://github.com/francois-fiorino/tech-automation-scripts/commit/fe4c50194b475deb7d4580da8b7bc5cfc94b14be) |
| 029 | 20 | PR #2 | [3f42242417](https://github.com/francois-fiorino/tech-automation-scripts/commit/3f4224241719feab32cfd0d8c2f5c6ecbc559679) |
| 030 | 12 | PR #2 | [627706b5c5](https://github.com/francois-fiorino/tech-automation-scripts/commit/627706b5c563a370a739c9b7ecc731cd09517ed3) |
| 031 | 4 | main | [573a4a79dd](https://github.com/francois-fiorino/tech-automation-scripts/commit/573a4a79dd5956a4ee4eced4ba5a31c3a5830894) |
