/*
===============================================================================
SCRIPT: user_text.sql
CATEGORIA: Oracle / performance/sql
ORIGEM: Oracle Script Collection 2015 / misc_scripts/user_text.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir fragmentos do SQL associado às sessões locais.

FUNCIONAMENTO DETALHADO
  Une V$SESSION.SQL_ADDRESS/HASH_VALUE a V$SQLTEXT.ADDRESS/HASH_VALUE; ordena usuário/endereço/PIECE.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION, V$SQLTEXT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Sem filtro STATUS=ACTIVE: pode mostrar último SQL de sessão inativa. Não inclui SID ou SERIAL#; várias sessões podem repetir fragmentos. Proteger texto SQL sensível.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @user_text.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  SQL_ADDRESS, USERNAME e SQL_TEXT em partes.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Hash incluído na associação por endereço, reduzindo cruzamentos indevidos. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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

set lines 132 pages 55
break on sql_address on username
ttitle 'Active SQL Text in Shared Memory'
spool user_text.lst
select sql_address,username,sql_text
from v$session,v$sqltext
where v$session.sql_address is not null and
v$session.sql_address=v$sqltext.address
and v$session.sql_hash_value=v$sqltext.hash_value
order by username, sql_address, piece
/
spool off
set pages 22 lines 80
pause Press enter to continue
