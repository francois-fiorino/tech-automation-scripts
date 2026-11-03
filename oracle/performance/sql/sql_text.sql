/*
===============================================================================
SCRIPT: sql_text.sql
CATEGORIA: Oracle / performance/sql
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/sql_text.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir fragmentos de texto SQL em cache com contadores agregados da área SQL.

FUNCIONAMENTO DETALHADO
  Une V$SQLAREA e V$SQLTEXT por HASH_VALUE e ADDRESS, ordena fragmentos por ADDRESS/PIECE e mostra SORTS e USERS_EXECUTING.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SQLAREA, V$SQLTEXT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Contadores não são por fragmento nem plano de child cursor. Cache muda durante a leitura; proteger spool de textos SQL com dados sensíveis. Nomes/endereços são locais à instância. Mantidos créditos de Mike Ault.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @sql_text.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  ADDRESS, SQL_TEXT em partes, SORTS e USERS_EXECUTING repetidos nos fragmentos.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  ADDRESS acrescentado à junção por HASH_VALUE para reduzir vínculos indevidos em colisões de hash. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem sql_text.sql
rem
rem Function: Get all SQL code from shared SQL area
rem
rem Mike Ault 2/28/97 Rev 0.
rem
break on address on sorts on users_executing
set pages 55 lines 132
ttitle 'SQL Text in Shared Memory'
spool sql_text.lst
select b.address,b.sql_text,sorts,users_executing
from v$sqlarea a, v$sqltext b
where
a.hash_value=b.hash_value
and a.address=b.address
order by b.address,piece,sorts,users_executing
/
spool off
set pages 22 lines 80
pause Press enter to continue
