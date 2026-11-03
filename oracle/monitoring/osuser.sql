/*
===============================================================================
SCRIPT: osuser.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / _os_scripts/OSUSER.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relacionar sessões locais aos processos e usuários do sistema operacional.

FUNCIONAMENTO DETALHADO
  Left outer join V$SESSION.PADDR a V$PROCESS.ADDR; retorna SID, SPID, USERNAME e OSUSER.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION, V$PROCESS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não filtra sessões de usuário nem estado ACTIVE. SPID pode ser compartilhado em threaded execution; SID sem SERIAL# não é identidade durável.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @osuser.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  SID, processo do servidor, usuário Oracle e OSUSER, inclusive sessões sem processo correspondente.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  SQL preservado; wrapper de título/spool tornados independentes. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem Name: OSUSER.SQL
rem
rem Function: Provide list of SID, System PID and username for
rem Function: current oralce users
rem
ttitle 'Oracle System Users'
set lines 132 pages 0
spool osuser.lst
select a.sid,b.spid,a.username,a.osuser
from v$session a, v$process b
where a.paddr=b.addr (+)
/
spool off
ttitle off
clear columns
