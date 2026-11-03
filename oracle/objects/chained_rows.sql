/*
===============================================================================
SCRIPT: chained_rows.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/chained_rows.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Mostrar porcentagem estatística de encadeamento para tabelas com mais de uma linha encadeada.

FUNCIONAMENTO DETALHADO
  Consulta DBA_TABLES com CHAIN_CNT>1 e calcula razão frente a NUM_ROWS.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Sem OWNER na saída: homônimos não são distinguíveis. Dados dependem da coleta e não identificam causa de migração/encadeamento. Não altera tabelas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @chained_rows.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  TABLE_NAME, CHAIN_CNT, NUM_ROWS e Chain Percent.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NUM_ROWS protegido com NULLIF para estatística zero. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem chained_rows.sql
rem FUNCTION: SHow percentage of chained rows
rem tables must have been analyzed
rem MRA
rem
column "Chain Percent" format 999.99
column table_name heading 'Table|Name'
column chain_cnt heading 'Chained|Rows'
column num_rows heading 'Row|Count'
set pages 47
set feedback off
ttitle 'Chained Rows Report'
spool chained_rows.lst
select table_name,chain_cnt, num_rows, chain_cnt/nullif(num_rows,0)*100 "Chain Percent" from dba_tables
where
chain_cnt>1 
/
--and owner not in ('SYS','SYSTEM')
spool off
ttitle off

