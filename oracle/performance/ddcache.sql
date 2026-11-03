/*
===============================================================================
SCRIPT: ddcache.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / misc_scripts/DDCACHE.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Calcular proporção acumulada de misses do row cache.

FUNCIONAMENTO DETALHADO
  Divide SUM(GETMISSES) por SUM(GETS) de V$ROWCACHE e multiplica por 100.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$ROWCACHE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Contadores acumulados e agregação entre parâmetros de cache; não é buffer-cache hit ratio. Não inclui necessariamente misses de getmisses em outras classes de cache.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @ddcache.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  MISS_PERCENT em percentual; NULL se não há gets.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF protege soma de gets igual a zero. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Wrapper de título substituído por TTITLE local.
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
rem title:    ddcache.sql
rem FUNCTION: report on the v$rowcache table
rem HISTORY:  created sept 1995 MRA
rem
ttitle "DD Cache Hit Ratio"
spool ddcache.lst
SELECT (SUM(getmisses)/NULLIF(SUM(gets),0))*100 Miss_percent
FROM V$ROWCACHE
/
spool off
pause Press enter to continue
ttitle off
