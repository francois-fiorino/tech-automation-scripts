/*
===============================================================================
SCRIPT: latch_contention.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/latch_contention.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar proporções históricas de sleeps e misses de aquisição de latch.

FUNCIONAMENTO DETALHADO
  Une V$LATCHNAME e V$LATCH por LATCH# e filtra SLEEPS>0; calcula 100*SLEEPS/GETS e 100*IMMEDIATE_MISSES/(IMMEDIATE_MISSES+IMMEDIATE_GETS).

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$LATCHNAME, V$LATCH

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  SLEEPS/GETS não é taxa de misses e pode ultrapassar 100. Contadores acumulados; latchs podem variar por versão. Não sustenta ajuste de spin sem diagnóstico.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @latch_contention.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  NAME, RATIO1 e RATIO2 em escala percentual conforme fórmulas, ordenados por RATIO1.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  GETS protegido por NULLIF; DECODE incompleto do denominador imediato substituído por NULLIF para preservar valor não zero e retornar NULL em zero. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Wrapper de título com aspas duplas substituído por TTITLE local.
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
REM

REM comment: Genereate latch contention report
REM USE         : From SQLPlus or other front end
REM Limitations : None
rem
COLUMN NAME   FORMAT A35
COLUMN RATIO1  FORMAT 999.9999
COLUMN RATIO2  FORMAT 999.9999
SET PAGES 58 NEWPAGE 0
ttitle "LATCH CONTENTION REPORT"
spool latch_contention.lst
SELECT A.NAME,100.*B.SLEEPS/nullif(B.getS,0) RATIO1,
100.*b.immediate_misses/nullif(b.immediate_misses+b.immediate_gets,0) ratio2 FROM
V$LATCHNAME A, V$LATCH B WHERE
A.LATCH# = B.LATCH# AND B.SLEEPS > 0
order by 2 desc;
SPOOL OFF
PAUSE PRESS RETURN TO CONTINUE
clear columns
ttitle off
set pages 22
