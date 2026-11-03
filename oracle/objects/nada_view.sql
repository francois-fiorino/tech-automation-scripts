/*
===============================================================================
SCRIPT: nada_view.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/nada_view.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar tabelas de teste e views de resumo de interações/contatos.

FUNCIONAMENTO DETALHADO
  DROP/CREATE TEST/TEST2 e CREATE OR REPLACE SUMMARIZE_INTERACTIONS/NADA; UNION traduz códigos e agrega tabelas DBO.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS de criação/execução/consulta e permissões administrativas
  conforme limitações; não instalar variantes sobre objetos de trabalho.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  TEST, TEST2, DBO.BBS_INTERACTION_LOG, DBO.USERS, SUMMARIZE_INTERACTIONS, NADA

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DROP destrutivo e DDL confirma transações. Campos TOTAL_HITS misturam estado CHAR e contagens convertidas a texto; unidades não são uniformes. Sem coleta/população de TEST/TEST2 aqui. Grants diretos e recursos para agregação necessários.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente clone com tabelas TEST descartáveis e schemas de aplicação compatíveis.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tabelas/views criadas; consultas posteriores a NADA unem métricas de tipos distintos.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: DDL/DML, staging, autenticação ou efeitos da saída
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código completo preservado; nome NADA não implica ausência de efeitos. 
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
drop table test;
create table test
( COUNT_OF_HITS                            NUMBER,
 STATE                                    CHAR(2),
 ACCESS_DATE                              DATE,
 SUM_TYPE                                 CHAR(3))
storage(initial 1m next 1m pctincrease 0);

drop table test2;
create table test2
( DISTINCT_HITS                            NUMBER,
 TOTAL_HITS                               NUMBER,
 ACCESS_DATE                              DATE,
 TOTAL_TYPE                               CHAR(3))
storage (initial 500k next 500k pctincrease 0);

rem Code for view: SUMMARIZE_INTERACTIONS
CREATE OR REPLACE VIEW SUMMARIZE_INTERACTIONS as
select docid,trunc(creation_ts) action_date from dbo.bbs_interaction_log;

create or replace view nada as
select 
decode(sum_type,'CD ','CNET Distinct',
                'CT ','CNET Total',
                'WD ','Web Distinct',
                'WT ','Web Total',
                'NDD','Web Distinct Daily',
                'NTD','Net Total Daily',
                'NDM','Net Distinct Monthly',
                'NTM','Net Total Monthly',
                'NSD','Net Summary Daily',
                'NSM','Net Summary Monthly',
                'WSM','Web Distinct Monthly',
                'CSD','CNET Distinct Daily',
                'WSD','Web Summary Daily',
                'CSM','CNET Distinct Monthly',
                sum_type) name,
 COUNT_OF_HITS value,  
 STATE total_hits, 
 ACCESS_DATE check_date from test
union
select
decode(total_type,'CD ','CNET Distinct',
                'CT ','CNET Total',
                'WD ','Web Distinct',
                'WT ','Web Total',
                'NDD','Web Distinct Daily',
                'NTD','Net Total Daily',
                'NDM','Net Distinct Monthly',
                'NTM','Net Total Monthly',
                'NSD','Net Summary Daily',
                'NSM','Net Summary Monthly',
                'WSM','Web Distinct Monthly',
                'CSD','CNET Distinct Daily',
                'WSD','Web Summary Daily',
                'CSM','CNET Distinct Monthly',
                total_type) name,
 DISTINCT_HITS value, 
 to_char(TOTAL_HITS) total_hits, 
 ACCESS_DATE check_date from test2
union
select 
  'INTERACTIONS(total)' name,
  count(*) value, 
  '  ' total_hits,
  action_date check_date from summarize_interactions
group by action_date
union
select 
  'CONTACTS(total)' name,
  count(*) value,
  '  ' total_hits, 
  trunc(creation_ts) check_date from dbo.users
where site_id>1
group by trunc(creation_ts)
/
