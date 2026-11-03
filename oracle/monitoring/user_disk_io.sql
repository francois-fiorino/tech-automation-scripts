/*
===============================================================================
SCRIPT: user_disk_io.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/user_disk_io.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar contadores acumulados de I/O das sessões de usuários, excluindo contas de administração.

FUNCIONAMENTO DETALHADO
  Une V$SESSION a V$SESS_IO por SID; exclui USERNAME SYS, SYSTEM e DBSNMP, tratando NULL como SYS; ordena PHYSICAL_READS decrescente.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION, V$SESS_IO

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não agrega por usuário apesar do comentário histórico. Não inclui SID/SERIAL# na saída nem restringe ACTIVE; contadores são por sessão desde sua acumulação, não IOPS recentes.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @user_disk_io.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OSUSER, USERNAME truncado a 15 caracteres, PHYSICAL_READS, BLOCK_GETS e PROCESS cliente.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada. 
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

-- List all users and disk i/o:

set lines 200

select
--   ses.sid, 
--   ses.serial#, 
   ses.osuser,
   substr(ses.username,1,15) as username, 
  sio.physical_reads, 
   sio.block_gets, 
   ses.process
from 
   v$session ses, 
   v$sess_io sio
where
   ses.sid = sio.sid
and 
   nvl(ses.username,'SYS') not in ('SYS', 'SYSTEM','DBSNMP')
order by
   sio.physical_reads desc;