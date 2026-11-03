/*
===============================================================================
SCRIPT: ash_event_count.sql
CATEGORIA: Oracle / performance/ash
ORIGEM: Oracle Script Collection 2015 / _ash_scripts/ash_event_count.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Contar amostras históricas por SQL_ID para SQLs em cache cujo texto contém orders.

FUNCIONAMENTO DETALHADO
  Filtra DBA_HIST_ACTIVE_SESS_HISTORY com EXISTS em V$SQL e SQL_FULLTEXT LIKE %orders%, agrupa SQL_ID e exige mais de uma amostra.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_ACTIVE_SESS_HISTORY, V$SQL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Filtro case-sensitive e depende do cache atual. Histórico pode conter DBIDs/containers diferentes; não restringe período. Ausência em cache exclui SQL.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @ash_event_count.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  SQL_ID e quantidade de amostras, decrescente; não número de execuções/esperas.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  EXISTS evita multiplicar amostras quando V$SQL tem vários child cursors para o mesmo SQL_ID. 
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
   h.sql_id,
   count(*)
from
   dba_hist_active_sess_history h
where
   exists (select 1 from v$sql s where s.sql_id=h.sql_id
           and s.sql_fulltext like '%orders%')
having 
   count(*) > 1
group by
   h.sql_id
order by 
   2 DESC
;
