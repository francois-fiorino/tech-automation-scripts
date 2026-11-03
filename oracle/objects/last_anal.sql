/*
===============================================================================
SCRIPT: last_anal.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/last_anal.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar data da última coleta de estatísticas das tabelas de schemas selecionados.

FUNCIONAMENTO DETALHADO
  Consulta DBA_TABLES com lista histórica de owners excluídos e apresenta LAST_ANALYZED formatado; ordena owner/tabela.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não é data do último DML nem indicador suficiente de staleness. Estatísticas de partições/subpartições exigem views próprias. Lista de exclusões foi preservada.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @last_anal.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OWNER, TABLE_NAME e LAST_ANALYZED; NULL pode indicar ausência de estatísticas no nível consultado.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  TO_DATE aplicado a coluna já DATE substituído por TO_CHAR com máscara explícita, evitando conversão implícita dependente de NLS. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col owner format a10 Heading 'Table|Owner'
col table_name format a40  heading 'Table|Name'
col last_analyzed heading 'Last Date|Analyzed'
ttitle 'Table Last Analyzed'
break on owner
spool last_anal.lst
select owner,table_name,to_char(last_analyzed,'dd-mon-yy hh24:mi') last_analyzed 
from dba_tables 
where 
owner not in ('SYS','SYSTEM','DBAUTIL','OUTLN','SCOTT','RMAN','WEBDB','DBSNMP','OAS_PUBLIC','PUBLIC')
order by owner,table_name,last_analyzed
/
spool off
