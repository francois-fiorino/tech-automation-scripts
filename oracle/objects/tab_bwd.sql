/*
===============================================================================
SCRIPT: tab_bwd.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/tab_bwd.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar atributos de armazenamento/concor­rência de tabelas selecionadas.

FUNCIONAMENTO DETALHADO
  Lista PCTFREE/PCTUSED/INITRANS/FREELISTS e CHAIN_CNT em DBA_TABLES com exclusões de owners.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Título block wait não implica que mede espera. PCTUSED/FREELISTS não governam ASSM como em MSSM; dados de chaining dependem da coleta.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @tab_bwd.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner/tabela/tablespace e atributos históricos de blocos.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  UNDEF COLUMNS substituído por CLEAR COLUMNS; filtros preservados. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col tablespace_name format a19
col table_name format a26
col owner format a19
col chain_cnt heading 'Chained|Rows'
col ini_trans format 9999 heading 'Ini|Tran'
col pct_used format 9999 heading 'PCT|Used'
col pct_free format 9999 heading 'PCT|Free'
col freelists format 99999 heading 'Free|Lists'
set lines 132 pages 47
ttitle 'Table Block Wait Determination Values'
spool tab_bwd.lst
select owner,table_name,tablespace_name,pct_free,pct_used,ini_trans,freelists,chain_cnt
from dba_tables where owner not in ('SYS','SYSTEM','RMAN817','OEM_CAPACITY_PLANNER','PERFSTAT')
order by owner,tablespace_name,table_name
/
spool off
clear columns
set lines 80 pages 22

