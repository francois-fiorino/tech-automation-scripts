/*
===============================================================================
SCRIPT: pool_rep.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/pool_rep.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar medidas históricas customizadas de shared pool usado/disponível em faixa de datas.

FUNCIONAMENTO DETALHADO
  Filtra DBA_RUNNING_STATS pelos nomes Shared Pool Available/Used e TRUNC(MEAS_DATE) inclusivo entre DATE1 e DATE2; ordena por nome e data original.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_RUNNING_STATS (objeto customizado)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Requer tabela/view e coleta externas. TRUNC da coluna pode limitar uso de índice; preservado por equivalência funcional. Datas de limite são dias inteiros.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE date1 = 2026-11-01
  DEFINE date2 = 2026-11-03
  @pool_rep.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  NAME, VALUE e MEAS_DATE; unidade e metodologia dependem do coletor.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Máscara YYYY-MM-DD explícita nos dois TO_DATE; ORDER BY T.MEAS_DATE substitui ordenação lexicográfica da data exibida. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
column name format a30 heading 'Pool Measurement'
column meas_date format a15 heading 'Measurement Date'
column value format 9,999.99 heading 'Value'
set pages 47
ttitle 'Shared Pool Measurements'
spool pool_rep.lst
select name,value,to_char(meas_date,'dd-mon-yy hh24:mi') meas_date
from dba_running_stats t
where name in ('Shared Pool Available',
'Shared Pool Used') and 
trunc(meas_date) between to_date('&date1','YYYY-MM-DD') and to_date('&date2','YYYY-MM-DD')
order by name,t.meas_date
/
spool off

