/*
===============================================================================
SCRIPT: rbk3nv.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/rbk3nv.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar métricas de rollback sem views intermediárias.

FUNCIONAMENTO DETALHADO
  Inline views equivalentes a ROLLBACK1/2 usam outer joins por USN e são ligadas ao catálogo de segmentos.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$ROLLNAME, V$ROLLSTAT, DBA_ROLLBACK_SEGS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Outer joins podem produzir NULL para segmentos sem estatísticas. Não mede uma transação específica nem substitui diagnóstico de AUM.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @rbk3nv.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tablespace/segmento, OPTSIZE/shrinks/averages/HWM/waits/wraps/extends.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Heading HWM e ORDER BY qualificado; duas inline views completas mantidas. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
REM NAME                : RBK3.SQL
REM FUNCTION            : REPORT ON ROLLBACK SEGMENT HEALTH
REM FUNCTION            : USES THE ROLLBACK1 and ROLLBACK2 VIEWs
REM USE                 : FROM SQLPLUS
REM Limitations         : None
REM
REM ------------------------------------------------------------------------ 
REM DISCLAIMER: 
REM    This script is provided for educational purposes only. 
REM    The script has been tested and appears to work as intended. 
REM    You should always run new scripts on a test instance initially. 
COLUMN hwmsize          FORMAT 9999999999    HEADING 'SEGMENT HWM'
COLUMN tablespace_name  FORMAT a11		HEADING 'TABLESPACE'
COLUMN segment_name     FORMAT A10           HEADING 'ROLLBACK'
COLUMN optsize          FORMAT 9999999999   HEADING 'OPTL|SIZE'
COLUMN shrinks          FORMAT 9999           HEADING 'SHRINKS'
COLUMN aveshrink        FORMAT 9999999999   HEADING 'AVE|SHRINK'
COLUMN aveactive        FORMAT 9999999999   HEADING 'AVE|TRANS'
COLUMN waits            FORMAT 99999              HEADING 'WAITS'
COLUMN wraps            FORMAT 99999              HEADING 'WRAPS'
COLUMN extends          FORMAT 9999              HEADING 'EXTENDS'
rem
BREAK ON REPORT
COMPUTE AVG OF AVESHRINK ON REPORT
COMPUTE AVG OF AVEACTIVE ON REPORT
COMPUTE AVG OF SHRINKS ON REPORT
COMPUTE AVG OF WAITS ON REPORT
COMPUTE AVG OF WRAPS ON REPORT
COMPUTE AVG OF EXTENDS ON REPORT
COMPUTE AVG OF HWMSIZE ON REPORT
SET FEEDBACK OFF VERIFY OFF LINES 132 PAGES 47
ttitle "ROLLBACK SEGMENT HEALTH"
spool rbk3nv.lst
rem
SELECT c.tablespace_name, a.segment_name, a.optsize, a.shrinks, a.aveshrink, a.aveactive,
       b.hwmsize, b.waits, b.wraps, b.extends 
FROM (SELECT 
	d.segment_NAME,EXTENTS,
	OPTSIZE,SHRINKS,
	AVESHRINK,AVEACTIVE,
	d.STATUS
FROM 
V$ROLLNAME N, 
V$ROLLSTAT S,
dba_rollback_segs d
WHERE   
d.segment_id=n.usn(+) 
and d.segment_id=S.USN(+)) a, 

(SELECT d.segment_NAME, EXTENTS, XACTS,
HWMSIZE, RSSIZE, WAITS,
WRAPS,  EXTENDS
FROM    
V$ROLLNAME N,
V$ROLLSTAT S,
dba_rollback_segs d
WHERE
d.segment_id=n.usn(+) 
and d.segment_id=S.USN(+)) b, 
dba_rollback_segs c
where a.segment_name=b.segment_name
and c.segment_name=a.segment_name
ORDER BY c.tablespace_name, a.segment_name;
SPOOL OFF
CLEAR COLUMNS
TTITLE OFF
SET FEEDBACK ON VERIFY ON LINES 80 PAGES 22
PAUSE Press enter to continue
