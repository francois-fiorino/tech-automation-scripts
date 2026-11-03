# Procedimento de revisão e documentação por script

## 1. Registro mínimo

| Campo | O que registrar |
| --- | --- |
| Identificador | Nome e caminho do arquivo original |
| Finalidade real | O que o SQL/PLSQL efetivamente consulta, calcula ou modifica |
| Tipo | Consulta; relatório; DDL; DML; PL/SQL; SQL*Plus; Shell |
| Entradas | Parâmetros `&`, `&&`, `DEFINE`, variáveis, paths fixos |
| Dependências | Views, tabelas, pacotes, arquivos auxiliares, RAC, AWR/ASH |
| Privilégios | Permissões de leitura/escrita necessárias |
| Efeitos | Alterações de objetos, dados, `COMMIT`, `SPOOL`, arquivos |
| Custo | Possíveis full scans, cargas de CPU/I/O, locks, retenção histórica |
| Versões | Comprovação por teste em cada versão Oracle relevante |
| Licenciamento | Verificar Diagnostics Pack/Tuning Pack quando aplicável |
| Segurança | Literais sensíveis, credenciais, concatenação e privilégios excessivos |
| Testes | Ambiente, evidências, resultado esperado e limitações |
| Proveniência | Créditos originais e permissão de redistribuição |
| Status | Não revisado / Revisado estaticamente / Testado / Aprovado |

## 2. Classificação de risco sugerida

- **Baixo (provisório):** somente leitura, views documentadas, sem efeitos colaterais observáveis; ainda requer validação de custo.
- **Moderado:** acesso a `SYS`, views internas, recursos licenciados, consultas pesadas ou dependências externas.
- **Alto:** DDL/DML, mudanças de sessão/instância, `COMMIT`, `TRUNCATE`, `DROP`, scripts gerados e executados, operações com sistema operacional.

O risco deve ser **derivado do conteúdo integral e do contexto de execução**, nunca apenas de uma busca por palavras-chave.

## 3. Etapas de validação

1. Preservar hash, autoria e conteúdo original fora do repositório público.
2. Identificar comandos SQL e SQL*Plus; expandir dependências de `START`/`@@`.
3. Revisar parâmetros, efeitos colaterais e acesso a tabelas internas.
4. Escrever descrição e exemplo **sem reproduzir código de terceiros sem permissão**.
5. Testar a eventual versão própria em laboratório, com privilégio mínimo e rollback/plano de recuperação quando necessário.
6. Registrar planos de execução e custo para consultas relevantes.
7. Obter autorização antes de republicar qualquer código original.
8. Publicar somente material autorizado e revisado, mediante revisão de pull request.

## 4. Modelo de ficha por script

```markdown
# Identificador do script

- Origem/autoria:
- Permissão de redistribuição:
- Objetivo real:
- Tipo e risco:
- Entradas/parâmetros:
- Objetos e pacotes acessados:
- Permissões necessárias:
- Alterações e arquivos gerados:
- Restrições de versão/licenciamento:
- Como validar em laboratório:
- Resultados esperados e limitações:
- Status de revisão:
```

**Advertência:** a documentação não equivale a homologação. Nenhum script da coleção foi executado nesta etapa.
