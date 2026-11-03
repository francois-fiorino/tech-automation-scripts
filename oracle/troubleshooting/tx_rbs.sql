/*
===============================================================================
SCRIPT: tx_rbs.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / misc_scripts/TX_RBS.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relacionar rollback segments a locks TX e sessões/processos.

FUNCIONAMENTO DETALHADO
  Outer joins de ROLLNAME/ROLLSTAT a locks TX modo 6, SESSION por SID e PROCESS por PADDR/ADDR.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$LOCK, V$SESSION, V$PROCESS, V$ROLLNAME, V$ROLLSTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  TRUNC(ID1/65536) decodifica USN de TX; presença não prova transação bloqueadora. Pode haver mais de uma sessão por segmento e segmentos sem lock. Não cobre todas as instâncias RAC.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @tx_rbs.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Segmento, SID/SPID, usuário da sessão/terminal e extent/bloco corrente.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  SID deixou de ser comparado a PID interno Oracle; adicionado V$SESSION para junção correta ao processo e username de sessão. Separador solto convertido em REM, preservando aviso histórico. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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

rem   Name     : TX_RBS.SQL
rem   Purpose: Generate a report of active rollbacks
rem   Use     : From SQL*Plus
rem   History:
rem   Date        Who                What
rem 
rem
REM ------------------------------------------------------------------------ 
REM DISCLAIMER: 
REM    This script is provided for test purposes only. It is NOT  
REM    supported by Oracle World Wide Technical Support. 
REM    The script has been tested and appears to work as intended. 
REM    You should always run new scripts on a test instance initially. 
REM *************************************************************
COLUMN  name FORMAT a10         HEADING "Rollback|Segment"
COLUMN  pid  FORMAT 9999       HEADING "Ora|PID"
COLUMN  spid FORMAT 9999       HEADING "Sys|PID"
COLUMN  curext FORMAT 99999    HEADING "Curr|Extent"
COLUMN  curblk FORMAT 99999    HEADING "Curr|Block"
COLUMN  terminal FORMAT a10    HEADING "Terminal"
COLUMN transaction format a20 Heading 'Transaction'
SET PAGES 56  LINES 132 VERIFY OFF FEEDBACK OFF
ttitle "Rollback Segments in Use"
spool tx_rbs.lst
SELECT  
     r.name, l.Sid, spid, 
     NVL(q.username, 'no transaction') "Transaction",  
     p.terminal "Terminal",
     s.curext,s.curblk
FROM  
     v$lock l, 
     v$process p, v$session q, 
     v$rollname r,
     v$rollstat s
WHERE 
         l.sid=q.sid(+) AND q.paddr=p.addr(+)
     AND TRUNC(l.id1(+) / 65536) = r.usn 
     AND l.type(+) = 'TX' 
     AND l.lmode(+) = 6
     AND r.usn=s.usn
ORDER BY r.name;
SPOOL OFF
SET PAGES 22  LINES 80 VERIFY ON FEEDBACK ON
CLEAR COLUMNS
TTITLE OFF

