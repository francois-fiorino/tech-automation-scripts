/*
===============================================================================
SCRIPT: used_tab.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / misc_scripts/used_tab.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relacionar objetos bloqueados, sessão e uso de undo da transação.

FUNCIONAMENTO DETALHADO
  Une LOCKED_OBJECT a OBJECTS/ROLLBACK_SEGS/TRANSACTION/SESSION por objeto, XID completo, TADDR e SID.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$LOCKED_OBJECT, DBA_OBJECTS, DBA_ROLLBACK_SEGS, V$TRANSACTION, V$SESSION

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  USED_UREC pertence à transação, não quantidade de registros da tabela. Muitos nomes são truncados; várias linhas por transação/objeto são possíveis. Não prova bloqueio de outra sessão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @used_tab.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OS/DB user, schema/objeto/tipo, rollback e USED_UREC truncados para apresentação.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  XIDSQN e SESSION_ID incluídos nas junções para não cruzar slot reutilizado ou sessão diferente. 
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
select substr(a.os_user_name,1,8) "OS User"
, substr(a.oracle_username,1,8) "DB User"
, substr(b.owner,1,8) "Schema"
, substr(b.object_name,1,20) "Object Name"
, substr(b.object_type,1,10) "Type"
, substr(c.segment_name,1,5) "RBS"
, substr(d.used_urec,1,12) "# of Records"
from v$locked_object a
, dba_objects b
, dba_rollback_segs c
, v$transaction d
, v$session e
where a.object_id = b.object_id
and a.xidusn = c.segment_id
and a.xidusn = d.xidusn
and a.xidslot = d.xidslot
and a.xidsqn = d.xidsqn
and a.session_id=e.sid
and d.addr = e.taddr
; 
