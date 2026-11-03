/*
===============================================================================
SCRIPT: idx_time.sql
CATEGORIA: Oracle / objects/indexes
ORIGEM: Oracle Script Collection 2015 / _index_scripts/IDX_TIME.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar data do último DDL dos índices de um proprietário informado.

FUNCIONAMENTO DETALHADO
  Consulta DBA_OBJECTS filtrada por OBJECT_TYPE=INDEX e OWNER_NAME, formatando LAST_DDL_TIME.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_OBJECTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  LAST_DDL_TIME não indica manutenção de linhas, último uso ou horário de rebuild necessariamente. Filtro é case-sensitive e usa igualdade; informar owner conforme dicionário.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE owner_name = HR
  @idx_time.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OBJECT_NAME e MOD_TIME; hora do último DDL registrada no objeto.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Máscara HH trocada por HH24 para eliminar ambiguidade de horário. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
column mod_time format a25 heading 'Modification|Time'
column object_name format a30 heading 'Index|Name'
set verify off
ttitle 'Index Modification Times'
spool idx_time.lst
select object_name,to_char(last_ddl_time,'DD-MON-YY HH24:MI:SS') MOD_TIME from dba_objects where 
object_type='INDEX' and owner='&owner_name';
spool off
