/*
===============================================================================
SCRIPT: poolstat.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/poolSTAT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Distribuir bytes ocupados e livres dos componentes SGA.

FUNCIONAMENTO DETALHADO
  Obtém denominador não livre de SGASTAT, agrega por pool e acrescenta ramos de memória livre com percentual fixo zero.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$SGASTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  NULL pool é rotulado db_block_buffers historicamente, embora possa incluir outros componentes. Percentual não é ocupação de cada pool; free não compõe denominador.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @poolstat.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Pool, bytes e percentual do total não livre; Free Memory possui percentual zero por convenção do código.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF protege total não livre zero; rotulagem histórica descrita sem recomendar redimensionamento. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
select sum(bytes) sum_bytes from sys.v_$sgastat
where name != 'free memory';
ttitle 'SGA Component Pools Report'
spool poolstat.lst
select decode(pool,'','db_block_buffers',pool) pool,
sum(a.bytes) bytes,sum(a.bytes)/nullif(&divide_by,0)*100  Percent
from sys.v_$sgastat a 
where a.name !='free memory'
group by decode(pool,'','db_block_buffers',pool)
union
select 'Free Memory '||pool,sum(bytes),0 
from sys.v_$sgastat a 
where a.name ='free memory'
group  by 'Free Memory '||pool
order by bytes desc
/
spool off
pause Press Enter to continue
clear columns
clear breaks
set pages 22 lines 80 feedback on verify on
ttitle off

