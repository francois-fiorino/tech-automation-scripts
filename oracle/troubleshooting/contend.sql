/*
===============================================================================
SCRIPT: contend.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / misc_scripts/CONTEND.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Agrupar esperas acumuladas de blocos por classe.

FUNCIONAMENTO DETALHADO
  Consulta WAITSTAT com COUNT>0, soma contagens/tempos e calcula média por classe.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$WAITSTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não identifica arquivo/bloco/sessão ou evento preciso. Contadores são acumulados; métricas dependem de instrumentação. Filtro positivo já impede divisor zero.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @contend.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  CLASS, TOTAL_WAITS, TOTAL_TIME e média em centésimos de segundo por espera.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  DEFINE OUTPUT direcionado a contend.lst; cálculo preservado. Título convertido em TTITLE local.
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
REM CONTEND.SQL 
REM FUNCTION: SHOWS WHERE POSSIBLE CONTENTION FOR RESOURCES 
REM           IN BUFFER BUSY WAITS USE TO PINPOINT ADDITIONAL 
REM           TUNING AREAS. 
REM 
REM CALLED FROM STATUS 
REM
col avg_wait format a10 
SET VERIFY OFF FEEDBACK OFF  
SET PAGES 58 
SET LINES 79 
ttitle "AREA OF CONTENTION REPORT"
define output = contend.lst
SPOOL &OUTPUT 
SELECT CLASS,SUM(COUNT) TOTAL_WAITS, sum(time) TOTAL_TIME, 
to_char(sum(time)/sum(count),'9,999.999') avg_wait
FROM V$WAITSTAT where count>0
group by class; 
SPOOL OFF 
PAUSE PRESS RETURN TO CONTINUE 
set verify on feedback on pages 22 lines 80
ttitle off
