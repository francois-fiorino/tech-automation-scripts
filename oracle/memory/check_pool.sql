/*
===============================================================================
SCRIPT: check_pool.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/check_pool.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Executar sequência de três relatórios de shared pool da coleção.

FUNCIONAMENTO DETALHADO
  Limpa formatação e chama TEST_POOL, SQL_GARBAGE3 e REUSE_SQL2 com caminhos relativos ao próprio arquivo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  oracle/memory/test_pool.sql, oracle/performance/sql/sql_garbage3.sql, oracle/performance/sql/reuse_sql2.sql

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Exige arquivos distribuídos na estrutura do repositório, privilégios de cada helper e terminal interativo. Não é avaliação automática de saúde nem altera pool; preserva PAUSEs e efeitos de settings dos helpers.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @check_pool.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Três relatórios sequenciais com suas métricas e limitações.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  @ sem extensão/SQLPATH trocado por @@ com extensão e caminhos relativos verificados na main; créditos Mike Ault preservados. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
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
REM Check_pool.sql
REM Mike Ault   Burleson Consulting  6/26 
REM FUNCTION: This script runs several SQL scripts that
REM FUNCTION: check on the health of the shared pool
clear columns
clear computes
ttitle off
@@test_pool.sql
clear columns
clear computes
ttitle off
@@../performance/sql/sql_garbage3.sql
ttitle off
clear columns
clear computes
@@../performance/sql/reuse_sql2.sql
ttitle off
clear columns
clear computes


