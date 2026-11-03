/*
===============================================================================
SCRIPT: tab_bwd_c.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/tab_bwd_c.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar atributos de armazenamento de tabelas com CHAIN_CNT positivo e owner não excluído.

FUNCIONAMENTO DETALHADO
  Consulta DBA_TABLES com exclusão por NO_CHECK e ordena owner/tablespace/tabela.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES, NO_CHECK (objeto customizado de uma coluna)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  NO_CHECK deve conter uma única coluna e nenhum NULL para NOT IN funcionar como esperado. Atributos não demonstram block waits; PCTUSED/FREELISTS têm escopo legado em MSSM.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @tab_bwd_c.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, tabela, tablespace, PCTFREE/PCTUSED, INITRANS, FREELISTS e CHAIN_CNT.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  UNDEF COLUMNS corrigido para CLEAR COLUMNS; seleção preservada. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col tablespace_name format a29
col table_name format a27
col owner format a17
col chain_cnt heading 'Chained|Rows'
set lines 132 pages 47
ttitle 'Table Block Wait Determination Values'
spool tab_bwd_c.lst
select owner,table_name,tablespace_name,pct_free,pct_used,ini_trans,freelists,chain_cnt
from dba_tables where owner not in (select * from no_check) and chain_cnt>0
order by owner,tablespace_name,table_name
/
spool off
clear columns
set lines 80 pages 22

