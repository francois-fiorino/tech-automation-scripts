/*
===============================================================================
SCRIPT: test_pool2.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / misc_scripts/test_pool2.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Comparar memória não livre do shared pool com parâmetro de tamanho configurado.

FUNCIONAMENTO DETALHADO
  Soma SGASTAT não free memory e relaciona SHARED_POOL_SIZE numérico em bytes; preserva LEAST/GREATEST das estimativas.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SGASTAT, V$PARAMETER

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  SHARED_POOL_SIZE zero sob ASMM/AMM não significa pool ausente: percentual NULL e avail proxy não refletem memória dinâmica real. Não estima capacidade recuperável nem soma total SGA. Comentário de alternativa mantido.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @test_pool2.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Shared_pool_used/size/avail em MiB e FULL_POOL_PCT relativo ao tamanho configurado.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Sintaxe b.value(1...) e DECODE %M inválidos substituídos por valor numérico normalizado da view; agregação MAX e unidades coerentes/NULLIF corrigem quatro expressões, sem retirar saídas ou comentário histórico. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
column shared_pool_used format 9,999.99
column shared_pool_size format 9,999.99
column shared_pool_avail format 9,999.99
column avail_pool_pct format 999.99
ttitle 'Shared Pool Summary'
spool test_pool2.lst
select
 least(max(to_number(b.value)),sum(a.bytes))/1048576 shared_pool_used,
 max(to_number(b.value))/1048576 shared_pool_size,
 (greatest(max(to_number(b.value)),sum(a.bytes))-sum(a.bytes))/1048576 shared_pool_avail,
 sum(a.bytes)/nullif(max(to_number(b.value)),0)*100 full_pool_pct
from v$sgastat a, v$parameter b
where a.pool='shared pool' and a.name<>'free memory'
and b.name='shared_pool_size';
rem SELECT 
rem		SUM(a.BYTES)/1048576 pool_used,
rem                max(b.value)/(1024*1024) shared_pool_size,
rem                (max(b.value)/(1024*1024))-(sum(a.bytes)/(1024*1024)) shared_pool_avail,
rem                (sum(a.bytes)/max(b.value))*100 avail_pool_pct
rem	FROM  
rem		v$sgastat a, v$parameter b 
rem	WHERE 
rem		a.name in ( 
rem		'reserved stopper',             
rem		'table definiti',                  
rem		'dictionary cache',           
rem		'library cache',              
rem		'sql area',
rem		'PL/SQL DIANA',
rem		'SEQ S.O.') and
rem                b.name='shared_pool_size';
spool off
ttitle off
