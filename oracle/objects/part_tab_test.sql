/*
===============================================================================
SCRIPT: part_tab_test.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/part_tab_test.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar tabela teste com partições range e subpartições hash de 2001.

FUNCIONAMENTO DETALHADO
  DROP STORE_TABLE e CREATE com quatro ranges, default quatro hash subpartitions e duas explícitas em Q3.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  STORE_TABLE, tablespaces DBAUTIL_DATA/DBAUTIL_INDEX

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DROP destrutivo, CREATE TABLE/quota/compatibilidade de particionamento e licenciamento. Sem MAXVALUE, datas além do último limite falham. Q3 tem duas subpartições explícitas apesar do default quatro. Nomes de tablespace são exemplos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema descartável e recursos licenciados/autorizados: revisar arquivo.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tabela composta criada, sem dados.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  conforme descritos. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Datas TO_DATE com mês textual trocadas por literais DATE ISO para não depender de NLS; estrutura e storage mantidos. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 040 — 04/11/2026
  Correções e melhorias: DDL de teste preservado.
  Limitações e pendências: DROP destrutivo e partições limitadas a datas anteriores a 2002; Q3 tem duas subpartições explícitas. Tablespaces distintos e licenciamento dependem do ambiente.
  Homologação necessária: Datas exatamente em cada limite, NULL/MAXVALUE ausente, duas subpartições Q3 e distribuição hash; schema descartável.
  Parâmetros e execução: contrato detalhado acima e no corpo; somente laboratório.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  sem Windows, exportação, job ou comando administrativo executado.

AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de qualquer utilização em produção. Sua execução é de responsabilidade do profissional responsável pelo ambiente. Os mantenedores deste repositório não se responsabilizam por indisponibilidade, perda de dados, alterações indevidas ou outros impactos decorrentes de sua utilização.

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
drop table store_table;
create table store_table 
(data_item INTEGER, length_of_item INTEGER, 
storage_type VARCHAR2(30), owning_dept NUMBER, storage_date DATE)
 partition by range (storage_date)
 subpartition by hash (data_item)
 subpartitions 4
 store in (dbautil_data)
 (partition q1_2001 values less than (DATE '2001-04-01')
  storage (initial 100k next 100k pctincrease 0),
 partition q2_2001 values less than (DATE '2001-07-01')
  storage (initial 200k next 200k pctincrease 0),
 partition q3_2001 values less than (DATE '2001-10-01')
  storage (initial 150k next 150k pctincrease 0)
   (subpartition q3_2001_s1 TABLESPACE dbautil_index,
   subpartition q3_2001_s2 TABLESPACE dbautil_index),
 partition q4_2001 values less than (DATE '2002-01-01')
  storage (initial 50k next 50k pctincrease 0));
