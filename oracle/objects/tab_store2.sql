/*
===============================================================================
SCRIPT: tab_store2.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/tab_store2.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Combinar atributos de tabelas não particionadas e defaults de tabelas particionadas.

FUNCIONAMENTO DETALHADO
  UNION de DBA_TABLES com PCT_USED não NULL e DBA_PART_TABLES com DEF_*; preserva exclusões de owners.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES, DBA_PART_TABLES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Primeira parte pode omitir tabelas ASSM onde PCT_USED é NULL. Defaults do objeto particionado não garantem atributos de cada partição. Não recomenda alterações.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @tab_store2.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner/tabela, PCTFREE/PCTUSED, INITRANS/FREELISTS, tipo de particionamento e logging.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col owner format a10 heading 'Owner'
col table_name format a30 heading 'Table Name'
col partition_type format a10 heading 'Partition|Type'
col pct_free format 9999 heading 'Pct|Free'
col ini_trans format 9999 heading 'Ini|Trans'
col freelists format 999999999 heading 'Freelists'
break on owner
set lines 132 pages 50
ttitle 'Table Storage'
spool tab_store2.lst
select owner,table_name,pct_free,pct_used, ini_trans,freelists,'N/A' partition_type,
logging 
from dba_tables
where owner not in 
('SYS','SYSTEM','DBAUTIL','OUTLN','SCOTT','RMAN','WEBDB','DBSNMP','OAS_PUBLIC','PUBLIC')
 and pct_used is not null
union
select owner,table_name,def_pct_free,def_pct_used, def_ini_trans,def_freelists, partitioning_type, def_logging
from dba_part_tables
where owner not in 
('SYS','SYSTEM','DBAUTIL','OUTLN','SCOTT','RMAN','WEBDB','DBSNMP','OAS_PUBLIC','PUBLIC')
order by owner,partition_type,table_name
/
spool off
ttitle off
set lines 80 pages 22
