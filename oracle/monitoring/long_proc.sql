/*
===============================================================================
SCRIPT: long_proc.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / misc_scripts/long_proc.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Localizar sessões ativas de Forms/SQL*Plus com chamada acima de 300 segundos.

FUNCIONAMENTO DETALHADO
  Une SESSION/PROCESS por endereço e filtra ACTIVE/LAST_CALL_ET/programa/LOCKWAIT NULL.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION, V$PROCESS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  LAST_CALL_ET ativo não é elapsed exato do SQL atual nem CPU. Filtro LOCKWAIT NULL não exclui todas as esperas; nomes fixos f60/sqlplus omitem outros clientes. Não mata sessões.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @long_proc.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  SID/SERIAL#, módulo/programa, LAST_CALL_ET, SQL hash, SPID e processo cliente.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col sid heading 'Sid'
col ser heading 'Serial#'
col module format a20 heading 'Module|Name'
col program heading 'Program'
col last_call heading 'Last|Call'
col sql_hash_value heading 'Hash|Value'
col spid heading 'System|Pid'
col process heading 'Process'
set lines 132 pages 55
ttitle 'Long Running Processes'
spool long_proc.lst
SELECT c.sid, c.serial# ser, c.module,
SUBSTR(c.program,1,10) Program,
c.last_call_et Last_Call, c.sql_hash_value,
d.spid, c.process
FROM v$session c, v$process d
where c.status='ACTIVE'
AND c.last_call_et>300
and c.paddr=d.addr
and c.lockwait is null
and (c.program like 'f60%'
or c.program like 'sqlplus%')
/
spool off
set lines 80 pages 22
ttitle off
