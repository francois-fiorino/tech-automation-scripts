# Revisão complementar das propostas administrativas

Atualizado em 04/11/2026. **80 de 177 scripts reavaliados nesta fase; 41 com alteração de código e 39 com comportamento mantido. Nenhuma compilação/execução Oracle.**

Commit da revisão 036: [0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a](https://github.com/francois-fiorino/tech-automation-scripts/commit/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a). Todos os 20 scripts e o roteiro auxiliar de laboratório foram conferidos após publicação, por conteúdo/caminho/blob. O roteiro não foi executado.

Os scripts continuam no [PR #2](https://github.com/francois-fiorino/tech-automation-scripts/pull/2), em Draft. Corrigir um erro não resolve contratos, privilégios e homologação. O número de implementações da coleção permanece 476 main e 177 revisão; o teste auxiliar não é contado como implementação adicional da coleção. Nenhum merge foi realizado.

## Arquivos da revisão 036

| Script | Tratamento | Blob SHA confirmado |
|---|---|---|
| [oracle/objects/new_fprc.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/objects/new_fprc.sql) | código e cabeçalho | `6666c78c4a2f066aa83670229bae67650980fa8e` |
| [oracle/objects/new2fprc.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/objects/new2fprc.sql) | cabeçalho; corpo preservado | `fd2a05f25a5f3406ca233889ab8a9fb8d291bfb7` |
| [oracle/administration/kill_session.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/administration/kill_session.sql) | código e cabeçalho | `9bd359d482a24e1407c11d89c365ee70f0f26ae8` |
| [oracle/administration/chng_pwd.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/administration/chng_pwd.sql) | código e cabeçalho | `48973cb5aedf841f2d404915c9a256edeceb421a` |
| [oracle/administration/chk_priv.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/administration/chk_priv.sql) | código e cabeçalho | `efd0c068cef8bc92e13a2351b4bf433d70be9b9b` |
| [oracle/administration/get_osuser.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/administration/get_osuser.sql) | cabeçalho; corpo preservado | `9572684a003205e342175126ef03c269fb0e0b44` |
| [oracle/objects/startup_date.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/objects/startup_date.sql) | código e cabeçalho | `c098b840869a592f180406e0cd292a090479ab94` |
| [oracle/objects/space.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/objects/space.sql) | código e cabeçalho | `34fbff0f6a9005b732c089d583a2ece9fa6df71d` |
| [oracle/administration/get_sum.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/administration/get_sum.sql) | cabeçalho; corpo preservado | `f0f11b800e1cfa442cf5f1ff83fed871a6b726d7` |
| [oracle/objects/dec2hex.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/objects/dec2hex.sql) | código e cabeçalho | `a257ae273965d5fd337e962509f7cbee31c69727` |
| [oracle/objects/delta_time.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/objects/delta_time.sql) | código e cabeçalho | `853312e2133da6f914a339aa4631facf12b75690` |
| [oracle/backup-recovery/get_logfiles.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/backup-recovery/get_logfiles.sql) | código e cabeçalho | `12377dfc2d8018345aac778be0971be9729ab4aa` |
| [oracle/backup-recovery/remove_logfiles.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/backup-recovery/remove_logfiles.sql) | código e cabeçalho | `0e874cc8a2f05f9a35daa32d4b0204ed00e8fb6a` |
| [oracle/objects/seq_rct.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/objects/seq_rct.sql) | código e cabeçalho | `47f3e92903e0375462a843fd7401c646af3b3d1b` |
| [oracle/administration/cre_user.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/administration/cre_user.sql) | cabeçalho; corpo preservado | `2f0ad2ac9c222824995afcf2eed5a531fa6c558f` |
| [oracle/objects/basic_mview.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/objects/basic_mview.sql) | código e cabeçalho | `8a5bb01fe41c38eaa1043b0eebf037f7885c6e5a` |
| [oracle/administration/chk_tab.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/administration/chk_tab.sql) | código e cabeçalho | `b48dfc34deceb8328554f92f6fc28868b10cd34d` |
| [oracle/administration/get_stat_count.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/administration/get_stat_count.sql) | código e cabeçalho | `651fbf2ab2202008ba8d88c7afc575888dce3ec2` |
| [oracle/administration/upsert.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/administration/upsert.sql) | código e cabeçalho | `4b5fe56286f3d9b860050064b7a8bd07ca4c214f` |
| [oracle/administration/update.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/256f3206a5c43e46ccff203a13ff3fe3fa99ac48/oracle/administration/update.sql) | código e cabeçalho | `48830f89eaa79af34c90dd527faf513b7f75808d` |

## Achados, correções e homologação individual

### `oracle/objects/new_fprc.sql`

Corrigidos os três INSERT VALUES WHERE para INSERT SELECT FROM DUAL WHERE, sem alterar campos, filtros NOT IN ou COMMIT.

**Pendências:** Dependências OFFICE/TRUNK_GROUP/MEASUREMENT/ERROR_LOG e chaves desconhecidas. NOT IN preserva sua semântica de NULL; não garante unicidade concorrente. Filtro de trunk_group ainda global por nome, não por escritório. Handler continua registrando sem relançar; não foi inventada política transacional.

**Testes de laboratório necessários:** NULL nos campos/chaves; mesmo trunk em escritórios diferentes; cargas concorrentes; erro intermediário; rollback e confirmação.

### `oracle/objects/new2fprc.sql`

Corpo reavaliado e mantido: ignorar DUP_VAL_ON_INDEX não prova equivalência entre a linha existente e a recebida.

**Pendências:** Contrato/chaves e política de erro precisam ser definidos. TDMS é homônimo incompatível com NEW_FPRC; não instalar ambos em sequência. COMMIT é global à transação do chamador e handler pode deixar inserções anteriores pendentes.

**Testes de laboratório necessários:** Chaves de escritório/trunk/data; duplicata divergente; concorrência; erro no ERROR_LOG; confirmar resultado/estado transacional em cada falha.

### `oracle/administration/kill_session.sql`

SID/SERIAL limitados a até 10 dígitos ASCII antes da concatenação, sem aspas ou metacaracteres. AUTHID CURRENT_USER evita emprestar ALTER SYSTEM do definidor; DBMS_SQL.NATIVE substitui flag V7.

**Pendências:** Exige CREATE PROCEDURE, EXECUTE DBMS_SQL e ALTER SYSTEM autorizado no contexto invocador. Validação lexical não autoriza o alvo, não evita corrida/reutilização de SID e não protege sessões críticas. Não tem parâmetro de instância RAC; não deve ser exposto indiscriminadamente por GRANT EXECUTE.

**Testes de laboratório necessários:** NULL/vazio; espaços; números normais; aspas, vírgula, comentário, newline, expoente e payload; privilégio ausente; sessão já encerrada; alvo descartável.

### `oracle/administration/chng_pwd.sql`

Direitos do invocador e SESSION_USER explícitos; username validado/citado; senha entre aspas, com rejeição de aspas duplas e caracteres de controle; cleanup em exceção e sem impressão da instrução.

**Pendências:** ALTER USER altera autenticação e pode confirmar transações; testar regras de senha/versão e contas proxy/common. O parâmetro deve vir por bind de cliente autorizado, sem literal em histórico. RETURN de DBMS_SQL não comprova número de contas alteradas. Limpar variáveis PL/SQL não garante apagamento de cópias em memória/auditoria.

**Testes de laboratório necessários:** Senha com espaços, apóstrofo, ponto-e-vírgula e ampersand por bind; doublequote/control rejeitados; usuário quoted; privilégio ausente; verify function; erro de parse; conta descartável.

### `oracle/administration/chk_priv.sql`

Buffer de tabela ancorado em USER_TAB_PRIVS.TABLE_NAME; parâmetros de cursor desambiguados e cursor fechado em exceção.

**Pendências:** Consulta a existência de linha em USER_TAB_PRIVS por nome/privilégio, sem filtrar owner/grantee; não é verificação de autorização efetiva nem expande roles. UPPER ainda limita identificadores quoted. BOOLEAN é contrato PL/SQL, não SQL BOOLEAN portátil.

**Testes de laboratório necessários:** Tabela >32 caracteres; nenhuma linha; privilégios de owners/grantees distintos; quoted misto; exceção durante FETCH.

### `oracle/administration/get_osuser.sql`

Corpo preservado; registrada a ambiguidade funcional em vez de trocar por OS_USER de sessão sem evidência do contrato.

**Pendências:** Retorna primeira OSUSER distinta dentre sessões do usuário, sem ordem; não identifica necessariamente a sessão chamadora. JOIN V$PROCESS é local e pode omitir sessões. Exige CREATE PROCEDURE e SELECT diretos.

**Testes de laboratório necessários:** Mesmo usuário em duas sessões com OSUSER diferente; nenhuma sessão correspondente; shared server; chamadas em RAC; decidir contrato antes de mudar consulta.

### `oracle/objects/startup_date.sql`

Retorno DATE obtido diretamente de V$INSTANCE.STARTUP_TIME; eliminados KEY/VALUE obsoletos, montagem juliana e roundtrip NLS. Saída de diagnóstico em ISO; OUT inicializado NULL no caso sem linha.

**Pendências:** Reimplementação da obtenção da mesma informação por coluna documentada. CREATE PROCEDURE e SELECT direto em SYS.V_$INSTANCE necessários. Data é da instância local, não uptime da PDB nem conjunto RAC.

**Testes de laboratório necessários:** Comparar OUT a V$INSTANCE.STARTUP_TIME com NLS_DATE_FORMAT distintos; NULL/erro de acesso; instâncias RAC diferentes.

### `oracle/objects/space.sql`

DBA_DATA_FILES conduz o relatório com LEFT JOIN de espaço livre; arquivos sem extents livres aparecem com zero. Detalhe do arquivo usa a mesma família de views/container em vez de cruzar V$DATAFILE.

**Pendências:** Zero em DBA_FREE_SPACE também pode refletir indisponibilidade de metadados/arquivo offline; não inferir ocupação exata sem verificar status e acesso. Continua sem tempfiles ou potencial AUTOEXTEND; valores exibidos são KiB apesar do rótulo histórico KB.

**Testes de laboratório necessários:** Datafile com zero extents livres; vários extents; arquivo offline; tamanho zero; PDB com FILE_ID local.

### `oracle/administration/get_sum.sql`

Função preservada: acrescentar owner ou partições mudaria seu contrato atual de soma global por nome.

**Pendências:** Soma extents SEGMENT_TYPE=TABLE em todos os owners visíveis; NULL quando nenhum. Não mede bytes de linhas nem inclui partições. Evitar uso para atribuição por schema sem decidir nova interface.

**Testes de laboratório necessários:** Nomes homônimos em dois schemas; tabela particionada; tabela vazia/deferred; nenhum extent; definir se escopo global é pretendido.

### `oracle/objects/dec2hex.sql`

Preservado o algoritmo modular e crédito Jonas Nordstrom. Entradas inválidas rejeitadas; HEXTOINTEGER aceita lowercase, trata NULL e limita ao PLS_INTEGER positivo. INTEGERTOHEX(0) retorna 0, preservando recursão sem zeros extras.

**Pendências:** Domínio agora explícito: DEC2HEX inteiro NUMBER não negativo; HEXTOINTEGER 0..7FFFFFFF sem sinal/prefixo; INTEGERTOHEX PLS_INTEGER não negativo. Isso muda retornos indevidos anteriores para erro e corrige zero. Não interpreta hexadecimal como signed/two-complement.

**Testes de laboratório necessários:** NULL,0,15,16,255,2147483647; lowercase; G, espaços, sinal, fração, -1 e 80000000; roundtrip no domínio comum.

### `oracle/objects/delta_time.sql`

Diferença absoluta usa todas as componentes DATE, inclusive dias. Mantidos retorno textual e DBMS_OUTPUT; horas totais não fazem wrap em 24h. NULL retorna NULL.

**Pendências:** Contrato corrigido é duração absoluta H+:MI:SS, com pelo menos dois dígitos de hora. Para intervalos >=24h, saída pode ter mais de 8 caracteres e consumidores precisam adequação. DATE não contém fuso; não calcula DST ou precisão de TIMESTAMP.

**Testes de laboratório necessários:** Datas iguais; virada de meia-noite; 25h; vários dias; argumentos invertidos; NULL; NLS distintos.

### `oracle/backup-recovery/get_logfiles.sql`

Chamadas diretas ADD_LOGFILE substituem PL/SQL concatenado; AUTHID CURRENT_USER; EOF tratado só no GET_LINE; erros propagados com fechamento do arquivo. DIRECTORY lógico separado de caminho físico; terceiro parâmetro opcional de base preserva chamadas com dois argumentos.

**Pendências:** Alvo modernizado usa DIRECTORY Oracle e READ no objeto, acesso SO, SELECT em ALL_DIRECTORIES e EXECUTE/autorizações LogMiner do invocador. Nome de DIRECTORY é normalizado para uppercase. Caminhos absolutos na lista são respeitados; relativos usam base física. Linhas vazias são ignoradas. Primeiro arquivo não vazio usa NEW e substitui lista LogMiner anterior; seguintes usam ADDFILE. Falha após várias chamadas deixa alterações parciais na lista; não existe rollback automático. Não inicia mining.

**Testes de laboratório necessários:** Lista vazia; linha em branco; caminho Unix, Windows e UNC; base com/sem separador; apóstrofo no nome; erro no segundo arquivo; DIRECTORY sem READ; EOF versus erro LogMiner.

### `oracle/backup-recovery/remove_logfiles.sql`

Chamadas diretas ADD_LOGFILE substituem PL/SQL concatenado; AUTHID CURRENT_USER; EOF tratado só no GET_LINE; erros propagados com fechamento do arquivo. DIRECTORY lógico separado de caminho físico; terceiro parâmetro opcional de base preserva chamadas com dois argumentos.

**Pendências:** Alvo modernizado usa DIRECTORY Oracle e READ no objeto, acesso SO, SELECT em ALL_DIRECTORIES e EXECUTE/autorizações LogMiner do invocador. Nome de DIRECTORY é normalizado para uppercase. Caminhos absolutos na lista são respeitados; relativos usam base física. Linhas vazias são ignoradas. REMOVEFILE apenas remove a entrada da lista LogMiner, não apaga arquivo. Falha após várias chamadas deixa alterações parciais na lista; não existe rollback automático. Não inicia mining.

**Testes de laboratório necessários:** Lista vazia; linha em branco; caminho Unix, Windows e UNC; base com/sem separador; apóstrofo no nome; erro no segundo arquivo; DIRECTORY sem READ; EOF versus erro LogMiner.

### `oracle/objects/seq_rct.sql`

Staging/texto/buffer ampliados para 128/4000; owners e sequências citados por DBMS_ASSERT.ENQUOTE_NAME(FALSE); saída deixa de quebrar linhas em 60 caracteres. Todos os campos, DROP/CREATE e algoritmo de staging preservados.

**Pendências:** LAST_NUMBER não é próximo valor exato com cache; restauração em ambiente ativo pode gerar gaps/repetição. Não exporta grants ou propriedades modernas como SCALE/SHARD/SESSION/KEEP. SEQ_TEMP não deve preexistir; cria/remove staging e confirma transações.

**Testes de laboratório necessários:** Owners e nomes longos/quoted; múltiplos schemas; cache zero/grande; CYCLE/ORDER; sequências existentes no destino; verificar integridade do spool e valores sem aplicar em produção.

### `oracle/administration/cre_user.sql`

Fluxo não alterado nesta revisão: ACCEPT HIDE não impede interpolação SQL*Plus nem torna a entrada uma bind variable.

**Pendências:** Ainda exige entrada confiável sem aspas/metacaracteres. USER/DEFAULT/TEMP e PASSWORD são substituições textuais antes do parse; ampliar escaping exige nova interface de fornecimento de segredo. Grants e quota ilimitada precisam aprovação específica; não há cleanup transacional de DDL.

**Testes de laboratório necessários:** Aspas, ampersand e newline; valores de username/tablespace não confiáveis; falha entre CREATE e GRANT; decidir interface de binds/segredo antes de liberar o script.

### `oracle/objects/basic_mview.sql`

Gerador substitui concatenação inválida de LONG por CLOB de DBMS_METADATA.GET_DDL; SQLTERMINATOR habilitado; spool local e ordenado. Não emite CREATE OR REPLACE MATERIALIZED VIEW.

**Pendências:** GET_DDL exige EXECUTE DBMS_METADATA e visibilidade de metadados (próprios ou SELECT_CATALOG_ROLE autorizado). Não inclui dependentes/grants completos nem dados; não é backup. Limite LONG de saída é 1000000; conferir truncamento. Transformação de sessão é restaurada ao default, não ao valor customizado anterior; usar cliente dedicado. Saída não é executada.

**Testes de laboratório necessários:** MView com QUERY >10k; refresh/storage/quoted; usuário sem acesso a outro schema; saída >1MB; spool indisponível; comparar DDL com catálogo.

### `oracle/administration/chk_tab.sql`

Identificadores do ANALYZE citados por DBMS_ASSERT; buffer de tabela ancorado e instrução ampliada; limiar negativo/NULL rejeitado; cleanup antes do RAISE e cursor inicializado.

**Pendências:** Preservados algoritmo, piso um, limiar e dependência DBA_UTILITIES.GET_COUNT. O helper recebe UPPER(owner.table) e ainda não trata nomes quoted mistos; sem sua fonte/contrato não se declara suporte. ANALYZE pode alterar planos/bloquear; grants diretos exigidos.

**Testes de laboratório necessários:** Nomes longos; owner/tabela quoted no gerador versus helper; pacote ausente; erro no PARSE; limiar negativo; zero linhas e redução de cardinalidade.

### `oracle/administration/get_stat_count.sql`

Buffer ancorado em DBA_TABLES.TABLE_NAME e cursor fechado em exceção; chamada do helper mantida para não presumir contrato de nome qualificado.

**Pendências:** DBA_UTILITIES.GET_COUNT recebe apenas nome da tabela e pode contar objeto de schema errado. Schema permanece case-sensitive conforme interface existente. NUM_ROWS pode estar desatualizado; helper/grants/chaves precisam ser fornecidos e revisados.

**Testes de laboratório necessários:** Owner do chamador diferente do schema; tabelas homônimas; nome >32 caracteres; helper ausente/com erro; cursor fechado após falha.

### `oracle/administration/upsert.sql`

INSERT e origem MERGE usam a lista explícita dos sete campos já existentes no contrato MERGE; eliminada dependência de ordem/colunas extras de SELECT *. Demais filtros e sequência preservados.

**Pendências:** Os três exemplos continuam em sequência; não executar como alternativas independentes. Duplicatas na fonte podem causar ORA-01427/30926; UPDATE sem match continua atribuindo NULL por comportamento original. Chave NULL e concorrência não resolvidas; sem COMMIT explícito.

**Testes de laboratório necessários:** Colunas em ordem diferente e coluna extra; SCRIPT_NAME duplicado/NULL; target sem match; fonte vazia; reexecução e concorrência.

### `oracle/administration/update.sql`

Validação de lote inteiro positivo antes de TRUNCATE; nome alvo validado por SQL_OBJECT_NAME; DATE e ROWID passam por bind; buffer ampliado, NATIVE e cleanup em erro. Limite inclusivo BETWEEN corrigido para rowcount+rows-1, respeitando tamanho solicitado.

**Pendências:** TEMP_TAB ainda é compartilhada e truncada, com COMMIT por lote e possível confirmação do trabalho do chamador; proibir concorrência. ROWID pode ficar obsoleto por movimento de linha. SQL_OBJECT_NAME não verifica autorização de negócio nem fixa identidade do objeto. Somente tabela heap/ROWID físico e ENTRY_TS compatível; não homologado para IOT/UROWID/remote. Falha deixa lotes anteriores confirmados.

**Testes de laboratório necessários:** NULL/zero/negativo/fracionário; lote1/exato/resíduo; alvo vazio; nome malicioso/inexistente; NLS de data; movimento de linha; erro no lote2; concorrência proibida.

## Validação local e roteiro de laboratório

Foram analisados por parser SQLGlot em dialeto Oracle os quatro INSERTs do TDMS (três corrigidos e o registro de erro) e as três instruções de UPSERT. Não se declarou parsing/compilação integral de PL/SQL pelo parser local. Foram executadas fixtures SQLite dos INSERT SELECT com parâmetros adaptados para binds locais, para inserção repetida e a semântica preservada de NOT IN com NULL; LEFT JOIN de datafile sem extents livres; e limites de lotes para tamanhos/coberturas diferentes. Esses resultados não equivalem à semântica transacional ou runtime Oracle.

O [roteiro Oracle review036_lab.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/0c6e9ce71d3ffa3d8d4da1bd303a827474ae5d8a/oracle/collection/tests/review036_lab.sql) cobre conversores, duração (incluindo >24h) e data de startup, após instalação individual em schema descartável. Não instala rotinas nem chama KILL SESSION, ALTER USER, LogMiner, ANALYZE ou atualização em lotes. Não foi executado neste trabalho. As demais rotinas dependem dos casos específicos listados acima e de objetos/contratos do laboratório.

Os cabeçalhos agora incluem as referências oficiais das APIs usadas. Foram preservados algoritmos essenciais ou substituída a obtenção obsoleta da mesma informação por APIs completas documentadas, com a diferença explicitada. Não houve uso de pseudocódigo para substituir implementação.

Ajuste final do mesmo lote: parâmetros internos do cursor de UPDATE_IT renomeados para evitar ROW reservado, preservando a interface pública. Commit [256f3206a5c43e46ccff203a13ff3fe3fa99ac48](https://github.com/francois-fiorino/tech-automation-scripts/commit/256f3206a5c43e46ccff203a13ff3fe3fa99ac48); blob conferido após publicação.

## Revisão 037 — mais 20 scripts

Commit [5c46898439576d594ef844d4575660995fb4fadf](https://github.com/francois-fiorino/tech-automation-scripts/commit/5c46898439576d594ef844d4575660995fb4fadf). Conteúdo/caminho/blob dos 20 arquivos conferidos após publicação. Onze receberam alterações de código; nove tiveram comportamento mantido com pendências de ambiente/contrato explicitadas.

| Script | Tratamento | Blob SHA |
|---|---|---|
| [oracle/administration/windows/batch_substitute.bat](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/administration/windows/batch_substitute.bat) | cabeçalho; corpo preservado | `f4d177c520baafbfd1117d4e8534b35bb4d2eef2` |
| [oracle/administration/isvaldat.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/administration/isvaldat.sql) | cabeçalho; corpo preservado | `7b8665476e41a440fa3d780ea1368dc1b3621394` |
| [oracle/security/link_rct.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/security/link_rct.sql) | código/cabeçalho | `15de84d55dfc1069b726cceb55ea04b5a07340df` |
| [oracle/administration/ora_kill.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/administration/ora_kill.sql) | código/cabeçalho | `21fec0c3ffa03bc6ddc645aab549e2fc71459750` |
| [oracle/administration/rbk_rct.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/administration/rbk_rct.sql) | código/cabeçalho | `3084df5191f2303b43a21ce13f57312c82308844` |
| [oracle/administration/run_fprc.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/administration/run_fprc.sql) | cabeçalho; corpo preservado | `6ddc0eef3679e5ec02d7e0ef56f54dae0eeb948e` |
| [oracle/administration/check_schema.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/administration/check_schema.sql) | código/cabeçalho | `1047bda2c7edd9b3e0e08c64cc8cc57bf5a92967` |
| [oracle/security/cr_role.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/security/cr_role.sql) | cabeçalho; corpo preservado | `88b141097696c5c25a119da65c54629f158af6cb` |
| [oracle/administration/cre_dba_running_stats.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/administration/cre_dba_running_stats.sql) | cabeçalho; corpo preservado | `fea08e0124aa42c26122927b53cbf5da8f25e7ac` |
| [oracle/administration/cre_tem_size.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/administration/cre_tem_size.sql) | cabeçalho; corpo preservado | `665110b0e013a2ec9b8b8eb5345f94675f930afd` |
| [oracle/administration/create_block_views.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/administration/create_block_views.sql) | cabeçalho; corpo preservado | `d7ee248f6b01df333d365f4511e7fd99c58a1fb7` |
| [oracle/objects/create_cluster.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/objects/create_cluster.sql) | código/cabeçalho | `021032abbcd094681164cb5bf788769cd32645f8` |
| [oracle/administration/db_df.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/administration/db_df.sql) | cabeçalho; corpo preservado | `382b5c29960e7aa00a055e816f3fa960aa7b265a` |
| [oracle/administration/drop_rbk.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/administration/drop_rbk.sql) | cabeçalho; corpo preservado | `2d56a86efe7cafda5a52811d09f98d08600e7550` |
| [oracle/objects/extract_data_subset.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/objects/extract_data_subset.sql) | código/cabeçalho | `c4c97cf9a73102d6ebebca845347a78812fba120` |
| [oracle/administration/flush_it.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/administration/flush_it.sql) | código/cabeçalho | `d65e3451f9ed485d5e12b9527e35c329455b3cd3` |
| [oracle/administration/flush_it7.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/administration/flush_it7.sql) | código/cabeçalho | `e63cbdded1b3c0571cc26b4d7f45a74aebb7983f` |
| [oracle/administration/flush_it8.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/administration/flush_it8.sql) | código/cabeçalho | `09ac6b7b03cd1428cd1fc14ec069467bdacd5157` |
| [oracle/administration/flush_it_new.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/administration/flush_it_new.sql) | código/cabeçalho | `c958deda358a6d0edda94004ce1a84fb1a3d0679` |
| [oracle/administration/hratio.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/5c46898439576d594ef844d4575660995fb4fadf/oracle/administration/hratio.sql) | código/cabeçalho | `8b53706f8ca4ae081bc77b92a70ceec1e0c3c738` |

### `oracle/administration/windows/batch_substitute.bat`

Corpo CMD preservado; a expansão CALL ainda reinterpreta metacaracteres e exige interface sem execução de texto para aceitar entrada não confiável.

**Pendências:** Sem Windows disponível; não é SQL e não passa por parser Oracle. Aceitar somente arquivos/argumentos confiáveis em VM descartável.

**Testes necessários:** Espaços em caminho; Unicode; linhas vazias; %, !, &, |, redirecionamento e aspas; nenhum teste Windows executado.

### `oracle/administration/isvaldat.sql`

Contrato 0=válido/1=erro preservado, inclusive NULL válido e captura genérica de exceção.

**Pendências:** Não distingue formato inválido de data inválida; TO_DATE sem FX é flexível. Não impor formato exato ou rejeitar NULL sem mudar API esperada.

**Testes necessários:** NULL, string vazia, ano bissexto, mês inválido, máscara inválida, FX e NLS_DATE_LANGUAGE distintos.

### `oracle/security/link_rct.sql`

Gerador reimplementado por DBA_DB_LINKS sem ler SYS.LINK$/senhas, sem staging DDL e sem minúsculas ou remoção de domínio. Saída contém marcadores de segredo e EXIT bloqueante; HOST é citado com escape de apóstrofo e identificadores por DBMS_ASSERT. HOST com marcadores usuais de autenticação é retido e substituído por marcador de serviço; a detecção não é garantia de anonimização de descriptor arbitrário.

**Pendências:** Não restaura segredos, credenciais, links SHARED/authenticated e todos os atributos modernos. CONNECT privado exige autenticação manual; PUBLIC exige conta autorizada sem assumir SYS. Saída é proposta bloqueada, não roteiro aplicável sem revisão. Metadados de HOST podem conter informação sensível e precisam de proteção; rejeitar/remover eventual credencial embutida no catálogo antes de compartilhar o spool.

**Testes necessários:** Link conectado/fixed user; nome com domínio/quoted; host com apóstrofo; PUBLIC versus privado; catálogo vazio; limite DBMS_OUTPUT; saída deve começar com EXIT bloqueante.

### `oracle/administration/ora_kill.sql`

Gerador exclui a própria sessão e restringe TYPE=USER além das exclusões existentes de SYS/NULL. Continua sem executar o spool.

**Pendências:** Não é lista de sessões não essenciais: inclui contas administrativas e de aplicação críticas. Revalidar SID/SERIAL antes de cada aplicação e privilégio no KILL_SESSION revisado; escopo local, sem RAC remoto.

**Testes necessários:** Sessão chamadora; SYS; background; usuário crítico; sessão encerrada ou SID reutilizado entre geração e uso.

### `oracle/administration/rbk_rct.sql`

Nomes de segmento/tablespace preservam case por ENQUOTE_NAME; staging e buffer ampliados para 128/4000 e saída sem quebra em 80 caracteres.

**Pendências:** Continua roteiro de undo manual legado, não migração de AUM. OFFLINE não recupera OPTIMAL, staging deve ser exclusivo e grants/custo/storage exigem ambiente alvo. DDL confirma transações e saída não é aplicada automaticamente.

**Testes necessários:** Nomes quoted/longos; ONLINE/OFFLINE; OPTIMAL ausente; tabela staging existente; spool íntegro; ambiente legado descartável com undo manual.

### `oracle/administration/run_fprc.sql`

Pipeline mantido: gera driver e executa helper para produzir fonte; documentada dependência real da localização e de valores confiáveis.

**Pendências:** OWNER/TYPE/NAME são substituição textual SQL*Plus; helper usa SQLPATH, arquivos externos e pode revelar código/segredos. Caminhos rep_out e nome de helper dependem do diretório de execução. Não presumir que @@ resolveria arquivos a partir do driver gerado em outra pasta.

**Testes necessários:** Owner/type/name com espaços/aspas; diretório ausente; FPRC_RCT no SQLPATH; fonte longa/com segredo; arquivo de saída existente; definir nova interface antes de entradas não confiáveis.

### `oracle/administration/check_schema.sql`

Sequência de três ADMIN_TABLES numéricos substituída por CREATE_ACTION somente se SYS.REPAIR_TABLE não existe. Não apaga/purga evidências antes do CHECK_OBJECT. Tipos usam constantes DBMS_REPAIR no PL/SQL e buffers ancorados.

**Pendências:** Rotina de DBA com acesso especial SYS/DBMS_REPAIR; checagem de existência não valida estrutura nem elimina corrida de criação. Tabela existente é reutilizada e pode acumular evidência. CHECK_OBJECT documenta TABLE/INDEX; suporte de CLUSTER deve ser confirmado antes de uso. Não repara nem marca blocos automaticamente.

**Testes necessários:** Tabela de reparo ausente/existente/estrutura incorreta; corrida de criação; TABLE/INDEX/CLUSTER; schema vazio; falha em objeto intermediário; custo de varredura em cópia descartável.

### `oracle/security/cr_role.sql`

Lista integral de CREATE ROLE/GRANT preservada; não alterado destinatário nem objetos por suposição.

**Pendências:** Objetos de aplicação e GMPRATIC são exemplos históricos, sem autorização atual implícita. DDL pode confirmar e aplicar parcialmente. Requer decisão de matriz de acesso e privilégios mínimos antes de execução.

**Testes necessários:** Objetos/conta inexistentes; role já criada; falha no meio dos grants; autoridade WITH GRANT OPTION; escopo PDB/common.

### `oracle/administration/cre_dba_running_stats.sql`

DDL de staging histórico preservado, sem tornar DROP em recriação silenciosamente idempotente.

**Pendências:** DROP destrói histórico e confirma transação; colunas precisam coincidir com consumidores. DATA_TABLESPACE é substituição textual de entrada confiável. Não cria retenção/PK/índice nem rotina de coleta.

**Testes necessários:** Tabela existente com dados; tabela ausente; quota/tablespace; consumidores de cinco colunas; falha após DROP.

### `oracle/administration/cre_tem_size.sql`

Estrutura de duas colunas preservada para manter compatibilidade dos consumidores; não adicionada chave owner por suposição.

**Pendências:** DROP remove dados; contratos sem OWNER podem misturar tabelas homônimas. Tablespace por substituição SQL*Plus; revisar apenas entrada confiável. Storage legado pode ser ignorado em LMT.

**Testes necessários:** Nomes >32/até128; homônimos em schemas; tabela existente/ausente; consumidores COUNT/FILL; quota e storage.

### `oracle/administration/create_block_views.sql`

Views internas e grants preservados; nenhum mapeamento de flags foi promovido a API estável.

**Pendências:** X$BH, LRBA_SEQ, DIRTY_QUEUE e FLAG dependem da versão/estrutura interna. Substitui views e concede acesso a DBAUTIL; SELECT direto e decisão de segurança são necessários.

**Testes necessários:** Colunas presentes no RU alvo; unidades dos flags; custo de varredura; DBAUTIL ausente; falha entre DROP/CREATE/GRANT; dependentes invalidados.

### `oracle/objects/create_cluster.sql`

Exemplo inclui CREATE INDEX ON CLUSTER; cláusulas CLUSTER das tabelas mapeiam a coluna local DEPTNO à chave do cluster, em vez de usar indevidamente o nome da chave de cluster como coluna local.

**Pendências:** Permanece template com marcadores <...> que precisam de edição consciente; não compila sem configurar. Tablespace USERS e storage são exemplos. CREATE CLUSTER/TABLE/INDEX confirma transações e pode falhar parcialmente; não instala DEMO sobre dados existentes.

**Testes necessários:** Nomes configurados; chave de cluster com nome diferente de DEPTNO; INSERT de departamentos/empregados; índice de cluster; FK/PK; ASSM/LMT; objetos existentes.

### `oracle/administration/db_df.sql`

Definição histórica preservada, sem presumir equivalência de tabelas internas com DBA_DATA_FILES atual.

**Pendências:** SYS.TS$/FILE$/FILEXT$ e unidades são dependentes de versão. MAXEXTEND/INC podem não representar bytes; ausência de linha FILEXT$ é permitida pelo outer join. Não tratar como inventário moderno homologado.

**Testes necessários:** Layout/colunas do RU alvo; arquivos sem FILEXT$; autoextend ligado/desligado; CDB/PDB; validar unidade de cada campo.

### `oracle/administration/drop_rbk.sql`

Comandos e aviso educacional histórico preservados; a afirmação de teste do autor não foi tratada como teste desta revisão.

**Pendências:** DROP de RB6 etc. são nomes históricos e não alvos autorizados. Requer undo manual/offline e ausência de transações/dependências. DDL pode ter sucesso parcial e não é reversível por ROLLBACK.

**Testes necessários:** Ambiente manual descartável; nomes existentes/ausentes; segmento online/em uso; revisar cada alvo antes de executar qualquer comando.

### `oracle/objects/extract_data_subset.sql`

Retorno antecipado para tabela já emitida evita repetição/recursão cíclica no caminho alcançado; flag reiniciada por filho; nomes emitidos citados por ENQUOTE_NAME, buffers até32767 e percentual validado. Percentual emitido como inteiro/100, sem decimal NLS.

**Pendências:** Ainda não é amostragem aleatória/anonimização. Seleção de raízes pode omitir grafos sem raiz/ciclos e self-FKs; múltiplos pais, chaves NULL e preservação referencial exigem testes. CTAS gerado perde constraints/grants/índices e pode exceder32767 em schema amplo. Chamada exemplo MOVIES/BERT continua apenas gerando texto.

**Testes necessários:** Diamante; ciclo alcançável; grafo sem raiz; self-FK; múltiplas FKs; chaves compostas/NULL; nomes quoted; 0/100/fora da faixa; decimal NLS; texto longo; reexecução XGO.

### `oracle/administration/flush_it.sql`

Limiar validado antes da coleta; base de memória ausente/zero falha explicitamente antes de FLUSH/KEEP; NATIVE e cleanup de cursores em exceção com RAISE. Política/cursores/commits existentes preservados.

**Pendências:** FLUSH pode causar hard parse e degradação global; definer rights/grants EXECUTE precisam de revisão. Categorias/SQL_SUMMARY/DBA_RUNNING_STATS e estruturas internas, quando presentes, ainda exigem contrato. ASMM/AMM pode tornar tamanho configurado inadequado, mesmo positivo. KEEPs podem ter efeito parcial antes de falha; não há rollback de estado de shared pool.

**Testes necessários:** NULL, negativo,0,0.5,1,100,>100; baseNULL/zero; pacote/view ausente; falha duranteKEEP/PARSE/INSERT; cursor fechado; medir impacto só em laboratório descartável.

### `oracle/administration/flush_it7.sql`

Limiar validado antes da coleta; base de memória ausente/zero falha explicitamente antes de FLUSH/KEEP; NATIVE e cleanup de cursores em exceção com RAISE. Política/cursores/commits existentes preservados.

**Pendências:** FLUSH pode causar hard parse e degradação global; definer rights/grants EXECUTE precisam de revisão. Categorias/SQL_SUMMARY/DBA_RUNNING_STATS e estruturas internas, quando presentes, ainda exigem contrato. ASMM/AMM pode tornar tamanho configurado inadequado, mesmo positivo. KEEPs podem ter efeito parcial antes de falha; não há rollback de estado de shared pool.

**Testes necessários:** NULL, negativo,0,0.5,1,100,>100; baseNULL/zero; pacote/view ausente; falha duranteKEEP/PARSE/INSERT; cursor fechado; medir impacto só em laboratório descartável.

### `oracle/administration/flush_it8.sql`

Limiar validado antes da coleta; base de memória ausente/zero falha explicitamente antes de FLUSH/KEEP; NATIVE e cleanup de cursores em exceção com RAISE. Política/cursores/commits existentes preservados.

**Pendências:** FLUSH pode causar hard parse e degradação global; definer rights/grants EXECUTE precisam de revisão. Categorias/SQL_SUMMARY/DBA_RUNNING_STATS e estruturas internas, quando presentes, ainda exigem contrato. ASMM/AMM pode tornar tamanho configurado inadequado, mesmo positivo. Mantida convenção antiga: valor <1 é fração, valor >=1 é percentual; exatamente1 significa1%, não100%. KEEPs podem ter efeito parcial antes de falha; não há rollback de estado de shared pool.

**Testes necessários:** NULL, negativo,0,0.5,1,100,>100; baseNULL/zero; pacote/view ausente; falha duranteKEEP/PARSE/INSERT; cursor fechado; medir impacto só em laboratório descartável.

### `oracle/administration/flush_it_new.sql`

Limiar validado antes da coleta; base de memória ausente/zero falha explicitamente antes de FLUSH/KEEP; NATIVE e cleanup de cursores em exceção com RAISE. NUM_RUNS validado como inteiro não negativo. Política/cursores/commits existentes preservados.

**Pendências:** FLUSH pode causar hard parse e degradação global; definer rights/grants EXECUTE precisam de revisão. Categorias/SQL_SUMMARY/DBA_RUNNING_STATS e estruturas internas, quando presentes, ainda exigem contrato. ASMM/AMM pode tornar tamanho configurado inadequado, mesmo positivo. KEEPs podem ter efeito parcial antes de falha; não há rollback de estado de shared pool.

**Testes necessários:** NULL, negativo,0,0.5,1,100,>100; baseNULL/zero; pacote/view ausente; falha duranteKEEP/PARSE/INSERT; cursor fechado; medir impacto só em laboratório descartável.

### `oracle/administration/hratio.sql`

Denominador do ratio de período protegido por NULLIF; erro deixa de inserir segunda coleta/confirmar valor artificial. Cursor fecha em erro e exceção é propagada. Data/hora derivadas do mesmo SYSDATE; ratio NUMBER sem limite5,2.

**Pendências:** Tabela HIT_RATIOS e sua chave não fornecidas; duas coletas/hora podem multiplicar subconsultas e causar ORA-01427. Restart e dados ausentes ainda invalidam deltas; não há startup/instância no contrato. Commits existentes podem deixar atualização parcial. Não usar hit ratio isolado para decidir ação.

**Testes necessários:** Zero delta; várias coletas na hora; virada de dia; restart; estatística ausente; erro de tabela/UPDATE; razões negativas; confirmar estado após commits.

### Validação local do lote 037

Os dois UPDATEs de HITRATIO passaram pelo parser SQLGlot em dialeto Oracle. Inspeções locais verificaram ausência de leitura de senha em SYS.LINK$ no novo gerador, barreira EXIT no arquivo gerado, ciclo create-only da tabela DBMS_REPAIR, template de cluster com índice e coluna local correta, guards de shared pool e cleanup. Fixtures locais cobriram grafos com ciclo/diamante/self-edge, denominador zero e quoting de HOST. Modelos de grafo não equivalem a executar o pacote SUBSETDATA. Nenhum script foi executado ou compilado em Oracle/Windows; os erros e limitações de domínio permanecem descritos individualmente.

## Revisão 038 — 04/11/2026

Mais 20 scripts reavaliados: nove alterações de código e 11 revisões documentais. Commit [169cc5270f3af21fc0a336badeda46c314beb09c](https://github.com/francois-fiorino/tech-automation-scripts/commit/169cc5270f3af21fc0a336badeda46c314beb09c); todos os arquivos foram conferidos por conteúdo/caminho/blob após publicação. Permanecem no PR #2; nenhum merge ou execução Oracle/Windows.

| Script | Tratamento | Blob SHA confirmado |
|---|---|---|
| [oracle/memory/keep_them.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/memory/keep_them.sql) | cabeçalho; corpo preservado | `115347eab932ffddcac5e5c178e17cbed5025637` |
| [oracle/security/link.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/security/link.sql) | cabeçalho; corpo preservado | `72040599c65733dc2a0d406c70ff9f824c7c423b` |
| [oracle/administration/map_db.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/administration/map_db.sql) | cabeçalho; corpo preservado | `d226af302bdd1c384f2c430baee762e676487706` |
| [oracle/security/pword_gen.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/security/pword_gen.sql) | cabeçalho; corpo preservado | `dae1219f444867d38d152ac0fee104aaf2bcbd1c` |
| [oracle/administration/rbk_views.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/administration/rbk_views.sql) | cabeçalho; corpo preservado | `39b3d09e49be91b57c3dfde0d0822be87d69bf05` |
| [oracle/administration/version.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/administration/version.sql) | código/cabeçalho | `e1998946bcdf80e6b5953c37a53f4f480fed63be` |
| [oracle/administration/count_blocks.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/administration/count_blocks.sql) | código/cabeçalho | `8f3b1d5ac41aac6b70205a5b2086dc8219c5e6c5` |
| [oracle/administration/fill_sz.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/administration/fill_sz.sql) | cabeçalho; corpo preservado | `bb370032dc24652e7e7e2b43e38cee32799818e6` |
| [oracle/administration/new_dba_free.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/administration/new_dba_free.sql) | cabeçalho; corpo preservado | `6c4c13f1032937a3b25046ee215f04bbb71832e4` |
| [oracle/administration/brown.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/administration/brown.sql) | código/cabeçalho | `8690bc9198f111c1578d1f4726a618ea43079a71` |
| [oracle/administration/explain.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/administration/explain.sql) | cabeçalho; corpo preservado | `a7a7c5ff0ac5d4120817003300aa6e2496c540b7` |
| [oracle/objects/in_rct.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/objects/in_rct.sql) | código/cabeçalho | `3aeb44298dceace7db9da870554b90a61a446812` |
| [oracle/objects/in_rct2.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/objects/in_rct2.sql) | código/cabeçalho | `2e68dcab21ef116c079d50b8a8847cef59114d5f` |
| [oracle/administration/exp_ext_tab.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/administration/exp_ext_tab.sql) | código/cabeçalho | `347bc5102b315a682aaa43e48d77d01af67b8dbd` |
| [oracle/performance/explain1.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/performance/explain1.sql) | cabeçalho; corpo preservado | `8641e304de88e07956528da609e1b00be99e3965` |
| [oracle/administration/in_siz_es.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/administration/in_siz_es.sql) | código/cabeçalho | `468fd1b3982ad32fdc38f4ded7c2b0babf30f464` |
| [oracle/administration/index_size.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/administration/index_size.sql) | cabeçalho; corpo preservado | `4b1c63a704164a6a1a799b22db953d1a0e253a3d` |
| [oracle/administration/index_sz.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/administration/index_sz.sql) | código/cabeçalho | `9fbe7f04e65e80d66a0aededdc03c1390d046b9e` |
| [oracle/administration/legacy-linux/proc_sys_net.sh](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/administration/legacy-linux/proc_sys_net.sh) | código/cabeçalho | `a19827df6b32ba67298e1e9a787a2464e19792e3` |
| [oracle/rac/staggered_sequence_trigger.sql](https://github.com/francois-fiorino/tech-automation-scripts/blob/169cc5270f3af21fc0a336badeda46c314beb09c/oracle/rac/staggered_sequence_trigger.sql) | cabeçalho; corpo preservado | `546ab33ac74dbf0af58f6584dc892067932c466e` |

### `oracle/memory/keep_them.sql`

Chamadas/ordem mantidas; não escolhidos flags de KEEP sem confrontar tipo/versão dos objetos.

**Pendências:** Lista fixa de objetos Oracle antigos, com tipos mistos e flags vazios; pode falhar parcialmente e pressionar shared pool. Duplicata de WRI$_ADV_HDM_T preservada como parte do exemplo histórico. Não é recomendação de pinning geral.

**Testes de laboratório necessários:** Confrontar DBA_OBJECTS/flags da API para cada um dos33 comandos; objeto ausente; impacto de memória; efeito parcial; nenhum KEEP foi executado.

### `oracle/security/link.sql`

Proposta sanitizada e os dois bloqueios anteriores preservados; não removido EXIT nem trocados os dois nomes por suposição.

**Pendências:** Intenção de DROP/CREATE com nomes diferentes e fornecimento seguro do segredo precisam de definição. Autorização de DDL público e plano de recuperação permanecem pendentes.

**Testes de laboratório necessários:** Confirmar que ambas as barreiras precedem todo DDL; revisar os dois nomes e o escopo PUBLIC em laboratório descartável.

### `oracle/administration/map_db.sql`

Relatório/UNION/QUIT preservados; registrados efeitos do cliente e ambiguidade de segmentos homônimos.

**Pendências:** QUIT pode confirmar a transação do chamador e encerra o cliente; usar sessão dedicada sem trabalho pendente. Relatório não inclui owner/partição na identidade textual, nem tempfiles. Nomes de host/banco compõem o spool e requerem ambiente confiável.

**Testes de laboratório necessários:** Extents em arquivos distintos; segmento homônimo; lacunas livres; spool existente; sessão dedicada; aliases de COMPUTE versus cabeçalhos do cliente.

### `oracle/security/pword_gen.sql`

Algoritmo histórico preservado para estudo e mantido como inadequado para autenticação. Não transformado em gerador seguro apenas mudando seed ou nomes.

**Pendências:** Seis caracteres A–Z têm no máximo26^6 combinações e seed temporal é previsível. Uma geração criptográfica com tamanho adequado exige definir novo contrato de tamanho/caracteres/armazenamento; não configurar contas reais com esta função.

**Testes de laboratório necessários:** Analisar repetição e domínio sem registrar senhas reais; validar requisitos de uma futura interface e compatibilidade dos consumidores antes de substituir o retorno de6 caracteres.

### `oracle/administration/rbk_views.sql`

Definições e outer joins preservados; exemplos de teste do autor permanecem históricos, sem equivaler a homologação desta revisão.

**Pendências:** Undo manual/rollback e informações locais; não oferece topologia RAC ou histórico. CREATE OR REPLACE invalida dependentes e confirma DDL; campos de segmentos offline podem ser NULL.

**Testes de laboratório necessários:** Segmento ONLINE/OFFLINE; AUM versus manual; atributos presentes no RU alvo; valores NULL; dependentes e grants diretos.

### `oracle/administration/version.sql`

Cursor fecha em exceção e erro é propagado. Extração do banner e contrato de versão curta preservados.

**Pendências:** Banner não é inventário completo de RU/patch. Se houver várias linhas Oracle ou nenhuma, primeiro FETCH pode ser ambíguo/NULL; não escolher outra fonte e alterar contrato silenciosamente.

**Testes de laboratório necessários:** Banner19c, formatos antigos, ausência/múltiplas linhas, erro de acesso; comparação com inventário de patches em laboratório.

### `oracle/administration/count_blocks.sql`

Contagem gerada usa OBJECT/RELATIVE_FNO/BLOCK_NUMBER com delimitadores em vez do prefixo de ROWID restrito; owners/nomes citados e literal do staging escapado. Saída ordenada e arquivo dedicado count_blocks_generated.sql, executado conforme fluxo original.

**Pendências:** Continua full scan/DML automático ao executar o script. Contabiliza blocos com linhas, não HWM ou blocos alocados. Sem owner no staging, homônimos são indistinguíveis; reexecução duplica dados. TABLE não cobre partições/IOT/UROWID; contexto de BIGFILE exige laboratório.

**Testes de laboratório necessários:** Nomes com apóstrofo/aspas; mesmo número de bloco em arquivos/objetos distintos; tabela vazia; staging e permissões; custo com clone representativo; script gerado íntegro.

### `oracle/administration/fill_sz.sql`

Corpo integral dos1290 INSERTs preservado. Todas as instruções foram lidas por parser SQLGlot em dialeto Oracle e conferidas estruturalmente: alvo TEMP_SIZE_TABLE e COUNT DISTINCT com três componentes ROWID.

**Pendências:** Lista fixa de ambiente histórico; não é inventário portável. Full scans e staging sem owner/PK, com possibilidade de dados parciais/repetidos e commits do cliente. Apenas revisão estática; parsing não valida existência, case dos três nomes XDB com hífen, privilégios ou custo.

**Testes de laboratório necessários:** Validar as1290 tabelas/owners e três nomes XDB citados; IOT/UROWID; múltiplos arquivos; casos vazios; comparar contagem com fixture Oracle; nenhuma coleta massiva foi executada.

### `oracle/administration/new_dba_free.sql`

Definição interna mantida e finalidade real reforçada: extents alocados, não espaço livre.

**Pendências:** SYS.UET$ e X$KTFBUE não são interface estável; layout e interpretação de campos dependem de versão. UNION ALL pode refletir duas estratégias de gestão; não usar resultado como DBA_FREE_SPACE.

**Testes de laboratório necessários:** Verificar layout/RU, LMT/DMT, unidade LENGTH e identidade dos segmentos; comparar ao dicionário documentado em clone.

### `oracle/administration/brown.sql`

Arquivo gerado dedicado evita sobrescrever o helper index_sz.sql. ANALYZE usa owner/índice citados. Conversão USED_SPACE/bytes por bloco usa DBA_TABLESPACES do índice, não DB_BLOCK_SIZE global; metadado ausente preserva linha com NULL.

**Pendências:** DROP/CREATE/TRUNCATE e ANALYZE são destrutivos/custosos; commits do fluxo mantidos. Requer SELECT adicional DBA_TABLESPACES. Índices particionados/ausentes e nome de INDEX_STATS precisam validação. TRUNC preserva a aproximação original de bytes usados por blocos; não é tamanho real alocado nem recomendação de rebuild.

**Testes de laboratório necessários:** Dois tablespaces com blocos diferentes; nomes quoted; índice particionado; erro de ANALYZE; staging existente; arquivo gerado preexistente; parâmetros/colunas INDEX_STATS no alvo.

### `oracle/administration/explain.sql`

Wrapper e chamada @@plan.sql preservados; não executado SQL fornecido por substituição.

**Pendências:** SQL_STATEMENT é SQL livre por definição e ID também é substituição textual; somente entrada confiável. O helper PLAN pode TRUNCATE, abrir editor e confirmar transações. Não é análise isolada sem efeito no cliente.

**Testes de laboratório necessários:** Helper resolvido na pasta correta; statement_id; SQL terminador/multilinha; plano compartilhado; sessão de laboratório sem transações de aplicação.

### `oracle/objects/in_rct.sql`

Staging inclui owner e ordena por owner/índice/linha, evitando intercalar nomes homônimos; texto CLOB e buffer32767; identificadores emitidos citados sem LOWER. Todos os cursores/ramos/storage e delimitadores de geração preservados. CREATE de staging falho interrompe antes do TRUNCATE; saída inclui DEFINE OFF/SQLCASE MIXED para nomes citados.

**Pendências:** Não é exportação fiel de índices function-based, DESC, domain, particionados ou recursos modernos; staging é privado ao fluxo e sua estrutura foi ampliada. Grants DBMS_ASSERT e tamanho de saída exigem teste. Filtros OWNER/TABLE ainda são substituições SQL*Plus confiáveis. Não executar variantes simultaneamente ou aplicar a saída sem revisão.

**Testes de laboratório necessários:** Dois schemas com índice homônimo; nomes mixed/quoted; lista longa; armazenamento/partições; spool CLOB íntegro; tabela I_TEMP existente; falha no meio do fluxo.

### `oracle/objects/in_rct2.sql`

Staging inclui owner e ordena por owner/índice/linha, evitando intercalar nomes homônimos; texto CLOB e buffer32767; identificadores emitidos citados sem LOWER. Tamanho em blocos usa BLOCK_SIZE do tablespace e índice não único passa a incluir owner. Todos os cursores/ramos/storage e delimitadores de geração preservados. CREATE de staging falho interrompe antes do TRUNCATE; saída inclui DEFINE OFF/SQLCASE MIXED para nomes citados.

**Pendências:** Não é exportação fiel de índices function-based, DESC, domain, particionados ou recursos modernos; staging é privado ao fluxo e sua estrutura foi ampliada. Grants DBMS_ASSERT e tamanho de saída exigem teste. Filtros OWNER/TABLE ainda são substituições SQL*Plus confiáveis. SIZE_IT ainda está associado apenas por nome, sem contrato de owner/medida; pode multiplicar homônimos e permanece bloqueio. Não executar variantes simultaneamente ou aplicar a saída sem revisão.

**Testes de laboratório necessários:** Dois schemas com índice homônimo; nomes mixed/quoted; lista longa; armazenamento/partições; spool CLOB íntegro; tabela I_TEMP existente; falha no meio do fluxo.

### `oracle/administration/exp_ext_tab.sql`

DEFAULT DIRECTORY substitui token DEFAULT_DIRECTORY inválido; CTAS deixa de declarar tipos no cabeçalho e os mantém por CAST explícito nas sete expressões, sem SELECT *. Driver Data Pump e três nomes de arquivo originais preservados.

**Pendências:** CTAS grava binário Data Pump no servidor, apesar da extensão .txt; não é CSV. Requer DIRECTORY SQL_DIR autorizado, READ/WRITE, espaço, quota, SELECT origem e tipos/conversões válidos. CASTs podem rejeitar/truncar conforme tipo; arquivos existentes e falha de unload exigem plano de limpeza.

**Testes de laboratório necessários:** Origem com colunas em outra ordem/extras; tamanhos acima20/64; conversão de data/número; falta de grant/DIRECTORY; arquivo existente; roundtrip em clone; parallel e custo.

### `oracle/performance/explain1.sql`

Algoritmo e créditos Christian Adams preservados; não promovida subtração de custos a métrica de tempo.

**Pendências:** TRUNCATE/COMMIT e arquivo AFIEDT.BUF REPLACE afetam estado compartilhado e sessão. Custo CBO não é necessariamente aditivo e percentuais são heurísticos. Precisa das colunas customizadas e PLAN_TABLE exclusiva.

**Testes de laboratório necessários:** Plano com múltiplos filhos/custoNULL/zero; custo não aditivo; arquivo buffer existente; sessão paralela; SQL de entrada não confiável proibido; grants e colunas customizadas.

### `oracle/administration/in_siz_es.sql`

Lista de colunas passa a IN (&clist), removendo UPPER aplicado a múltiplos argumentos (inválido para exemplo com duas colunas). Entradas devem ser literais normalizados confiáveis, sem SQL arbitrário.

**Pendências:** Ainda usa substituição textual e execução automática do script gerado. A lista deve usar nomes na forma do dicionário; SQLCASE do cliente e quoted mixed exigem teste. Sem função/LOB/compressão e sem fidelidade de storage; coluna inexistente pode deixar geração incompleta.

**Testes de laboratório necessários:** Lista de uma/duas colunas uppercase; coluna desconhecida; schema/tabela quoted; entrada não confiável proibida; tabela vazia; SQLCASE e NLS; verificar saída antes de executar.

### `oracle/administration/index_size.sql`

Modelo VSIZE e cálculo por COUNT(*) preservados como estimativa legada, sem alegação de medir o índice.

**Pendências:** Contagem inclui linhas com todas as chaves NULL, que podem não existir em B-tree; overheads e compressão não são cobertos. Ordenar por COLUMN_ID não reproduz ordem das chaves. Entradas SQL*Plus e arquivo gerado são superfícies de execução; sem expressão/LOB/function-based seguro.

**Testes de laboratório necessários:** Todas as chaves NULL; chaves compostas/parcialmenteNULL; tabelas vazias; function-based; compressão; nomes mixed; definir domínio e fórmula antes de uma reimplementação física.

### `oracle/administration/index_sz.sql`

WHENEVER SQLERROR EXIT FAILURE ROLLBACK impede chegar ao TRUNCATE se CREATE falhar, protegendo uma STAT_TEMP já existente. CTAS/algoritmo e layout espelhado de INDEX_STATS preservados.

**Pendências:** INDEX_STATS representa validação na sessão e pode estar vazio/desatualizado. STAT_TEMP pode preexistir; DDL confirma transação. SELECT * segue deliberado para espelhar o layout do catálogo no staging, cuja versão precisa ser validada.

**Testes de laboratório necessários:** Sessão sem ANALYZE; INDEX_STATS populado; STAT_TEMP já existente; layout do RU; quota/storage; sem tratar sucesso do CREATE como homologação de coleta.

### `oracle/administration/legacy-linux/proc_sys_net.sh`

Barreira incondicional adicionada antes de qualquer escrita /proc ou hdparm. Comandos/valores históricos permanecem abaixo, sem tradução especulativa para kernel atual.

**Pendências:** Exige estudo e homologação de kernel/driver/disco antes de adaptar uma cópia privada; não remover bloqueio no repositório. Não há restauração/persistência de parâmetros.

**Testes de laboratório necessários:** sh -n apenas; confirmar EXIT antes das duas chamadas hdparm e das sete escritas em /proc; nenhum ajuste de SO foi executado.

### `oracle/rac/staggered_sequence_trigger.sql`

Fórmula e política de sobrescrever EMP_ID preservadas; acrescentado contraexemplo concreto de colisão.

**Pendências:** Instância1 com NEXTVAL100001 e instância2 com NEXTVAL1 resultam em100001. O offset pode destruir a unicidade de uma sequência global. Política de chaves e codificação de instância precisam de decisão; não trocar algoritmo de negócio silenciosamente.

**Testes de laboratório necessários:** Unicidade entre instâncias/faixas; CYCLE/RESTART/cache; chave fornecida pelo chamador; capacidade de EMP_ID; apenas contraexemplo aritmético local, sem trigger Oracle executado.

### Validação local do lote 038

Os 1.290 INSERTs de FILL_SZ foram integralmente analisados pelo parser SQLGlot em dialeto Oracle: todos inserem em TEMP_SIZE_TABLE, todos têm COUNT DISTINCT com OBJECT/RELATIVE_FNO/BLOCK_NUMBER e suas fontes abrangem 19 owners. O corpo original publicado foi preservado integralmente. As três referências XDB com hífen continuam citadas; parser não valida existência/case/permissão no catálogo Oracle.

Uma fixture SQLite executou o SELECT do gerador COUNT_BLOCKS, expandindo apenas macros de apresentação, e executou a instrução produzida com funções ROWID substituídas por funções locais de fixture. O caso cobriu aspas/apóstrofo/ampersand em nomes e quatro identidades de bloco com linhas repetidas, objetos e arquivos diferentes. Não equivale à implementação DBMS_ROWID ou execução no banco Oracle.

O SELECT de sete CASTs do CTAS foi analisado em dialeto Oracle. A gramática de external table foi confrontada à documentação oficial; não se declarou compilação do CREATE no Oracle nem validação completa dessa extensão pelo parser local. Fixtures adicionais conferiram ordenação do staging por owner/índice/linha, IN com várias colunas, e o contraexemplo aritmético de colisão do trigger RAC. O Shell passou somente por `sh -n`, com inspeção de EXIT antes de todas as escritas e hdparm; seu conteúdo não foi executado.

## Revisão 039 — 04/11/2026

20 scripts: cinco alterações de código e 15 revisões documentais. Commit [4c88d359890cc82a98e6ae3f1a5307a1072a3266](https://github.com/francois-fiorino/tech-automation-scripts/commit/4c88d359890cc82a98e6ae3f1a5307a1072a3266); arquivos confirmados por caminho/conteúdo/blob. Sem execução Oracle, grants, trace ou DDL administrativo. Propostas permanecem no PR #2, sem merge.

### `oracle/troubleshooting/no_trace_my_session.sql`

Corpo preservado; desabilita apenas a sessão corrente.

**Pendências:** Pode interromper diagnóstico planejado; não remove trace existente nem apaga binds já registrados.

**Homologação necessária:** Habilitar trace em sessão descartável, desabilitar e verificar ausência de novos registros.

**Blob confirmado:** `518db016f86bc33547d11cb2d53063b01406df04`.

### `oracle/troubleshooting/trace_my_session.sql`

Corpo preservado; TRUE/TRUE mantém coleta de waits e binds.

**Pendências:** Binds podem conter dados pessoais/segredos. Definir janela, quota e desativação; SID é local à instância e conexão atual.

**Homologação necessária:** Usar binds fictícios, validar arquivo/overhead e helper de desativação na mesma sessão.

**Blob confirmado:** `377c2b77b74ccf8431f86f4c9783e30c974f9a87`.

### `oracle/security/grant_rc.sql`

WRITE_OUT agora usa seus parâmetros; falhas SQL interrompem antes de reutilizar G_TEMP.

**Pendências:** SYS.OBJAUTH$ é interface interna; buffers 20/255, nomes LOWER e ordem de grantor ainda limitam fidelidade. Não adicionar senhas ao arquivo apesar da recomendação histórica.

**Homologação necessária:** G_TEMP preexistente, falha intermediária, grants em cadeia e nomes quoted; comparar grantor e ordem.

**Blob confirmado:** `a63736a78322078e1ff30fdd3b5cd1faea9dbab3`.

### `oracle/security/role_rct.sql`

Gerador histórico preservado, com bloqueio incondicional antes de consultar hashes.

**Pendências:** Exportação de PASSWORD/USER$ permanece apenas como referência histórica inacessível pelo fluxo normal. Roles modernas e autenticação externa exigem outra implementação homologada.

**Homologação necessária:** Confirmar EXIT antes de SELECT/Spool; não coletar verificadores reais.

**Blob confirmado:** `04ba30c51b25e76f26ee14c213a504efcaac961e`.

### `oracle/security/sys_gran.sql`

Trecho gerador comentado preservado, sem reativação.

**Pendências:** SPOOL OFF ativo pode fechar spool do chamador; não gera grants no estado atual. Lista exclui roles predefinidas e não representa inventário completo.

**Homologação necessária:** Inspecionar comentário e estado do cliente em sessão isolada.

**Blob confirmado:** `5f265f6b4f1c3452c95526a754d8659fcff66f12`.

### `oracle/security/sys_grnt.sql`

Trecho DBA_SYS_PRIVS permanece comentado.

**Pendências:** Nome histórico menciona roles, mas consulta privilégios de sistema. Macro GRANTEE não é validada no trecho inativo; não ativar sem revisão.

**Homologação necessária:** Verificar ausência de arquivo gerado; revisar destinatário/admin option antes de qualquer reativação.

**Blob confirmado:** `442dfdacd22724352ef65563cfc8d0e94228dc81`.

### `oracle/security/tab_grnt.sql`

Corpo preservado; sem senha embutida.

**Pendências:** Ordenação por CONNECT/grantee não resolve dependências transitivas. SQL*Plus quebra/formatos e nomes sem quoting podem invalidar saída; grants de coluna ausentes.

**Homologação necessária:** Grants encadeados, PUBLIC, nomes mixed case e largura/spool; não aplicar automaticamente.

**Blob confirmado:** `3d8044d55d3c389724165bb9c57bf8c9b4ee3a2d`.

### `oracle/administration/dba_user_privs.sql`

View histórica preservada.

**Pendências:** Roles de segundo nível e sessões com roles desabilitadas não são resolvidas; SUBSTR trunca nomes/privilégios. Não instalar no SYS nem tratar como autorização efetiva.

**Homologação necessária:** Comparar privilégios diretos, PUBLIC, role aninhada e nomes longos no mesmo container.

**Blob confirmado:** `49e58cd22f0492044266fab771a7627c27dda068`.

### `oracle/administration/display_buffer_contents.sql`

Corpo preservado; DROP de T1 e CTAS continuam explícitos.

**Pendências:** T1 homônima é destruída; falha de DROP não é seletivamente tratada. Root multitenant exige identidade CON_ID; não executar nesse contexto sem adaptação.

**Homologação necessária:** Schema descartável; comparar partições, dois arquivos e buffer não residente; verificar denominador zero.

**Blob confirmado:** `3b412642c99abaf7ffbe74941a111ad8f045c23e`.

### `oracle/administration/plan.sql`

Corpo preservado; limpeza e editor mantidos.

**Pendências:** CONNECT BY sem identidade de statement pode misturar planos; TRUNCATE remove todos e confirma transação mesmo após erro anterior. OWNER só confiável.

**Homologação necessária:** Dois planos com IDs iguais, plano vazio e falha SELECT; somente PLAN_TABLE descartável.

**Blob confirmado:** `2f8ea79157317617103c833e42073dc246c1cf13`.

### `oracle/administration/analyze_all.sql`

Corpo preservado; não substituído por DBMS_STATS silenciosamente.

**Pendências:** Macros METHOD/NUM_OF_ROWS/PERCENT_TO_USE são texto SQL e permitem injeção; START aplica análise a todos os owners não excluídos. Estatísticas/locks podem afetar planos.

**Homologação necessária:** Métodos e números confiáveis, owners adicionais internos, falha parcial e custo; laboratório isolado.

**Blob confirmado:** `e828b1fa9e45a16fa05495537eddc8ad5711a2fc`.

### `oracle/performance/big_plan.sql`

Consulta de negócio integral preservada.

**Pendências:** Tipos e objetos DIMENSION/TRN_INVENTORY_DLY_3K/DIM_SUB_LOCATION ausentes; BETWEEN textual depende do tipo/NLS e inclui só limites descritos. Não inventar conversão DATE ou mudar precedência AND/OR.

**Homologação necessária:** Fornecer DDL/dados fictícios; validar joins/cardinalidade, datas e equivalência das duas alternativas do filtro.

**Blob confirmado:** `ede654da0a7eaec69db953f41c3910627654b10e`.

### `oracle/administration/garbage_view.sql`

Heurística histórica preservada; não recomenda purge.

**Pendências:** SHARABLE_MEM e PERSISTENT_MEM podem se sobrepor; UNION produz linhas separadas GOOD/GARBAGE. Execução única não prova desperdício.

**Homologação necessária:** Usuário com ambas classes, SQL sem execução e snapshot variável; não interpretar soma como memória recuperável.

**Blob confirmado:** `2c2f0cd71b06a418219c4adf4b18439fa2c221ad`.

### `oracle/performance/sql/get_sql.sql`

Trinta chamadas históricas preservadas.

**Pendências:** SQLSTMT2 ausente: efeitos e significado dos identificadores não comprovados. Não converter para SQL_ID nem executar helper desconhecido.

**Homologação necessária:** Localizar fonte completa do helper e validar contrato antes de chamadas.

**Blob confirmado:** `6fe6755bc171624633cde8b2f1278cd2b162f965`.

### `oracle/administration/rowsize.sql`

Gerador preservado, incluindo NULLIF e ordenação.

**Pendências:** Sem colunas visíveis produz SQL incompleto; tipos LONG/LOB/objetos e nomes não escapados exigem revisão. VSIZE mais overhead fixo não é tamanho físico. START automático e caminho de saída confiável.

**Homologação necessária:** Tabela vazia, uma coluna, NULL, LOB, nomes quoted e custo de full scan em laboratório.

**Blob confirmado:** `20c2eb7c7f3888ac5d2ea740a381892d17e7b549`.

### `oracle/objects/tabhelp.sql`

Corpo preservado; corrigida afirmação documental sobre SERVEROUTPUT.

**Pendências:** UPPER não resolve quoted mixed case; comentários de colunas sem ordenação e tabela inexistente sem mensagem explícita. EXECUTE permite visualizar comentários via direitos do definidor.

**Homologação necessária:** SET SERVEROUTPUT ON; EXEC table_help('HR','EMPLOYEES'); testar tabela ausente e comentários longos.

**Blob confirmado:** `dc447683d8bbcb49c4a7cb72a3fbc83ab143ba46`.

### `oracle/objects/tab_rct.sql`

Falhas SQL interrompem o script; T_TEMP excluída do cursor de tabelas.

**Pendências:** Saída ainda tem DROP, omite precisão NUMBER/defaults/LOB/partições e usa LOWER sem quoting; não é recuperação fiel. DDL confirma transação; staging não é temporário de sessão.

**Homologação necessária:** T_TEMP existente, erro de INSERT, NUMBER(p,s) e schema pequeno descartável; nunca aplicar saída em aplicação.

**Blob confirmado:** `0878d5f3efbdb28b0fd98fa71bd0028e08d06b9e`.

### `oracle/objects/tab_scol.sql`

Colunas projetadas/agrupadas qualificadas com alias A para evitar ambiguidades com DBA_TAB_COLUMNS.

**Pendências:** INNER JOIN omite tabelas sem colunas visíveis; estatísticas podem ser NULL/desatualizadas. CREATE simples preservado; grant direto obrigatório.

**Homologação necessária:** Compilar view em laboratório; comparar duas tabelas homônimas em owners distintos, estatísticas NULL e contagem de colunas.

**Blob confirmado:** `67ceee01c1ad37bbb0ac0bab94e097c3d3138c5c`.

### `oracle/objects/trig_rct.sql`

Falhas SQL interrompem antes de reutilizar TRIG_TEMP.

**Pendências:** LONG 4000 pode truncar body, prefixo ON cabe em variável de owner limitada, WHEN sem parênteses pode ser inválido. Separador inicial / pode repetir buffer; tipos modernos não cobertos. Não usar saída como backup.

**Homologação necessária:** Staging existente, body maior que 4000, WHEN, multi-event, UPDATE OF e estado DISABLED; inspecionar cada DDL sem executá-lo automaticamente.

**Blob confirmado:** `c9598774967fb900c37f68a97af01fb3e02cd13a`.

### `oracle/administration/view.sql`

View de sete colunas mantida como variante alternativa.

**Pendências:** Arquivos sem extents livres não aparecem. Sem FSFI, incompatível com relatórios que exigem oitava coluna; offline/temp/multitenant exigem tratamento próprio.

**Homologação necessária:** Arquivo cheio, vários extents, ausência de livre e variante CREA_FS em schemas separados.

**Blob confirmado:** `477aa01d7536da6b8308b00db0e59cc9423eb211`.

### Validação local

Quatro definições CREATE VIEW (DBA_USER_PRIVS, SQL_GARBAGE, TAB_STAT_COL e FREE_SPACE) analisadas pelo parser SQLGlot em dialeto Oracle. Inspeção estática confirmou interrupção antes do CREATE de três tabelas de staging, bloqueio de ROLE_RCT antes da consulta sensível, uso dos parâmetros de WRITE_OUT e exclusão de T_TEMP do cursor. Os 15 corpos sem mudanças foram comparados integralmente com o commit anterior. Parser não valida catálogo/privilégios nem constitui compilação Oracle.

## Continuidade

Restam **97 de 177** scripts para revisão complementar, além da homologação dos 177. Acumulado: 80 revisados, 41 com código alterado e 39 revisões documentais. Nenhuma implantação homologada nesta fase. Próxima fila (040), também no JSON de verificação:

- `oracle/administration/act_size_tab.sql`
- `oracle/administration/auto_chain.sql`
- `oracle/objects/chain1.sql`
- `oracle/administration/chained.sql`
- `oracle/administration/ext_file.sql`
- `oracle/objects/get_long_length.sql`
- `oracle/administration/part_tab_all_rct.sql`
- `oracle/objects/part_tab_rct.sql`
- `oracle/objects/part_tab_test.sql`
- `oracle/administration/recomp_views.sql`
- `oracle/objects/tab_rct2.sql`
- `oracle/objects/tab_rct3.sql`
- `oracle/objects/tab_rebuild.sql`
- `oracle/administration/tab_size8.sql`
- `oracle/objects/trig_rct2.sql`
- `oracle/objects/view_rct2.sql`
- `oracle/administration/tablesp.sql`
- `oracle/backup-recovery/independent/datapump_tablespace_parameters.sql`
- `oracle/administration/tbsp_rct.sql`
- `oracle/administration/auto_defrag.sql`
