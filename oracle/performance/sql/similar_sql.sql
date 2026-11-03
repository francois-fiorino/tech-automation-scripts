/*
===============================================================================
SCRIPT: similar_sql.sql
CATEGORIA: Oracle / performance/sql
ORIGEM: Oracle Script Collection 2015 / misc_scripts/similar_sql.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Agrupar textos SQL por prefixo e usuário de parse para inspeção.

FUNCIONAMENTO DETALHADO
  Une SQLAREA a USERS, agrupa SUBSTR do texto com tamanho CHARS e exige contagem acima de NUM_REPEATS.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SQLAREA, DBA_USERS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Prefixo igual não prova SQL equivalente ou benefício de bind; pode misturar comandos diferentes. SQL_TEXT é prefixo limitado e SQLAREA já agrega children; não é frequência de execução. Entradas devem ser inteiros positivos controlados.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE chars = 40
  DEFINE num_repeats = 5
  @similar_sql.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Usuário, prefixo e número de entradas agrupadas.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta completa preservada. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
set lines 140 pages 55 verify off feedback off
col num_of_times heading 'Number|Of|Repeats'
col SQL heading 'SubString - &&chars Characters' 
col username format a15 heading 'User'
ttitle 'Similar SQL'
spool similar_sql.lst
select b.username,substr(a.sql_text,1,&&chars) SQL, count(a.sql_text) num_of_times from v$sqlarea a, dba_users b
where a.parsing_user_id=b.user_id
group by b.username,substr(a.sql_text,1,&&chars) having count(a.sql_text)>&&num_repeats
order by count(a.sql_text) desc
/
spool off
undef chars
undef num_repeats
clear columns
set lines 80 pages 22 verify on feedback on
ttitle off

