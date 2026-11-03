# Exemplos de revisão técnica — coleção legada de scripts Oracle

**Método:** inspeção estática de arquivos selecionados do ZIP fornecido. Não houve execução, teste em banco, nem validação de compatibilidade. As descrições abaixo são explicações originais; **o código de terceiros não é reproduzido**.

## 1. `_awr_scripts/awr_access_counts.sql`

**O que faz:** conta instruções distintas identificadas por `HASH_VALUE` e linhas de plano associadas a joins com `OPTIONS = 'CARTESIAN'`, consultando `SYS.V_$SQL_PLAN`.

**Dependências:** acesso a `V_$SQL_PLAN` e permissões correspondentes.

**Pontos de atenção:**
- Apesar do prefixo no nome, **não consulta o repositório AWR**; utiliza uma view dinâmica de planos atualmente disponível.
- A coluna `HASH_VALUE` não substitui a identificação detalhada por `SQL_ID` e child cursor.
- A contagem de linhas de plano não equivale necessariamente ao número de execuções reais de joins cartesianos.
- Consulta somente leitura, mas a semântica do indicador precisa ser esclarecida antes do uso em dashboards.

**Recomendação:** não chamar o resultado de “quantidade de execuções de joins cartesianos” e revisar critério de contagem.

## 2. `_awr_scripts/awr_cartesian_sum.sql`

**O que faz:** chama `DBMS_SPACE.CREATE_INDEX_COST` para estimar espaço utilizado/alocado de um índice hipotético em `STATS$SYSSTAT`, com `TABLESPACE SYSAUX`, e escreve valores via `DBMS_OUTPUT`.

**Dependências:** pacote `DBMS_SPACE`, existência da tabela citada, estatísticas e permissões compatíveis.

**Pontos de atenção:**
- **O nome sugere análise de produto cartesiano, mas o código estima custo de espaço de índice.** Divergência funcional relevante.
- O DDL aparece como **texto de entrada para estimativa**, não como uma execução direta de `CREATE INDEX`; não classificá-lo automaticamente como alteração efetiva.
- Os nomes `STATS$SYSSTAT` e `SYSAUX` estão fixados no script; isso limita sua reutilização.

**Recomendação:** renomear uma eventual implementação própria de acordo com sua verdadeira função e parametrizar objetos.

## 3. `_ash_scripts/ash_event_count.sql`

**O que faz:** agrupa amostras de `DBA_HIST_ACTIVE_SESS_HISTORY` por `SQL_ID`, cruzando com `V$SQL`, e filtra textos SQL que contenham o literal `orders`.

**Dependências:** histórico ASH, `V$SQL`, privilégios e licenciamento aplicáveis.

**Pontos de atenção:**
- O filtro `'%orders%'` é fixo e pode capturar instruções não relacionadas à tabela desejada.
- A junção por `SQL_ID` com `V$SQL` pode multiplicar amostras se houver múltiplos child cursors.
- SQLs históricos ausentes de `V$SQL` podem ser omitidos.
- O `HAVING COUNT(*) > 1` exclui grupos com apenas uma ocorrência; isso é amostragem ASH, **não contagem de execuções**.

**Recomendação:** validar a cardinalidade da junção e parametrizar o filtro de SQL.

## 4. `_dba_admin_scripts/BLOCKERS.SQL`

**O que faz:** identifica sessões bloqueadoras com `DBA_BLOCKERS`, `DBA_LOCK` e `V_$SESSION`, configurando saída e gerando relatório por `SPOOL`.

**Dependências:** acesso a views de administração; ambiente SQL*Plus com variáveis, estrutura de diretórios e arquivos auxiliares esperados.

**Pontos de atenção:**
- Usa comandos `START title132` e caminho `rep_out/&db/...`; a execução depende de arquivos/variáveis externos.
- O comentário histórico menciona “dead lock”, mas **bloqueio de sessão não comprova deadlock**.
- Consultas e formatação são legadas; devem ser verificadas antes do uso.
- A escrita de arquivo de relatório ocorre no cliente SQL*Plus.

**Recomendação:** separar consulta e formatação, documentar dependências externas e distinguir bloqueio de deadlock.

## 5. `_rac_grid_scripts/block_pin.sql`

**O que faz:** combina quatro séries de `GV$SYSSTAT` por `INST_ID` e calcula razões entre tempos de operações de global cache e blocos servidos.

**Dependências:** ambiente com estatísticas globais correspondentes; acesso a `GV$SYSSTAT`.

**Pontos de atenção:**
- Divide métricas por `global cache current blocks served` **sem defesa explícita para zero**.
- Rótulos de saída precisam de conferência de unidades da estatística original.
- A presença de `GV$` não prova que o resultado terá significado em instância não-RAC.

**Recomendação:** acrescentar `NULLIF` ao denominador em versão própria e explicitar unidades e escopo.

## 6. `_security_scripts/dba_user_privs.sql`

**O que faz:** define uma view chamada `DBA_USER_PRIVS` a partir de tabelas internas `SYS.SYSAUTH$`, `SYS.USER$` e mapeamentos de privilégios.

**Dependências:** acesso a estruturas internas `SYS`, privilégios de criação de view e resolução adequada do schema.

**Pontos de atenção:**
- **É DDL efetivo (`CREATE OR REPLACE VIEW`) e pode substituir uma view existente com esse nome no schema de execução.**
- Estruturas internas não são uma API estável para aplicações e podem variar por versão.
- Executar sem revisão em ambiente de produção representa risco operacional.

**Recomendação:** **não executar como rotina de diagnóstico**. Para consultas próprias, avaliar views documentadas de privilégios e papéis.

## 7. `_index_scripts/BROWN.SQL`

**O que faz:** gera dinamicamente outro script via `SPOOL`, utiliza `ANALYZE INDEX ... VALIDATE STRUCTURE`, cria/trunca tabela auxiliar, insere dados e produz relatório de ocupação.

**Dependências:** SQL*Plus, arquivos auxiliares, tabelas auxiliares e permissões de DDL/DML.

**Pontos de atenção:**
- Contém `DROP TABLE`, `CREATE TABLE`, `TRUNCATE TABLE`, `INSERT` e `COMMIT` na geração/execução de script auxiliar.
- Pode alterar objetos do schema e realizar tarefas de análise de índices custosas.
- A sintaxe/linha `#accept` requer análise antes de executar com SQL*Plus.
- Não é um script somente leitura.

**Recomendação:** classificar como **alto risco operacional**; nunca executar sem isolar schema, objetos auxiliares e consequências.

## Nota de qualidade

A classificação acima se aplica **somente aos sete arquivos examinados**. Os demais continuam pendentes de revisão individual; o nome do arquivo isoladamente não é evidência da função real.
