/*
===============================================================================
SCRIPT: explain.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _index_scripts/EXPLAIN.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Obter plano estimado de instrução controlada e chamar relatório PLAN.

FUNCIONAMENTO DETALHADO
  EXPLAIN PLAN SET STATEMENT_ID grava PLAN_TABLE; helper PLAN exibe, trunca tabela e abre editor conforme proposta no PR.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  PLAN_TABLE, instrução SQL informada, PLAN.SQL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  SQL_STATEMENT é SQL livre por definição e ID também é substituição textual; somente entrada confiável. O helper PLAN pode TRUNCATE, abrir editor e confirmar transações. Não é análise isolada sem efeito no cliente. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Somente PLAN_TABLE descartável: definir owner/id/sql_statement e revisar helpers antes.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Plano estimado e efeitos posteriores do helper.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  conforme descritos. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 038 (2026-11-04): Wrapper e chamada @@plan.sql preservados; não executado SQL fornecido por substituição. Casos de homologação: Helper resolvido na pasta correta; statement_id; SQL terminador/multilinha; plano compartilhado; sessão de laboratório sem transações de aplicação. Comentários/créditos históricos preservados. Não aprovado para implantação.

AVISO DE RESPONSABILIDADE
AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de
qualquer utilização em produção. Sua execução é de responsabilidade do
profissional responsável pelo ambiente. Os mantenedores deste repositório não
se responsabilizam por indisponibilidade, perda de dados, alterações indevidas
ou outros impactos decorrentes de sua utilização.

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
explain plan set statement_id ='&id'
for &sql_statement
/
@@plan.sql

