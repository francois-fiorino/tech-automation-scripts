/*
===============================================================================
SCRIPT: transactions.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / misc_scripts/transactions.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relacionar transações/sessões/locks DML ao primeiro fragmento SQL disponível.

FUNCIONAMENTO DETALHADO
  Une SESSION/TRANSACTION/ROLLNAME/PROCESS/SQLTEXT/DML_LOCKS, restringe PIECE=0 e identifica texto por endereço/hash.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION, V$TRANSACTION, V$ROLLNAME, V$PROCESS, V$SQLTEXT, DBA_DML_LOCKS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  LOG_IO é I/O lógico, não redo log I/O. PROCESS é do cliente, não SPID do servidor. INNER JOIN pode omitir transação sem texto/lock visível; várias linhas por transação.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @transactions.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Usuários, SID/SERIAL#, PROCESS cliente, estado, rollback/objeto, modo, I/O lógico/físico e uso de undo.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  SQL_HASH_VALUE adicionado à associação por endereço; demais junções e colunas preservadas. 
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
select s.osuser "O/S-User", s.username "Ora-User", s.sid "Session-ID",
  s.serial# "Serial", s.process "Process-ID", s.status "Status", r.name
  "Rollback", l.name "Obj Locked", l.mode_held "Lock Mode", t.log_io "Log
  I/O", t.phy_io "Phy I/O", t.used_ublk "undo blks", t.used_urec "undo recs",
  st.sql_text "Sql Text"
  from v$session s, v$transaction t, v$rollname r, v$process p, v$sqltext st,
  dba_dml_locks l
  where s.taddr = t.addr and l.session_id = s.sid and t.xidusn = r.usn and
  p.addr = s.paddr and s.sql_address = st.address and s.sql_hash_value=st.hash_value and st.piece = 0
/
