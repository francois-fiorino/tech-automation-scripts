/*
===============================================================================
SCRIPT: check_cache_latch.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/check_cache_latch.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Contar sessões em espera por evento e identificar latches no evento legado latch free.

FUNCIONAMENTO DETALHADO
  Primeira consulta agrupa sessões STATE=WAITING por EVENT; segunda relaciona P2 a V$LATCHNAME.LATCH# quando EVENT=latch free.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION_WAIT, V$LATCHNAME

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Inclui eventos Idle na primeira consulta. Em versões modernas muitos latches possuem eventos latch: específicos não cobertos pela segunda. Não mede duração.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @check_cache_latch.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Contagem por evento e contagem por nome de latch identificado.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Primeiro SPOOL redundante removido; relatório mantido em check_cache_latch.lst para não abrir dois destinos consecutivos. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem from metalink
rem
ttitle 'Cache Latches'
spool check_cache_latch.lst
select count(*), event from v$session_wait
       where state='WAITING' group by event order by 1 desc;

select count(*), name latchname from v$session_wait, v$latchname
       where event='latch free' and state='WAITING' and p2=latch#
       group by name order by 1 desc;
spool off
ttitle off
