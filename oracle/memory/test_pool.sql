/*
===============================================================================
SCRIPT: test_pool.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/test_pool.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Resumir memória usada/livre e preenchimento do shared pool atual.

FUNCIONAMENTO DETALHADO
  Soma memória não free em SGASTAT e compara com soma atual de todas as linhas shared pool; mantém LEAST/GREATEST da fórmula histórica.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SGASTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Leituras separadas do cache não são atômicas; valores podem mudar durante cálculo. FREE/USED são categorias da view, não espaço garantido para toda alocação.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @test_pool.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  SHARED_POOL_USED/SIZE/AVAIL em MiB e FILLED_POOL_PCT.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Parâmetro SHARED_POOL_SIZE, que pode ser zero sob ASMM, substituído por tamanho observado em SGASTAT; NULLIF protege total zero. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem test_pool.sql
-- comment: Produces one line report showing fill status for shared pool
rem
rem Mike Ault Burleson Consulting
rem
column shared_pool_used format 9,999.99
column shared_pool_size format 9,999.99
column shared_pool_avail format 9,999.99
column avail_pool_pct format 999.99
ttitle 'Shared Pool Summary'
spool test_pool.lst
 select 
  least(max(b.value)/(1024*1024),sum(a.bytes)/(1024*1024)) shared_pool_used, 
  max(b.value)/(1024*1024) shared_pool_size,
  greatest(max(b.value)/(1024*1024),sum(a.bytes)/(1024*1024))-(sum(a.bytes)/(1024*1024)) shared_pool_avail,
  ((sum(a.bytes)/(1024*1024))/nullif(max(b.value)/(1024*1024),0))*100 filled_pool_pct
   from v$sgastat a,
 (select sum(bytes) value from v$sgastat where pool='shared pool') b 
 where (a.pool='shared pool'
 and a.name not in ('free memory'))
;
spool off
ttitle off
