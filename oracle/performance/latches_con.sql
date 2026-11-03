/*
===============================================================================
SCRIPT: latches_con.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/latches_con.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar latches com aquisições e misses acumulados positivos.

FUNCIONAMENTO DETALHADO
  Consulta V$LATCH com GETS>0 e MISSES>0; retorna NAME, GETS, MISSES e SLEEPS, ordenando GETS decrescente.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$LATCH

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não é ranking por tempo ou taxa de contenção; GETS alto não implica gargalo. Não considera aquisições immediate na consulta. Validar deltas e tempo de espera antes de tuning.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @latches_con.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Nome e contadores acumulados de obtenção, misses e sleeps.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col name format a30 heading 'Latch Name'
col gets format 99,999,999,999 heading 'Gets'
col misses format 9,999,999,999 heading 'Misses'
col sleeps format 999,999,999 heading 'Sleeps'
set pages 55
ttitle 'Latches Contention Report'
spool latches_con.lst
select name,gets,misses,sleeps from v$latch where gets>0 and misses>0 order by gets desc
/
spool off
clear columns
ttitle off
