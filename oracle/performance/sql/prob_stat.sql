/*
===============================================================================
SCRIPT: prob_stat.sql
CATEGORIA: Oracle / performance/sql
ORIGEM: Oracle Script Collection 2015 / misc_scripts/prob_stat.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar fragmentos SQL com mais de mil gets e mais de uma execução.

FUNCIONAMENTO DETALHADO
  Une SQLAREA/SQLTEXT por hash/endereço, projeta PIECE e razão gets/exec e ordena razão crescente.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SQLAREA, V$SQLTEXT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não filtra razão >100 apesar do comentário e não garante muitas execuções: exige >1. Contadores são desde carga; não somar métricas repetidas por fragmento. ORDER BY é crescente e não top N.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @prob_stat.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Fragmentos de texto com métricas repetidas por PIECE e identificadores ocultos.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta com divisor protegido por EXECUTIONS>1 preservada; limiares reais documentados. 
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
rem 
rem examine statements that have a high ratio (>100) and many executions.   These statements may need a 
rem rewrite.  Normally, any statement requiring over 50 buffers may be a contention point.  However, this threshold 
rem depends on the application. 
rem 
rem statements with high ratios are problems if they are OLTP.  DSS statements will get high buffers gets per 
rem execution. 
spool sql_issues3 
column piece noprint 
column exec  format 9999999 
column ratio format 999999.99 
column gets  format 99999999 
column parses  format 99999999 
column text  format a32 wrap 
column hash_value noprint
column address noprint
set pagesize 9999 
rem set heading off 
set pause off 
select distinct piece, 
          b.sql_text text, 
          buffer_gets gets, 
          buffer_gets/executions "ratio", 
          executions exec, 
          parse_calls parses,
	  a.hash_value,
	  a.address
from v$sqlarea a, v$sqltext b 
where executions > 1 
  and a.hash_value = b.hash_value 
  and a.address = b.address 
  and buffer_gets> 1000 
order by 4, a.hash_value, a.address, piece; 
spool off 
