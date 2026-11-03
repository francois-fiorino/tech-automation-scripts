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
