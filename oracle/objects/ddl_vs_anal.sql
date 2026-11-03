/*
===============================================================================
SCRIPT: ddl_vs_anal.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/ddl_vs_anal.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Comparar dia de coleta de estatísticas com dia do último DDL de tabelas.

FUNCIONAMENTO DETALHADO
  Une TABLES/OBJECTS por owner/nome e tipo TABLE, filtra estatística presente e dias diferentes.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES, DBA_OBJECTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Datas diferentes não provam estatísticas stale; DDL pode não alterar distribuição e DML não muda LAST_DDL_TIME. Lista de owners excluídos é histórica. Não coleta estatísticas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @ddl_vs_anal.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner/tabela e timestamps completos de análise/DDL.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Tipo TABLE evita misturar índices/partições homônimos; comparação DATE TRUNC substitui texto e horas reais deixam de ser zeradas na saída. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col table_name format a30 heading 'Table|Name'
col last_analyzed format a18 heading 'Last|Analyzed'
col owner format a13 heading 'Owner'
col last_ddl_time format a18 heading 'Last DDL|Date'
ttitle 'DDL Verses Analyzed'
set lines 90 pages 55
spool ddl_vs_anal.lst
select 
  t.owner, t.table_name, 
  to_char(t.last_analyzed,'dd-mon-yyyy hh24:mi') last_analyzed, 
  to_char(o.last_ddl_time,'dd-mon-yyyy hh24:mi') last_ddl_time 
from 
  dba_tables t, dba_objects o 
where
   t.owner not in
   ('SYS','SYSTEM','DBAUTIL','OUTLN','SCOTT','RMAN','WEBDB','DBSNMP','OAS_PUBLIC','PUBLIC','PERFSTAT')
   and t.table_name=o.object_name 
   and t.owner=o.owner and o.object_type='TABLE'
   and t.last_analyzed is not null
   and trunc(t.last_analyzed)!=trunc(o.last_ddl_time)
/
spool off
ttitle off
set pages 22 lines 80
