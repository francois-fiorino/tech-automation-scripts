/*
===============================================================================
SCRIPT: cur_open.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / misc_scripts/Cur_open.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar cursores abertos/em cache de sessões ativas com OSUSER não oracle.

FUNCIONAMENTO DETALHADO
  Une V$OPEN_CURSOR a V$SESSION por SID, filtra STATUS=ACTIVE/OSUSER e ordena LAST_CALL_ET.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$OPEN_CURSOR, V$SESSION

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  TIME não é elapsed do cursor e cursores podem estar em cache sem executar. Filtro exclui sessões com OSUSER NULL; sem SID/SERIAL# na saída. Não é auditoria de vazamento de cursores por si só.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @cur_open.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Username, prefixo de texto do cursor, endereço e TIME como LAST_CALL_ET da sessão.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta e aviso histórico de versão preservados. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
REM: Report on open cursors
REM: shows first 60 of text only
REM: Valid for 7.3 and 8.0
column username format a20 heading 'User'
column sql_text format a60  heading 'Cursor text'
column address heading 'Address'
column time heading 'Elapsed Time'
set lines 131 pages 45
ttitle 'Currently Open Cursors'
spool cur_open.lst
select s.username, c.sql_text, c.address, last_call_et time
from v$open_cursor c, v$session s
where s.status = 'ACTIVE' and
c.sid = s.sid and
s.osuser <> 'oracle'
order by time desc, c.address desc, username;
spool off
ttitle off

