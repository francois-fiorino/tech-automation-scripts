/*
===============================================================================
SCRIPT: top_sql_waits.sql
CATEGORIA: Oracle / performance/ash
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/top_sql_waits.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relacionar soma histórica de campos ASH a usuário e texto SQL ainda em cache.

FUNCIONAMENTO DETALHADO
  Filtra V$ACTIVE_SESSION_HISTORY por últimas 24h disponíveis, une SQL_ID a V$SQLAREA e USER_ID a DBA_USERS e soma WAIT_TIME+TIME_WAITED por usuário/texto.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  V$ACTIVE_SESSION_HISTORY, V$SQLAREA, DBA_USERS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Soma de WAIT_TIME/TIME_WAITED amostrados não é duração total confiável de espera. Retenção pode ser menor que 24h e INNER JOIN elimina SQLs fora do cache. Agrupamento por prefixo SQL_TEXT pode unir SQL_IDs diferentes. Não mede AAS ou DB Time.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @top_sql_waits.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  USER_ID, USERNAME, SQL_TEXT e WAIT_TIME segundo expressão histórica; ordenação crescente, não top-N.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Fórmula original mantida com ressalva técnica explícita; redefinir métrica requer homologação, sem substituir por versão simplificada. 
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
select 
   ash.user_id,
   u.username,
   sqla.sql_text,
   sum(ash.wait_time + ash.time_waited) wait_time
from 
   v$active_session_history ash,
   v$sqlarea                sqla,
   dba_users                u 
where 
   ash.sample_time > sysdate-1
and 
   ash.sql_id = sqla.sql_id
and 
   ash.user_id = u.user_id
group by 
   ash.user_id,
   sqla.sql_text, 
   u.username
order by 4;
