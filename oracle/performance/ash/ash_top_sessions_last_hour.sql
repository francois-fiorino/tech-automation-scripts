/*
===============================================================================
SCRIPT: ash_top_sessions_last_hour.sql
CATEGORIA: Oracle / performance/ash
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/ash_top_sessions_last_hour.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Classificar cinco identidades de sessão por amostras ativas na última hora.

FUNCIONAMENTO DETALHADO
  Agrupa GV$ASH por INST_ID/SID/SERIAL#, exclui background e calcula contagem/participação.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  GV$ACTIVE_SESSION_HISTORY

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não mede DB time exato ou execuções. Retenção/CPU sampling e containers limitam interpretação; identidade deve incluir container quando aplicável.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @ash_top_sessions_last_hour.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  INST:SID:SERIAL, SAMPLE_COUNT e PCT_ACTIVITY.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Janela de 60 segundos corrigida para uma hora; INST_ID impede unir sessões homônimas entre nós; alias de contagem esclarecido. 
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
     inst_id||':'||session_id||':'||session_serial# as "INST:SID:SERIAL",
     count(*) as sample_count,
     round(count(*)*100/sum(count(*)) over (), 2) as pct_activity
  from
     gv$active_session_history
  where
     sample_time >= sysdate - 1/24
     and session_type <> 'BACKGROUND'
  group by 
     inst_id||':'||session_id||':'||session_serial#
  order by 
     count(*) desc)
where
  rownum <=5;
