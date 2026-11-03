/*
===============================================================================
SCRIPT: ash_file_wait_time_dy.sql
CATEGORIA: Oracle / performance/ash
ORIGEM: Oracle Script Collection 2015 / _ash_scripts/ash_file_wait_time_dy.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Agrupar amostras ASH associadas a datafiles.

FUNCIONAMENTO DETALHADO
  Une CURRENT_FILE# a DBA_DATA_FILES.FILE_ID, conta amostras e soma TIME_WAITED por nome.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  V$ACTIVE_SESSION_HISTORY, DBA_DATA_FILES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não agrupa por dia apesar de dy. Contagem não é número de I/Os/esperas; CURRENT_FILE# e tempo amostrado não garantem atribuição causal. Não cobre tempfiles; verificar CON_ID em CDB.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @ash_file_wait_time_dy.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  FILE_NAME, WAIT_NUMBER e TOTAL_TIME_WAITED, ordenados pelo nome decrescente.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta histórica mantida; limitações da métrica sinalizadas. 
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
   f.file_name file_name,
   COUNT(*)    Wait_Number,
   SUM(h.time_waited) Total_Time_Waited
from
   v$active_session_history     h,
   dba_data_files               f
where
   h.current_file# = f.file_id
group by
   f.file_name
order by f.file_name DESC
;
