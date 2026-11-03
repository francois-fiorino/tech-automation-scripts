/*
===============================================================================
SCRIPT: enqueues.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _wait_event_scripts/enqueues.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir estatísticas de enqueues e decodificar esperas legadas de locks.

FUNCIONAMENTO DETALHADO
  Lista V$SYSSTAT com CLASS=4; decodifica tipo/modo de P1 para evento enqueue; mostra V$ENQUEUE_STAT com CUM_WAIT_TIME>0.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SYSSTAT, V$SESSION_WAIT, V$ENQUEUE_STAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Evento enqueue é legado; versões modernas usam eventos enq: específicos, portanto o segundo conjunto pode ficar vazio. CLASS é máscara de bits; CLASS=4 não inclui classes combinadas. Unidades dependem das colunas e da versão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @enqueues.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Três conjuntos: estatísticas, tipo/modo das esperas e contadores de enqueue.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Divisores dos bytes de P1 corrigidos para potências de 256: 16777216 e 65536. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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

-- comment:  enqueue for sessions
ttitle 'Enqueues Report'
spool enqueues.lst
prompt Enqueues
col name format a25
col lock format a4 heading 'Lock'
col gets format 9,999,999 heading 'Gets'
col waits format 9,999,999 heading 'Waits'
col Mode format a4
SELECT *      FROM v$sysstat     WHERE class=4;

SELECT chr(bitand(p1,-16777216)/16777216)||
         chr(bitand(p1, 16711680)/65536) "Lock",
         to_char( bitand(p1, 65535) )    "Mode"
    FROM v$session_wait
   WHERE event = 'enqueue'
  
/

Prompt Enqueue Stats

select * from v$enqueue_stat where cum_wait_time>0
/
spool off
ttitle off
