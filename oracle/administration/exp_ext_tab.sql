/*
===============================================================================
SCRIPT: exp_ext_tab.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _index_scripts/exp_ext_tab.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar tabela externa por unload Data Pump de tabela interna.

FUNCIONAMENTO DETALHADO
  CREATE TABLE externa com colunas fixas, DIRECTORY SQL_DIR, três locais e PARALLEL AS SELECT de SQL_SCRIPTS_INT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/alteração/execução e SELECT DIRETO conforme LIMITAÇÕES.
  Grants por role podem não valer para views/procedimentos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SQL_SCRIPTS_INT, DIRECTORY SQL_DIR; nova SQL_SCRIPTS_EXT; ORACLE_DATAPUMP

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE TABLE/quota, leitura da origem e READ/WRITE no DIRECTORY. Arquivos com extensão .txt terão formato binário Data Pump, não CSV; pode usar paralelismo e escrever no SO do servidor.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório com diretório dedicado vazio: @exp_ext_tab.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tabela externa e arquivos de unload, se driver, esquema e diretório forem compatíveis.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PROPOSTA DE REVISÃO: o código pode modificar objetos, dados, jobs,
  arquivos ou sessão, conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Driver inválido ORACLE_INTERNAL corrigido para ORACLE_DATAPUMP, que suporta CTAS externo; nomes/colunas/arquivos preservados e exigem homologação. 
  Revisão estática somente; implantação depende de testes e aprovação do PR.
  Comentários e créditos históricos preservados abaixo.

AVISO DE RESPONSABILIDADE
Os scripts são disponibilizados para fins técnicos, educacionais e administrativos.
Antes da utilização, analise integralmente o código, compreenda seu funcionamento
e realize testes em ambiente controlado, preferencialmente desenvolvimento ou
homologação. Conteúdo fornecido no estado em que se encontra (AS IS), sem garantias
de funcionamento, compatibilidade, desempenho ou adequação a ambientes específicos.
A utilização ocorre por conta e risco de quem executa. Os mantenedores não assumem
responsabilidade por danos, perdas de dados, indisponibilidade ou outros impactos
decorrentes do uso, nos limites permitidos pela legislação aplicável.
===============================================================================
*/

/*  */
 CREATE TABLE sql_scripts_ext (permissions VARCHAR2(20),
  filetype NUMBER(3),owner VARCHAR2(20),
  group_name varchar2(20), size_in_bytes number,
  date_edited date , script_name VARCHAR2(64))
 ORGANIZATION EXTERNAL
( TYPE ORACLE_DATAPUMP
  DEFAULT_DIRECTORY sql_dir
  LOCATION (sql_dir:'scripts1.txt',
            sql_dir:'scripts2.txt',
            sql_dir:'scripts3.txt'))
  PARALLEL
  AS SELECT * FROM sql_scripts_int;
