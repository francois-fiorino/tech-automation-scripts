/*
===============================================================================
SCRIPT: changed_sql.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / misc_scripts/changed_sql.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Identificar plano atual de SQL de sessão não observado no histórico AWR do mesmo banco.

FUNCIONAMENTO DETALHADO
  Relaciona SESSION e SQL por SQL_ID/child, exige histórico com plano conhecido e NOT EXISTS para plano atual no DBID corrente.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  V$SESSION, V$SQL, DBA_HIST_SQLSTAT, V$DATABASE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não prova regressão de performance nem mudança causada por parâmetro. AWR é amostrado/retido; sem período definido. Validar DBID/CON_ID no contexto multitenant.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @changed_sql.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  SID, SQL_ID, LAST_CALL_ET e PLAN_HASH_VALUE atual.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NOT EXISTS evita efeito de NULL em NOT IN; DBID restringe baseline ao banco atual. Plano atual NULL excluído e histórico não nulo continua obrigatório. 
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

select
   vs.sid,
   vs.sql_id,
   vs.last_call_et,
   sq.plan_hash_value
from
   v$session vs,
   v$sql     sq
where
   vs.sql_id=sq.sql_id 
and
   vs.sql_child_number=sq.child_number 
and sq.plan_hash_value is not null
and not exists (select 1 from dba_hist_sqlstat ss
 where ss.sql_id=sq.sql_id and ss.plan_hash_value=sq.plan_hash_value
 and ss.dbid=(select dbid from v$database))
and exists (select 1 from dba_hist_sqlstat ss
 where ss.sql_id=sq.sql_id and ss.plan_hash_value is not null
 and ss.dbid=(select dbid from v$database));
