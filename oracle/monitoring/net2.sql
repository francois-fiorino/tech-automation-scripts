/*
===============================================================================
SCRIPT: net2.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / misc_scripts/net2.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir três conjuntos de estatísticas de paralelismo e dispatchers.

FUNCIONAMENTO DETALHADO
  Consulta PQ_SYSSTAT, percentual BUSY por NETWORK e espera média de filas DISPATCHER com DECODE para zero requisições.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$PQ_SYSSTAT, V$DISPATCHER, V$QUEUE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Contadores acumulados, não throughput de rede. Shared server deve ter dados; máscaras podem limitar valores muito grandes. Variante de network.sql com conjuntos separados e percentual em vez de fração.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @net2.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Estatísticas PQ; Protocol/%Busy; Protocol/AWT por resposta em centésimos de segundo.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF protege ocupação sem atividade; máscara ampliada para representar 100% sem overflow. TO_CHAR original era sintaticamente válido. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
column protocol format a8
set embedded off
ttitle 'Network Statistics'
spool net2.lst
select statistic,to_char(value) value from sys.v_$pq_sysstat;
select network "Protocol",to_char((sum(busy)/nullif(sum(busy)+sum(idle),0))*100,'990.99999') "%Busy"
from v$dispatcher
group by network;
select network "Protocol",
decode(sum(totalq), 0, 'No Responses',
to_char(sum(wait)/sum(totalq),'99.99999')||' hundreths of seconds') "AWT/Response"
from v$queue q, v$dispatcher d
where q.type='DISPATCHER'
and q.paddr=d.paddr
group by network
/
spool off
