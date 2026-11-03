/*
===============================================================================
SCRIPT: hrsumm.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / misc_scripts/hrsumm.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exportar resumo horário de hit ratios de tabela customizada.

FUNCIONAMENTO DETALHADO
  Solicita data/hora; concatena seis campos separados por vírgula de HIT_RATIOS e ordena por data/hora.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  HIT_RATIOS (tabela customizada)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DDL da tabela não acompanha este relatório. Filtro CHECK_HOUR>=hora aplica-se a todos os dias, não somente ao primeiro. NLS pode afetar mês/decimais e vírgula pode tornar exportação ambígua.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @hrsumm.sql
  -- Informar dd-mon-yy e hora inteira controlada.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Linhas data,hora,hitratio,period_hit_ratio,period_usage,users.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Comportamento do filtro preservado e explicitado; spool local em vez de diretório de aplicação fixo. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
set verify off feedback off heading off
accept start_date prompt 'Enter date (dd-mon-yy) to start listing from:'
accept start_hour prompt 'Enter hour (hh24) to start listing from:'
spool hrsumm.lst
select to_char(trunc(check_date),'dd-mon-yy')||','||to_char(check_hour)||','||to_char(hitratio)||','||to_char(period_hit_ratio)||','||to_char(period_usage)||','||to_char(users)
from hit_ratios
where check_date>=to_date('&&start_date','dd-mon-yy') and 
check_hour>=to_number(&&start_hour)
order by check_date,check_hour
/
spool off
set verify on feedback on
ttitle off

