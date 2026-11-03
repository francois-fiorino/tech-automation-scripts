/*
===============================================================================
SCRIPT: pool_size_stat.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/pool_size_stat.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar componentes do shared pool como porcentagem da SGA inteira.

FUNCIONAMENTO DETALHADO
  Obtém SUM(V_$SGA.VALUE), consulta SGASTAT com POOL=shared pool e calcula percentual.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$SGA, SYS.V_$SGASTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Denominador é SGA total, não total do shared pool; percentuais não devem somar 100. Inclui free memory quando presente. Não representa memória de cada sessão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @pool_size_stat.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Nome, bytes, PERCENT e pool, ordenados por bytes.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF no total; fórmula/escopo preservados. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem  Name:     poolstat.sql
rem
rem  FUNCTION: Report on the various shared pool components
rem            and their sizes
rem
rem
column sum_bytes new_value divide_by noprint
column percent format 999.99999
column bytes format 999,999,999,999
col pool heading 'Pool'
set pages 60 lines 80 feedback off verify off
break on report
compute sum of bytes on report
compute sum of percent on report
select sum(value) sum_bytes from sys.v_$sga;
ttitle 'Shared Pool Component Sizes Report'
spool pool_size_stat.lst
select a.name,a.bytes,a.bytes/nullif(&divide_by,0)*100  Percent,pool
from sys.v_$sgastat a 
Where pool='shared pool'
order by bytes desc
/
spool off
pause Press Enter to continue
clear columns
clear breaks
set pages 22 lines 80 feedback on verify on
ttitle off

