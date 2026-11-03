/*
===============================================================================
SCRIPT: log_mnr_rpt.sql
CATEGORIA: Oracle / backup-recovery
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/log_mnr_rpt.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar arquivos de redo disponíveis no contexto LogMiner com identificação do banco.

FUNCIONAMENTO DETALHADO
  Seleciona DB_ID, LOG_ID, nome, faixa de tempo e faixa de SCN em V$LOGMNR_LOGS; ordena pela data original LOW_TIME.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$LOGMNR_LOGS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  View depende da sessão LogMiner e de sua preparação. Não inicia mineração nem garante cobertura contínua dos SCNs. Permissões variam por versão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @log_mnr_rpt.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  DB_ID, LOG_ID, FILENAME, LOW_TIME/HIGH_TIME e LOW_SCN/NEXT_SCN.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  HH trocado por HH24; ORDER BY qualificado com alias L para ordenar DATE real, evitando ordem lexicográfica do texto formatado. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
COLUMN log_id FORMAT 999999
COLUMN filename FORMAT A20
COLUMN low_scn  FORMAT 9999999
COLUMN high_scn FORMAT 9999999
SET LINES 132 PAGES 45
ttitle 'Log Miner Log Files'
spool log_mnr_rpt.lst
SELECT     
   db_id,
   log_id,filename,
   to_char(low_time,'dd-mon-yy hh24:mi:ss') low_time,
   to_char(high_time,'dd-mon-yy hh24:mi:ss') high_time,
   low_scn,next_scn
FROM 
   v$logmnr_logs l
ORDER BY 
   l.low_time
/
SPOOL OFF
SET LINES 80 PAGES 22
