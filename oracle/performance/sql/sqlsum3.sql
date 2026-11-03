/*
===============================================================================
SCRIPT: sqlsum3.sql
CATEGORIA: Oracle / performance/sql
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/SQLSUM3.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Agregar memória de SQLAREA por usuário sem view intermediária.

FUNCIONAMENTO DETALHADO
  Inline view associa PARSING_USER_ID a DBA_USERS, seguida de somas e contagem por username.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$SQLAREA, DBA_USERS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  SHARABLE/PERSISTENT/RUNTIME têm semânticas próprias e podem sobrepor conceitos; MEM_SUM não garante memória física única. SQLAREA agrega children e é volátil.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @sqlsum3.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Usuário, três categorias de bytes, áreas e soma aritmética dos campos.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código integral preservado; nome de spool específico evita colisão com variante SQLSUM. 
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
rem FUNCTION: Generate a summary of SQL Area Memory Usage
rem FUNCTION: uses the sqlsummary view.
rem           showing user SQL memory usage 
rem
rem sqlsum.sql 
rem
column areas                                    heading Used|Areas
column sharable         format 999,999,999      heading Shared|Bytes
column persistent       format 999,999,999      heading Persistent|Bytes
column runtime          format 999,999,999      heading Runtime|Bytes
column username                                 heading "User" format a15
column mem_sum		format 999,999,999	heading Mem|Sum
ttitle "Users SQL Area Memory Use"
spool sqlsum3.lst
set pages 59 lines 80 
break on report 
compute sum of sharable on report
compute sum of persistent on report
compute sum of runtime on report
compute sum of mem_sum on report
compute sum of areas on report
select username, sum(sharable_mem) Sharable, sum( persistent_mem) Persistent, 
sum( runtime_mem) Runtime , count(*) Areas,
sum(sharable_mem+persistent_mem+runtime_mem) Mem_sum
from (select username, sharable_mem, persistent_mem, runtime_mem
from sys.v_$sqlarea a, dba_users b
where a.parsing_user_id = b.user_id)  
group by username
order by 5 desc;
spool off
pause Press enter to continue
clear columns
clear breaks
set pages 22 lines 80
ttitle off
