/*
===============================================================================
SCRIPT: ash_top_sql_last_hour.sql
CATEGORIA: Oracle / performance/ash
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/ash_top_sql_last_hour.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Classificar cinco SQL_IDs pela quantidade de amostras ativas na última hora.

FUNCIONAMENTO DETALHADO
  Consulta GV$ACTIVE_SESSION_HISTORY com janela SYSDATE-1/24, exclui BACKGROUND, agrupa SQL_ID e calcula participação nas amostras.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  GV$ACTIVE_SESSION_HISTORY

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Retenção pode ser menor que uma hora; amostras não são duração exata nem número de execuções. Soma instâncias, sem filtro de container; leitura pode ser custosa.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @ash_top_sql_last_hour.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  SQL_ID, SAMPLE_COUNT e PCT_ACTIVITY; pode conter SQL_ID NULL.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Janela original de 60 segundos corrigida para uma hora conforme finalidade do nome; alias DB_TIME trocado por SAMPLE_COUNT para evitar falsa unidade. 
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
   *
from (
   select
      sql_id,
      count(*) as sample_count,
      round(count(*)*100/sum(count(*)) over (), 2) as pct_activity
   from
      gv$active_session_history
   where
      sample_time >= sysdate - 1/24
      and session_type <> 'BACKGROUND'
   group by 
      sql_id
   order by 
      count(*) desc)
where
   rownum <=5;
