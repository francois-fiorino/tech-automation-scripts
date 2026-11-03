/*
===============================================================================
SCRIPT: wait.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / _wait_event_scripts/wait.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar espera em filas de dispatcher e proporção acumulada de atividade.

FUNCIONAMENTO DETALHADO
  Agrupa V$QUEUE TYPE=DISPATCHER por NETWORK após associação PADDR; divide SUM(WAIT) por SUM(TOTALQ). Outra consulta calcula BUSY/(BUSY+IDLE)*100 por rede.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$QUEUE, V$DISPATCHER

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Shared server/dispatchers devem estar configurados. Contadores acumulados; não mede ocupação instantânea nem CPU do host.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @wait.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Média em centésimos de segundo e percentual Busy Rate; razões NULL quando não houve atividade/requisições.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF nos denominadores de requisições e ocupação evita ORA-01476. 
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
column network format a10
column (sum(busy)/nullif(sum(busy)+sum(idle),0))*100 heading 'Busy Rate' format 999.99
column "Average Wait " format 9.99999999
select network, decode (sum(totalq),0,'No responses'),
sum(wait)/nullif(sum(totalq),0) ||' 100ths secs' "Average Wait "
from v$queue q, v$dispatcher d
where q.type='DISPATCHER' and q.paddr=d.paddr
group by network
/
select network, (sum(busy)/nullif(sum(busy)+sum(idle),0))*100
from v$dispatcher
group by network
/
