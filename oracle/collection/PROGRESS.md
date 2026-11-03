# Oracle Script Collection 2015 — andamento

Data: 2026-11-03. Projeto **em andamento**, sem homologação em banco Oracle.

## Ponto de partida verificado

- ZIP: 697 arquivos, 693 SQL e 4 auxiliares; 19 diretórios temáticos.
- Main inicial: `f33fc7af4109ec22276fdf5587704d819c9c8d9e`.
- Oito SQL da coleção já estavam publicados: sete em `oracle/performance/` e `oracle/rac/grid/block_pin.sql`.
- Todos os arquivos existentes foram preservados. Os oito corpos foram comparados com o ZIP; diferenças constam no inventário.

## Lote 001

20 SQL com análise individual, cabeçalhos em português e código completo.
18 arquivos receberam alterações de código ou comandos do cliente; duas consultas mantidas integralmente.
As alterações estão descritas em cada cabeçalho e no inventário.
Publicação somente é confirmada pelo commit alcançável pela main e comparação dos SHAs dos blobs com os arquivos preparados.

Categorias: `performance`, `performance/awr`, `performance/ash`, `troubleshooting`, `monitoring`, `administration`, `rac`.

Principais problemas: contadores multiplicados por produto cartesiano; atribuição dependente da ordem de UNION; divisões por zero; falta de DBID/EVENT_ID em AWR; SID reutilizado em ASH; texto não comentado e vírgula/terminadores ausentes; títulos externos não fornecidos; conversão de DATE por TO_DATE e ordenação por data formatada.

Foram preservados e sinalizados: soma inadequada de tempos ASH; estatísticas RAC legadas; mapeamento interno de X$KCBFWAIT; baseline e reinícios nos comparativos AWR; recomendações históricas de tuning. Nenhuma execução em banco foi realizada.

## Impedimentos e próximos lotes

45 SQL contêm aviso explícito de uso não comercial e instrução de licenciamento. Não foram republicados. A detecção é uma triagem textual, não substitui análise jurídica nem garante ausência de outras restrições nos pendentes.

Após verificação do lote 001: 28 SQL publicados (8 anteriores + 20 novos), 620 SQL pendentes de revisão e 45 bloqueados para análise de licença. Quatro arquivos auxiliares continuam pendentes. Não contar fichas ou arquivos preparados como publicados.

Continuar com lotes de 20, sempre lendo individualmente e verificando o estado atual da main. Não há processamento em segundo plano associado a este relatório.

## Referências técnicas consultadas

- [V$FILESTAT — Oracle Database Reference](https://docs.oracle.com/en/database/oracle/oracle-database/26/refrn/V-FILESTAT.html)
- [V$ACTIVE_SESSION_HISTORY — Oracle Database Reference](https://docs.oracle.com/en/database/oracle/oracle-database/26/refrn/V-ACTIVE_SESSION_HISTORY.html)
- [V$LOGHIST — Oracle Database Reference](https://docs.oracle.com/en/database/oracle/oracle-database/18/refrn/V-LOGHIST.html)
- [Oracle Database Reference 19c — FILEMETRIC_HISTORY](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/database-reference.pdf)

Validação realizada: leitura de cada original, inspeção dos diffs, conferência de comentários/créditos e restrições, 12 seções de documentação, UTF-8, ausência de dependências title80/title132 e comandos de alteração no lote; revisão de sintaxe estática. SQL*Plus e servidor Oracle não disponíveis para compilação/execução. Nada foi executado em produção.

O inventário inclui o hash SHA-256 do arquivo original para permitir retomada sem confundir versões. Não alterar os arquivos anteriores sem nova comparação.
