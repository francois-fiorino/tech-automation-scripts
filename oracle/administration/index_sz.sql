/*
===============================================================================
SCRIPT: index_sz.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _index_scripts/index_sz.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar staging STAT_TEMP com a estrutura de INDEX_STATS e esvaziá-la.

FUNCIONAMENTO DETALHADO
  CTAS de INDEX_STATS com storage legado seguido de TRUNCATE TABLE STAT_TEMP.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/alteração/execução e SELECT DIRETO conforme LIMITAÇÕES.
  Grants por role podem não valer para views/procedimentos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  INDEX_STATS; nova tabela STAT_TEMP

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  INDEX_STATS representa validação na sessão e pode estar vazio/desatualizado. STAT_TEMP pode preexistir; DDL confirma transação. SELECT * segue deliberado para espelhar o layout do catálogo no staging, cuja versão precisa ser validada. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema descartável: @index_sz.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tabela staging vazia com estrutura derivada da view.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PROPOSTA DE REVISÃO: o código pode modificar objetos, dados, jobs,
  arquivos ou sessão, conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 038 (2026-11-04): WHENEVER SQLERROR EXIT FAILURE ROLLBACK impede chegar ao TRUNCATE se CREATE falhar, protegendo uma STAT_TEMP já existente. CTAS/algoritmo e layout espelhado de INDEX_STATS preservados. Casos de homologação: Sessão sem ANALYZE; INDEX_STATS populado; STAT_TEMP já existente; layout do RU; quota/storage; sem tratar sucesso do CREATE como homologação de coleta. Comentários/créditos históricos preservados. Não aprovado para implantação.

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
whenever sqlerror exit failure rollback
/*  */
create table stat_temp storage (initial 1m next 1m) as select * from index_stats
 ;                                                                              
truncate table stat_temp;                                                       
