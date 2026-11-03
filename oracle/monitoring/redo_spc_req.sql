/*
===============================================================================
SCRIPT: redo_spc_req.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / misc_scripts/redo_spc_req.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exportar histórico customizado de redo log space requests.

FUNCIONAMENTO DETALHADO
  Filtra DBA_RUNNING_STATS pelo nome e data posterior ao dia informado, ordena e emite campos concatenados.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_RUNNING_STATS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não é número de log switches nem taxa de geração de redo; interpretar conforme coletor. Corte diário exclui o dia e saída textual depende de NLS.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE dd_mon_yy = 03-NOV-26
  @redo_spc_req.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Nome, valor, delta e data.

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
set pages 0 lines 80 heading off feedback off verify off
ttitle ''
ttitle off
set pages 0 lines 80 heading off feedback off verify off
spool redo_spc_req.lst
select 
name||','||to_char(value)||','||to_char(delta)||','||to_char(meas_date,'dd-mon-yy hh24:mi')
from dba_running_stats where name ='redo log space requests' 
and trunc(meas_date)>to_date('&dd_mon_yy','dd-mon-yy')
order by meas_date
/
spool off
