/*
===============================================================================
SCRIPT: similar_sql1.sql
CATEGORIA: Oracle / performance/sql
ORIGEM: Oracle Script Collection 2015 / misc_scripts/similar_sql1.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Contar entradas com prefixo textual SQL de 110 caracteres repetido mais de três vezes.

FUNCIONAMENTO DETALHADO
  Agrupa SUBSTR(SQL_TEXT,1,110) de V$SQLAREA, conta e ordena frequência.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SQLAREA

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não normaliza literais nem comprova equivalência semântica/plano. SQLs diferentes podem compartilhar prefixo; contagem não é execução ou child cursors.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @similar_sql1.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Prefixo de 110 caracteres e NUM_OF_TIMES.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Heading 90 Characters corrigido para 110; corpo SQL preservado. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col num_of_times heading 'Number|Of|Repeats'
col substr(a.sql_text,1,110) heading 'SubString - 110 Characters' 
col username format a10 heading 'User'
ttitle 'Similar SQL'
spool similar_sql1.lst
select substr(a.sql_text,1,110), count(a.sql_text) num_of_times from v$sqlarea a
group by substr(a.sql_text,1,110) having count(a.sql_text)>3
order by 2 desc
/
spool off
