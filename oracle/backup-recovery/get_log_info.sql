/*
===============================================================================
SCRIPT: get_log_info.sql
CATEGORIA: Oracle / backup-recovery
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/get_log_info.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir arquivos de redo registrados na sessão LogMiner.

FUNCIONAMENTO DETALHADO
  Consulta V$LOGMNR_LOGS e apresenta identificador, caminho, tempos inicial/final e SCNs delimitadores. Não adiciona logs nem inicia mineração.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$LOGMNR_LOGS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Exige preparação LogMiner na sessão e logs disponíveis para haver resultado; acesso/roles LogMiner dependem da versão e do container. NEXT_SCN é limite superior, não campo HIGH_SCN.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @get_log_info.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  LOG_ID, FILENAME, LOW_TIME, HIGH_TIME, LOW_SCN e NEXT_SCN.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  SQL original preservado. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
COLUMN filename FORMAT A45
COLUMN low_scn  FORMAT 9999999
COLUMN high_scn FORMAT 9999999
SET LINES 132 PAGES 45
ttitle 'Log Miner Log Files'
spool get_log_info.lst
select LOG_ID,FILENAME,LOW_TIME,HIGH_TIME,LOW_SCN,NEXT_SCN
from v$logmnr_logs
/
SPOOL OFF
SET LINES 80 PAGES 22
