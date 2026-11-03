/*
===============================================================================
SCRIPT: title132.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/title132.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Configurar cabeçalho SQL*Plus histórico para relatórios largos.

FUNCIONAMENTO DETALHADO
  Define COMPANY/HEADING e TTITLE, coleta data/hora e DB_NAME com NEW_VALUE e define DB para scripts chamadores.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SQL*Plus TTITLE/COLUMN/DEFINE, SYS.V_$PARAMETER

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Helper não contém relatório de negócio. Altera apresentação/variáveis persistentes da sessão; largura 132 depende também do chamador. &1 deve ser texto controlado.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @title132.sql "Relatório de teste"
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Cabeçalhos das páginas seguintes e variáveis DB/DBNAME/CURRENT_DATE/CURRENT_TIME.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Helper integral preservado; não é ausente do ZIP, mas estava em diretório diferente dos chamadores. 
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
rem
rem TITLE132.SQL 
rem
rem FUNCTION:    This SQL*Plus script builds a standard report heading 
rem              heading for database reports that are 132 columns 
rem
column  TODAY    NEW_VALUE  CURRENT_DATE   NOPRINT
column  TIME     NEW_VALUE  CURRENT_TIME   NOPRINT
column  DATABASE NEW_VALUE  DATA_BASE      NOPRINT
column  PASSOUT  NEW_VALUE  DBNAME         NOPRINT
rem
define COMPANY = " "
define HEADING = "&1"
rem
TTITLE LEFT "Date: " current_date CENTER company col 118 "Page:" format 999 -
       SQL.PNO SKIP 1 LEFT "Time: " current_time CENTER heading RIGHT -
       format a15 SQL.USER SKIP 1 CENTER format a20 data_base SKIP 2
rem
rem
set heading off termout off
rem
SELECT TO_CHAR(SYSDATE,'MM/DD/YY') TODAY,
      TO_CHAR(SYSDATE,'HH:MI AM') TIME,
      value||' database' DATABASE, 
      rtrim(value) passout
FROM   sys.v_$parameter
where name = 'db_name';
rem
set heading on termout on
set newpage 0
DEFINE DB = '&DBNAME'

