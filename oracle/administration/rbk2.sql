/*
===============================================================================
SCRIPT: rbk2.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/rbk2.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar todas as colunas da view customizada ROLLBACK2.

FUNCIONAMENTO DETALHADO
  SELECT * ordenado por segmento com médias visuais de contadores e HWM.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  ROLLBACK2 (customizada)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  View deve existir com contrato de RBK_VIEWS proposto no PR. SELECT * depende da definição; HWM é maior tamanho do segmento, não maior transação individual.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @rbk2.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Segmento/extents/xacts/HWM/rssize/waits/wraps/extends conforme definição instalada.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Heading HWM corrigido semanticamente; consulta original preservada. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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


REM
REM NAME        : RBK2.SQL
REM FUNCTION    : REPORT ON ROLLBACK SEGMENT STATISTICS
REM FUNCTION    : USES THE ROLLBACK2 VIEW
REM USE         : FROM SQLPLUS
REM Limitations : None
REM
REM ------------------------------------------------------------------------ 
REM DISCLAIMER: 
REM    This script is provided for educational purposes only.
REM    The script has been tested and appears to work as intended. 
REM    You should always run new scripts on a test instance initially.
REM ------------------------------------------------------------------------- 
REM Script begins after this line
COLUMN segment_name     FORMAT A8              HEADING 'ROLLBACK'
COLUMN extents          FORMAT 99999            HEADING 'EXTENTS'
COLUMN xacts            FORMAT 9999            HEADING 'TRANS'
COLUMN hwmsize          FORMAT 9999999999    HEADING 'SEGMENT HWM'
COLUMN rssize           FORMAT 9999999999    HEADING 'CUR SIZE'
COLUMN waits            FORMAT 99999              HEADING 'WAITS'
COLUMN wraps            FORMAT 99999              HEADING 'WRAPS'
COLUMN extends          FORMAT 9999              HEADING 'EXTENDS'
rem
SET FEEDBACK OFF VERIFY OFF lines 132 pages 58
BREAK ON REPORT
COMPUTE AVG OF WAITS ON REPORT
COMPUTE AVG OF WRAPS ON REPORT
COMPUTE AVG OF EXTENDS ON REPORT
COMPUTE AVG OF HWMSIZE ON REPORT
rem
ttitle "ROLLBACK SEGMENT STATISTICS"
spool rbk2.lst
rem
SELECT * FROM rollback2 ORDER BY segment_name;
SPOOL OFF
SET LINES 80 PAGES 20 FEEDBACK ON VERIFY ON 
TTITLE OFF
CLEAR COLUMNS
PAUSE Press enter to continue
