/*
===============================================================================
SCRIPT: sys_events.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / misc_scripts/sys_events.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar tempo acumulado de eventos com esperas sem timeout.

FUNCIONAMENTO DETALHADO
  Filtra SYSTEM_EVENT por padrões textuais, mostra waits-total_timeouts e tempo/média pelo total de waits.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SYSTEM_EVENT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  TIME_WAITED inclui tempo de esperas com timeout; coluna WAITS exclui timeouts e não é divisor da média corrigida. Filtros não equivalem à classe Idle; não são métricas de intervalo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @sys_events.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Evento, esperas sem timeout, média em centésimos de segundo por espera total e TIME_WAITED.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Média passou a usar TOTAL_WAITS com NULLIF, coerente com tempo total; heading alterado para unidade. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col event format a30 heading 'Event Name'
col waits format 999,999,999 heading 'Total|Waits'
col average_wait format 999,999,999 heading 'Avg Wait|centisec'
col time_waited format 999,999,999 heading 'Time Waited'
ttitle 'System Events'
spool sys_events.lst
select event, total_waits-total_timeouts waits,
time_waited/nullif(total_waits,0) average_wait,
time_waited
from v$system_event  
where total_waits-total_timeouts>0
	and event not like 'SQL*Net%'
	and event not like 'smon%'
	and event not like 'pmon%'
	and event not like 'rdbms%'
	and event not like '%control%'
	and event not like 'LGWR%'
        and event not like 'PX%'
order by time_waited desc
/
spool off
clear columns
ttitle off
