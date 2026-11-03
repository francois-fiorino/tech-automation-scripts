/*
===============================================================================
SCRIPT: brown_rep.sql
CATEGORIA: Oracle / objects/indexes
ORIGEM: Oracle Script Collection 2015 / _index_scripts/brown_rep.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar métricas históricas de registros removidos em estatísticas de índices coletadas externamente.

FUNCIONAMENTO DETALHADO
  Lê STAT_TEMP e calcula DEL_LF_ROWS_LEN/(LF_ROWS_LEN+DEL_LF_ROWS_LEN)*100 e (LF_ROWS-DISTINCT_KEYS)/LF_ROWS*100; exige LF_ROWS_LEN>0.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  STAT_TEMP (tabela customizada, geralmente cópia de INDEX_STATS)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Depende de coleta prévia com procedimento externo. DEL_LF_ROWS_LEN pode ser subconjunto de LF_ROWS_LEN, de modo que a soma do denominador não é percentual canônico de espaço recuperável. Não usar como gatilho automático de rebuild; não mede fragmentação física de disco.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @brown_rep.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  NAME, bytes removidos/folhas e BROWNING/DISTINCTIVENESS segundo fórmulas originais.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Fórmulas preservadas e limitações explícitas; nenhuma coleta ANALYZE executada. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Wrapper externo de título substituído por TTITLE local.
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
set lines 132 pages 55
column del_lf_rows_len format 999,999,999 heading 'Deleted Bytes'
column lf_rows_len format 999,999,999 heading 'Filled Bytes'
column browning format 999.90 heading 'Percent|Browned'
ttitle "Index Browning Report"
spool brown_rep.lst
select 
	name,del_lf_rows_len,lf_rows_len,
	(del_lf_rows_len/decode((lf_rows_len+del_lf_rows_len),0,1,
       lf_rows_len+del_lf_rows_len))*100 browning
            , (LF_ROWS-DISTINCT_KEYS)*100/ decode(LF_ROWS,0,1,LF_ROWS) DISTINCTIVENESS 
from 
	stat_temp 
where 
	lf_rows_len>0;
spool off
