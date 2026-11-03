/*
===============================================================================
SCRIPT: defrag_tbsp.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / misc_scripts/defrag_tbsp.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar registros customizados com defrag no nome desde ontem.

FUNCIONAMENTO DETALHADO
  Lê DBA_RUNNING_STATS com MEAS_DATE>TRUNC(SYSDATE-1) e LIKE %defrag%.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_RUNNING_STATS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não desfragmenta nem comprova benefício de operação; dados e unidade são do coletor. Janela é desde meia-noite de ontem e filtro é case-sensitive.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @defrag_tbsp.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  NAME, data e VALUE com heading Pieces.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta preservada. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
column meas_date format a17 heading 'Defrag Date'
column name format a40 heading 'Tablespace Defraged' word_wrapped
column value format 99999 heading 'Pieces'
set pages 47
ttitle 'Defragged Tablespaces Report'
spool defrag_tbsp.lst
select name,to_char(meas_date,'dd-mon-yy hh24:mi')meas_date,value 
from dba_running_stats where meas_date>trunc(sysdate-1)
and name like '%defrag%' 
/
spool off

