# Estado atual verificado — 2026-11-03

**Projeto em andamento. Próximo lote: 009. Não há processamento em segundo plano.**

| Situação | Quantidade |
|---|---:|
| SQL únicos publicados e verificados na main | **168** |
| Novos SQL publicados desde o início deste trabalho | **160** |
| Novos SQL publicados nesta retomada (lotes 005–008) | **80** |
| Novos arquivos na main com alterações de SQL/cliente/normalização | **133** |
| Fontes SQL aguardando análise individual | **469** |
| Retidos para análise de licença | 45 |
| Retido por credencial literal | 1 |
| Propostas apenas em branch, PR #2, fora dos totais main | 2 |
| Origens duplicadas/variantes mapeadas sem cópias adicionais | 7 |
| Referência externa sem implementação | 1 |
| Auxiliares pendentes | 4 |

[Inventário de 697 arquivos](inventory.csv) — 693 fontes SQL e 4 auxiliares. Existem 162 novos arquivos documentados (160 na main e 2 no PR). Os oito publicados antes do projeto foram comparados e preservados. As categorias novas desta retomada incluem `objects/indexes`, `asm` e `performance/sql`.

## Últimos lotes confirmados

| Lote | Novos SQL | Commit |
|---|---:|---|
| 005 | 20 | [00b1493](https://github.com/francois-fiorino/tech-automation-scripts/commit/00b1493c145d8d3381797abe85cfe8cf856351a6) |
| 006 | 20 | [f58f399](https://github.com/francois-fiorino/tech-automation-scripts/commit/f58f399ab4d227e86f6f112877a885e04ea86248) |
| 007 | 20 | [41ab033](https://github.com/francois-fiorino/tech-automation-scripts/commit/41ab033640d39879a4e646c012b332612efcaa72) |
| 008 | 20 | [a4fb9cc](https://github.com/francois-fiorino/tech-automation-scripts/commit/a4fb9ccf43f7afdd9b77ac2f695429991e751faf) |

Todos os 160 novos SQL foram novamente comparados por hash Git ao conteúdo UTF-8 publicado. Nenhum script existente no início desta retomada foi alterado; apenas controles do projeto foram atualizados. Inventário só classifica publicação como confirmada após essa verificação.

Principais correções desta retomada: denominadores zero, médias ponderadas, tempo/operação ASM invertido, identidade de objetos/sessões, limites de extent, colunas/agrupamentos incorretos, TO_DATE sobre DATE, máscaras e comandos de cliente. Fórmulas históricas sem metodologia confiável foram preservadas com ressalvas específicas, sem prometer correção semântica não validada.

Validação adicional: fixtures relacionais/aritméticas em SQLite para tablespaces cheios, total zero, ponderação entre instâncias, operações ASM e colisão de hash. Esses testes não compilam nem executam Oracle. Nenhum banco de produção, banco Oracle ou instância ASM foi acessado. Compilação, compatibilidade e impacto operacional continuam sujeitos a homologação no ambiente-alvo.

[PR #2](https://github.com/francois-fiorino/tech-automation-scripts/pull/2) permanece isolado para revisão dos dois exemplos administrativos. Arquivo com credencial não foi republicado e os 45 com aviso explícito de uso não comercial/licenciamento continuam retidos.

## Como retomar

Conferir main e o hash do inventário atual, validar ZIP pelos hashes SHA-256 e processar linhas `pendente` em lotes de 20. Próximo número: **009**. Preservar arquivos existentes, registrar correções e verificar blobs antes de confirmar publicação. Não promover propostas do PR ou retidos automaticamente. Não contar origens duplicadas como novas publicações.

A coleção **não está concluída**. Este checkpoint preserva o progresso para as próximas execuções; não é relatório final nem indica trabalho ativo após o fim da sessão.

---

## Histórico dos lotes e checkpoints anteriores

Os números nas seções abaixo descrevem cada estágio anterior. O quadro acima é o estado atual.

# Oracle Script Collection 2015 — andamento

Data: 2026-11-03. Projeto **em andamento**, sem homologação em banco Oracle.

## Ponto de partida verificado

- ZIP: 697 arquivos, 693 SQL e 4 auxiliares; 19 diretórios temáticos.
- Main inicial: `f33fc7af4109ec22276fdf5587704d819c9c8d9e`.
- Oito SQL da coleção já estavam publicados: sete em `oracle/performance/` e `oracle/rac/grid/block_pin.sql`.
- Todos os arquivos existentes foram preservados. Os oito corpos foram comparados com o ZIP; diferenças constam no inventário.

## Lote 001 — publicado e verificado

20 SQL com análise individual, cabeçalhos em português e código completo.
18 arquivos receberam alterações de código ou comandos do cliente; duas consultas mantidas integralmente.
As alterações estão descritas em cada cabeçalho e no inventário.
Publicação somente é confirmada pelo commit alcançável pela main e comparação dos SHAs dos blobs com os arquivos preparados.

Categorias: `performance`, `performance/awr`, `performance/ash`, `troubleshooting`, `monitoring`, `administration`, `rac`.

Principais problemas: contadores multiplicados por produto cartesiano; atribuição dependente da ordem de UNION; divisões por zero; falta de DBID/EVENT_ID em AWR; SID reutilizado em ASH; texto não comentado e vírgula/terminadores ausentes; títulos externos não fornecidos; conversão de DATE por TO_DATE e ordenação por data formatada.

Foram preservados e sinalizados: soma inadequada de tempos ASH; estatísticas RAC legadas; mapeamento interno de X$KCBFWAIT; baseline e reinícios nos comparativos AWR; recomendações históricas de tuning. Nenhuma execução em banco foi realizada.

## Impedimentos e próximos lotes

45 SQL contêm aviso explícito de uso não comercial e instrução de licenciamento. Não foram republicados. A detecção é uma triagem textual, não substitui análise jurídica nem garante ausência de outras restrições nos pendentes.

Após verificação do lote 002: 48 SQL publicados (8 anteriores + 40 novos), 599 SQL pendentes de revisão, 45 bloqueados para análise de licença e 1 retido para revisão de segurança. Quatro arquivos auxiliares continuam pendentes. Não contar fichas ou arquivos preparados como publicados.

Continuar com lotes de 20, sempre lendo individualmente e verificando o estado atual da main. Não há processamento em segundo plano associado a este relatório.

## Referências técnicas consultadas

- [V$FILESTAT — Oracle Database Reference](https://docs.oracle.com/en/database/oracle/oracle-database/26/refrn/V-FILESTAT.html)
- [V$ACTIVE_SESSION_HISTORY — Oracle Database Reference](https://docs.oracle.com/en/database/oracle/oracle-database/26/refrn/V-ACTIVE_SESSION_HISTORY.html)
- [V$LOGHIST — Oracle Database Reference](https://docs.oracle.com/en/database/oracle/oracle-database/18/refrn/V-LOGHIST.html)
- [Oracle Database Reference 19c — FILEMETRIC_HISTORY](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/database-reference.pdf)

Validação realizada: leitura de cada original, inspeção dos diffs, conferência de comentários/créditos e restrições, 12 seções de documentação, UTF-8, ausência de dependências title80/title132 e comandos de alteração no lote; revisão de sintaxe estática. SQL*Plus e servidor Oracle não disponíveis para compilação/execução. Nada foi executado em produção.

O inventário inclui o hash SHA-256 do arquivo original para permitir retomada sem confundir versões. Não alterar os arquivos anteriores sem nova comparação.

Commit do lote: [0ed29a8](https://github.com/francois-fiorino/tech-automation-scripts/commit/0ed29a8bc18010de88a4cb8ff69cb32ecf54af0d). Os 20 códigos e os dois arquivos de controle conferem com os hashes Git dos conteúdos UTF-8 publicados. Todos os 15 blobs preexistentes permaneceram idênticos.

## Lote 002

20 consultas administrativas, de objetos, PGA, LogMiner, segurança, métricas e RAC.
18 arquivos receberam correções de SQL ou comandos de apresentação; 2 corpos mantidos.
Novas categorias: `objects`, `memory`, `security`, `storage`, `backup-recovery`.
Correções: MINUS de packages agora considera OWNER; foreign keys incluem schema/tabela nas junções; denominador de latch usava DECODE incompleto; divisões por zero, aspas tipográficas, terminadores e datas/ordenação foram revisados.
Métricas históricas questionáveis foram preservadas com ressalvas específicas.
`_dba_admin_scripts/link.sql` foi retido por conter credencial literal e DDL público; nenhum segredo desse arquivo foi incluído nesta publicação.

Referências adicionais: [V$LOGMNR_LOGS](https://docs.oracle.com/en/database/oracle/oracle-database/12.2/refrn/V-LOGMNR_LOGS.html) e [V$PGA_TARGET_ADVICE](https://docs.oracle.com/en/database/oracle/oracle-database/21/refrn/V-PGA_TARGET_ADVICE.html).

Total novo nesta execução até o lote 002: 40 scripts com análise individual e cabeçalhos completos; 36 com alterações de código/cliente. Os 8 anteriores foram preservados e não homologados novamente. A conferência de hashes não valida semântica em execução Oracle.

## Lote 003

20 arquivos preparados de RAC, ocupação de segmentos e segurança. 16 receberam correções de SQL/cliente; 4 consultas foram mantidas. Incluem proteção de razões, normalização de BOM, terminador PL/SQL, alias inválido em gc_ratio.sql e GROUP BY inválido em sys_roles.sql.

Duplicação exata confirmada: `_rac_grid_scripts/cache_conv.sql` e `_i_o_scripts/reads_10g.sql` têm o mesmo texto integral. A origem adicional está mapeada ao código canônico já publicado `oracle/rac/reads_10g.sql`, sem publicação adicional.

`RACDIAG.SQL` contém apenas referência externa, sem implementação. `proc_sys_net.sql` é shell administrativo e `staggered_sequence_trigger.sql` cria trigger; ambos aguardam branch/PR de revisão. O conteúdo de nenhum dos três foi republicado.

Após verificação do lote 003, o total esperado é **68 arquivos SQL únicos publicados**, com **60 novos documentados individualmente**, dos quais **52 receberam alterações de SQL ou comandos de cliente**. Há 575 fontes aguardando análise individual, 2 aguardando revisão administrativa, 45 retidas para análise de licença, 1 retida por credencial, 1 duplicata mapeada e 1 referência sem código. Quatro auxiliares permanecem pendentes. O projeto NÃO está concluído.

Lote 002 verificado: [aeae553](https://github.com/francois-fiorino/tech-automation-scripts/commit/aeae553fff3f92a6afa9be31b17f3812bc680794); 22 conteúdos conferidos (20 SQL e 2 controles); scripts anteriores preservados.

## Lote 004

20 scripts de memória, advisors, buffers, I/O de sessões, jobs legados e coleta customizada. 14 arquivos com alterações de SQL/cliente; seis corpos preservados. Corrigidos denominadores, formatos de cliente, máscaras de data, ordenação cronológica e rótulo enganoso de leituras estimadas.

Dois novos mapeamentos de duplicação confirmados: `seg_top_logreads.sql` é cópia exata de `reads_10g.sql`; `cache_transfer.sql` contém o mesmo corpo de `forced_reads_writes.sql`, diferindo no comentário de nome/whitespace. Nenhum arquivo adicional foi criado para essas cópias.

Lote 003 verificado: [70f71f8](https://github.com/francois-fiorino/tech-automation-scripts/commit/70f71f803a4d7fb45f3fb9329f6caf59d906f9a4). Vinte SQL e dois controles conferidos por hash; scripts anteriores idênticos.

Lote 004 confirmado por hash: **88 SQL únicos publicados** (8 anteriores + 80 novos), **80 novos com análise técnica individual e cabeçalhos completos**, **66 novos com alterações de SQL/cliente**. Permanecem 553 fontes aguardando análise, 2 para branch/PR administrativa, 45 para análise de licença e 1 com credencial. Há ainda 3 origens duplicadas mapeadas, 1 referência sem implementação e 4 auxiliares pendentes.

Esses números não significam homologação de execução Oracle. O projeto permanece em andamento e o inventário é o ponto de retomada obrigatório.

## Checkpoint verificado — projeto não concluído

- **80 novos scripts publicados e conferidos na main**, em quatro lotes de 20.
- **88 scripts únicos da coleção na main**, incluindo oito anteriores.
- **82 novos arquivos com documentação técnica individual**, sendo 80 na main e 2 apenas em branch de revisão.
- **66 novos arquivos na main com correções de SQL/comandos de cliente**; os dois da branch também tiveram correções, sem execução administrativa.
- **553 fontes aguardam análise individual**; **45** estão retidas para análise de licença; **1** contém credencial literal e segue retida.
- **2 propostas de alto risco no [PR #2](https://github.com/francois-fiorino/tech-automation-scripts/pull/2)**, em rascunho; não contam como publicadas na main.
- **3 duplicatas de origem mapeadas** a códigos canônicos, sem contar como novas publicações.
- **1 referência externa sem implementação**; **4 auxiliares** pendentes.

Categorias publicadas na main: administration, backup-recovery, memory, monitoring, objects, performance, performance/awr, performance/ash, rac, security, storage e troubleshooting.

### Commits e verificações

| Lote | SQL novos | Commit |
|---|---:|---|
| 001 | 20 | [0ed29a8](https://github.com/francois-fiorino/tech-automation-scripts/commit/0ed29a8bc18010de88a4cb8ff69cb32ecf54af0d) |
| 002 | 20 | [aeae553](https://github.com/francois-fiorino/tech-automation-scripts/commit/aeae553fff3f92a6afa9be31b17f3812bc680794) |
| 003 | 20 | [70f71f8](https://github.com/francois-fiorino/tech-automation-scripts/commit/70f71f803a4d7fb45f3fb9329f6caf59d906f9a4) |
| 004 | 20 | [2d482e6](https://github.com/francois-fiorino/tech-automation-scripts/commit/2d482e66afe80c85ef4191bbb6263ddaff0cc08e) |

Os hashes dos 80 SQL novos foram comparados ao conteúdo UTF-8 publicado. Os 15 blobs que existiam no início continuam idênticos. Os dois arquivos do PR também foram conferidos por hash. `sh -n` aprovou somente a sintaxe do shell legado; nenhum comando dele foi executado. Não houve compilação ou execução em banco Oracle.

### Retomada

Usar o ZIP original de 697 arquivos e os SHA-256 do [inventário](inventory.csv). Ler o estado atual da main antes de escrever. Prosseguir pelas linhas com publicação `pendente`, em lotes de 20; não refazer os 80 novos nem os oito anteriores. Reavaliar duplicatas pelo corpo integral e preservar créditos. Arquivos retidos por licença/credencial e os dois do PR não devem ser promovidos automaticamente. O próximo lote será o 005.

Não existe processamento ativo em segundo plano. Este é um checkpoint parcial; não é relatório de conclusão da coleção.

## Lote 005 — arquivos, extents e I/O

20 arquivos com revisão individual e documentação completa; 18 receberam alterações de SQL/comandos de cliente. Sem execução em Oracle. Corrigidos percentuais com total zero, tamanho de bloco de tablespace não padrão, interpretação de status de backup, SQL com aspas/aliases inválidos, GROUP BY ausente e UNION que eliminava subtotais válidos. A consulta de undo agora relaciona SQL_ID juntamente com DBID, sem afirmar que a consulta de maior duração é quem gerou o undo.

FILEIO2.SQL, FILEIO_NH.SQL, datafile2.sql e mapper1.sql tiveram todos os SELECTs comparados com as versões canônicas; as diferenças são de apresentação/cliente e foram registradas no inventário. Nenhuma nova cópia foi publicada para essas variantes.

Após verificação: **108 SQL únicos na main**, sendo 100 publicados nas execuções deste projeto e 84 desses com alterações de código/cliente. **529 fontes** continuam aguardando análise individual, **45** retidas por licença, **1** por credencial, **2** apenas no PR #2, **7** origens duplicadas mapeadas e **1** referência sem implementação. Quatro auxiliares continuam pendentes.

Referências: [V$BACKUP](https://docs.oracle.com/en/database/oracle/oracle-database/26/refrn/V-BACKUP.html), [DBA_HIST_SEG_STAT](https://docs.oracle.com/en/database/oracle/oracle-database/26/refrn/DBA_HIST_SEG_STAT.html). Cabeçalhos detalham privilégios, unidades, dados acumulados versus deltas, dependências customizadas e riscos de tabelas internas.

## Lote 006 — índices, segmentos e tablespaces

20 arquivos analisados individualmente e documentados; 19 com alterações de SQL ou comandos de cliente. Nova subcategoria `objects/indexes`. Variantes co_lo_ind, co_lo_ind2 e co_lo_ind3 foram preservadas separadamente: suas exclusões de owners são funcionalmente diferentes.

Corrigidos o proprietário real da tabela na associação com índices, INDEX_OWNER no join de partições, GROUP BY/limite de extent no mapeamento de buffers e proteção contra zero no percentual de UNUSED_SPACE. A consulta de espaço agora inclui tablespaces sem extents livres com LEFT JOIN/NVL. MAX_EXTENT de DBA_IND_PARTITIONS foi conferido no Database Reference e preservado, pois é coluna válida nessa view.

Validação: leitura de originais e diffs; estrutura de cabeçalhos, comandos somente de diagnóstico e parênteses; teste auxiliar da consulta de espaço em SQLite com função NVL registrada e três fixtures (cheio, 50% livre e total zero). Esse teste valida lógica relacional auxiliar, não substitui parse/execução Oracle. Não houve execução em banco Oracle nem DDL/DML administrativo.

Lote 005 confirmado: [00b1493](https://github.com/francois-fiorino/tech-automation-scripts/commit/00b1493c145d8d3381797abe85cfe8cf856351a6), 20 SQL e dois controles conferidos por SHA; todos os scripts anteriores preservados.

Após confirmar lote 006: **128 SQL únicos na main** (8 anteriores + 120 novos); **103 dos novos** receberam alterações de código/cliente; 2 propostas documentadas permanecem apenas no PR #2. Continuam **509 fontes aguardando análise**, 45 retidas por licença, 1 por credencial, 7 origens duplicadas mapeadas, 1 referência sem implementação e 4 auxiliares pendentes. Projeto ainda não concluído.

Referências: [ALL_IND_PARTITIONS/DBA_IND_PARTITIONS](https://docs.oracle.com/en/database/oracle/oracle-database/21/refrn/ALL_IND_PARTITIONS.html) e [DBMS_SPACE](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_SPACE.html).

## Lote 007 — RAC, PX, serviços e ASM

20 consultas com análise/documentação individual; 14 arquivos alterados, incluindo normalização de CR isolado em arquivos históricos. Nova categoria `asm`. Corrigidas médias de espera não ponderadas entre instâncias, inversão de operações/tempo em ASM, divisão analítica por zero e CASE WHEN NULL que nunca correspondia. Acrescentados identificadores dos discos e SERIAL# na associação de sessões PX. Consulta de diskgroup utiliza view STAT para evitar discovery.

Os contadores compostos de hot_segments e gc_top_5_segments foram preservados com ressalvas explícitas de unidades/dupla contagem; não são declarados IOPS ou contabilidade de operações únicas. Interpretação de BYTES do In-Memory e de memória GCS/GES consta nos cabeçalhos. Consultas de ASH e exemplos de tracing não foram incluídos neste lote.

Validação: diffs completos, estrutura e ausência de comandos mutantes; fixtures auxiliares SQLite aprovaram médias ponderadas com instâncias de volumes distintos, ausência de esperas e cálculo de tempo/operação ASM com zero operações. Nenhum banco Oracle/ASM foi acessado e os testes não substituem homologação Oracle.

Lote 006 confirmado: [f58f399](https://github.com/francois-fiorino/tech-automation-scripts/commit/f58f399ab4d227e86f6f112877a885e04ea86248); vinte SQL e controles conferidos por hash, com preservação dos scripts anteriores.

Após verificação do lote 007: **148 SQL únicos na main**, dos quais 140 novos; **117 novos arquivos** com alterações de SQL/cliente/normalização. **489 fontes aguardam análise**, além de 45 retidas por licença, 1 por credencial e 2 no PR #2. Mantidos 7 mapeamentos de origens duplicadas, 1 referência sem implementação e 4 auxiliares pendentes.

Referências: [V$GES_BLOCKING_ENQUEUE](https://docs.oracle.com/en/database/oracle/oracle-database/21/refrn/V-GES_BLOCKING_ENQUEUE.html), [V$IM_SEGMENTS](https://docs.oracle.com/en/database/oracle/oracle-database/26/refrn/V-IM_SEGMENTS.html) e [V$ASM_DISK](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-ASM_DISK.html).

## Lote 008 — cache SQL, esperas e séries customizadas

20 arquivos com documentação individual; 16 com correções de SQL/comandos de cliente. Nova subcategoria `performance/sql`. Corrigidos TO_DATE sobre coluna DATE, nome de parâmetro db_block_size, associação por ADDRESS junto ao hash, limite de extent, divisor zero, máscara numérica e fechamento de SPOOL. Os scripts que dependem de DBA_RUNNING_STATS/STATETAB têm esses pré-requisitos explicitados; não foram apresentados como funcionalidades padrão Oracle.

Mantidos e sinalizados: soma inadequada de campos temporais amostrados ASH, plano iniciado no nó ID=1 e sem filtro de captura, diferença entre disk/memory e disk/total, e filtros de eventos mais amplos que seus títulos. Não houve simplificação/substituição dos corpos históricos.

Validação: cabeçalhos completos, diffs e ausência de DDL/DML direto; fixture auxiliar SQLite com dois textos/endereços diferentes e hash coincidente demonstrou associação correta por ADDRESS+HASH_VALUE. Sem execução/compilação Oracle.

Lote 007 confirmado: [41ab033](https://github.com/francois-fiorino/tech-automation-scripts/commit/41ab033640d39879a4e646c012b332612efcaa72), vinte SQL e dois controles conferidos por hash; scripts anteriores preservados.

Após confirmação do lote 008: **168 scripts SQL únicos na main**, dos quais **160 novos** e **133 novos arquivos com alterações de SQL/cliente/normalização**. Restam **469 fontes com análise individual pendente**, 45 retidas por licença, 1 por credencial, 2 apenas no PR #2, 7 origens duplicadas mapeadas e 1 referência sem código. Quatro auxiliares pendentes. Projeto ainda não concluído; próximo lote 009.

## Lote 009 — preparado para publicação

20 arquivos lidos individualmente, com código completo e cabeçalhos técnicos. 16 receberam alterações de SQL/comandos de cliente/normalização. Os cabeçalhos e o inventário descrevem cada correção e limitação. Sem execução ou compilação Oracle. Confirmar apenas após conferência de hashes Git.

Lote 009 confirmado por hashes: [commit 25e45a7](https://github.com/francois-fiorino/tech-automation-scripts/commit/25e45a746d7c3bd0b84d3da2ad4a9ebf98de8176). Vinte SQL e dois controles conferidos; scripts anteriores preservados.

## Lote 010 — preparado para publicação

20 arquivos lidos individualmente, com código completo e cabeçalhos técnicos. 13 receberam alterações de SQL/comandos de cliente/normalização. Os cabeçalhos e o inventário descrevem cada correção e limitação. Sem execução ou compilação Oracle. Confirmar apenas após conferência de hashes Git.

Lote 010 confirmado por hashes: [commit 424bd75](https://github.com/francois-fiorino/tech-automation-scripts/commit/424bd7546fe30a1797efa43025cfdbea854ed22a). Vinte SQL e dois controles conferidos; scripts anteriores preservados.

## Lote 011 — revisão administrativa

20 arquivos completos documentados e publicados APENAS na branch do [PR #2](https://github.com/francois-fiorino/tech-automation-scripts/pull/2), commit [436f99a](https://github.com/francois-fiorino/tech-automation-scripts/commit/436f99ad1cd56b8bb7ff9465aa68e53fd624b8ef). Hashes dos vinte conferidos. São 22 propostas no PR, incluindo duas anteriores; não contam como publicadas na main. Seis receberam correções de código. Nenhum comando administrativo foi executado. DBA_RUNNING_STATS/rotinas customizadas, jobs, eventos, CTAS e execução de DML gerado exigem laboratório. DELTA mantém erro de correlação explicitamente bloqueado para implantação; Windows batch mantém riscos de metacaracteres. O auxiliar batsub.txt é cópia exata desse batch e foi mapeado ao mesmo artefato.

## Lote 012 — preparado para publicação

20 arquivos lidos individualmente, com código completo e cabeçalhos técnicos. 18 receberam alterações de SQL/comandos de cliente/normalização. Os cabeçalhos e o inventário descrevem cada correção e limitação. Sem execução ou compilação Oracle. Confirmar apenas após conferência de hashes Git.

Lote 012 confirmado por hashes: [commit 4131a06](https://github.com/francois-fiorino/tech-automation-scripts/commit/4131a06e8f6baca711c0f3930cc34d68d98a4dc2). Vinte SQL e dois controles conferidos; scripts anteriores preservados.

Errata de dependências: title80.sql/title132.sql estão no ZIP em _dba_admin_scripts. Nos cabeçalhos anteriores, ausente refere-se à dependência não disponibilizada ao lado dos scripts no caminho operacional, não à inexistência no ZIP. Ambos agora estão catalogados em administration; os demais relatórios mantêm TTITLE local para execução independente. Duas variantes de cache advisor/SGASTAT foram mapeadas e analz_sch.sql contém apenas transcrição de prompts interrompidos, sem implementação.

## Lote 013 — preparado para publicação

20 arquivos lidos individualmente, com código completo e cabeçalhos técnicos. 18 receberam alterações de SQL/comandos de cliente/normalização. Os cabeçalhos e o inventário descrevem cada correção e limitação. Sem execução ou compilação Oracle. Confirmar apenas após conferência de hashes Git.
