/*
===============================================================================
SCRIPT: metric_summary.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/metric_summary.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar resumos de métricas de sistema para snapshot e instância informados.

FUNCIONAMENTO DETALHADO
  Filtra DBA_HIST_SYSMETRIC_SUMMARY por SNAP_ID, DBID e INSTANCE_NUMBER e retorna nome, unidade, mínimo, máximo e média.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_SYSMETRIC_SUMMARY

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Oracle 10g+. Ausência de linhas pode indicar falta de retenção/coleta. Estatísticas são resumos armazenados, não valores atuais.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE pEndSnap = 101
  DEFINE pDbId = 123456789
  DEFINE pInstNum = 1
  @metric_summary.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Metric Name, Metric Unit, Minimum Value, Maximum Value e Average Value; unidade varia conforme métrica.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Aspas tipográficas inválidas substituídas por aspas duplas SQL e acrescentado terminador. 
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
  metric_name "Metric Name",
  metric_unit "Metric Unit",
  minval "Minimum Value",
  maxval "Maximum Value",
  average "Average Value"
from
  DBA_HIST_SYSMETRIC_SUMMARY
where
       snap_id           = &pEndSnap
   and dbid              = &pDbId
   and instance_number   = &pInstNum;
