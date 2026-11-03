/*
===============================================================================
SCRIPT: sgastat.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/SGASTAT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Mostrar bytes de componentes da SGA e percentual sobre V$SGA.

FUNCIONAMENTO DETALHADO
  Soma V_$SGA.VALUE em variável cliente e divide cada linha V_$SGASTAT.BYTES pelo total.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$SGA, SYS.V_$SGASTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Views podem mudar entre consultas e não cobrem contabilidade sem sobreposição garantida. NEW_VALUE pode sofrer arredondamento do formato numérico. Não altera memória.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @sgastat.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  NAME, BYTES, PERCENT e POOL; totais do relatório.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF protege total zero; sgastat1 tem apenas diferença de formatação e será mapeado sem nova cópia. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem  Name:     sgastat.sql
rem
rem  FUNCTION: Report on the various SGA components
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
ttitle 'SGA Component Sizes Report'
spool sgastat.lst
select a.name,a.bytes,a.bytes/nullif(&divide_by,0)*100  Percent,pool
from sys.v_$sgastat a 
order by bytes desc
/
spool off
pause Press Enter to continue
clear columns
clear breaks
set pages 22 lines 80 feedback on verify on
ttitle off

