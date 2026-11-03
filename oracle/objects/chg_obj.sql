/*
===============================================================================
SCRIPT: chg_obj.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/chg_obj.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar objetos de DBO com último DDL posterior a data, excluindo views.

FUNCIONAMENTO DETALHADO
  Filtra DBA_OBJECTS por owner literal DBO, tipo diferente de VIEW e LAST_DDL_TIME após data.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_OBJECTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não monitora DML nem é auditoria histórica. Owner DBO fixo pode não existir e nomes são truncados por largura. Data não inclui hora de entrada, portanto limiar é meia-noite.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @chg_obj.sql
  -- Informar data dd-mon-yy quando solicitado.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner/nome/tipo e último DDL com hora 24h.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  HH24 na apresentação e ordenação por LAST_DDL_TIME real em vez de texto. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
REM: chg_obj.sql
REM: show report of objects that have been modified
REM: since a given date, excluding views
REM: MRA
column owner format a5 heading Owner
column object_name format a27 heading Name
column object_type format a12 heading Type
column modified format a15 heading Modified
undef chg_date
set pages 45 verify off 
ttitle 'Changed Objects Since &&chg_date'
spool chg_obj.lst
select owner,object_name,object_type,to_char(last_ddl_time,'dd-mon-yy hh24:mi') Modified
from dba_objects where owner= 'DBO' and last_ddl_time>to_date('&&chg_date','dd-mon-yy')
and object_type != 'VIEW'
order by object_type,last_ddl_time
/
spool off
ttitle off
