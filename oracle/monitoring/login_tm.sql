/*
===============================================================================
SCRIPT: login_tm.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / misc_scripts/LOGIN_TM.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Comparar estimativa legada de login com LOGON_TIME da sessão.

FUNCIONAMENTO DETALHADO
  Mantém cálculo SYSDate/HSECS e estatística numérica 13, juntando por SID, e acrescenta data de login diretamente da sessão.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$SESSTAT, SYS.V_$SESSION, SYS.V_$TIMER

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Statistic# 13 não é estável entre versões; HSECS sofre wrap e não é calendário. Filtro original pode omitir sessões. Usar coluna ACTUAL_LOGON_TIME como login; algoritmo antigo preservado para comparação histórica.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @login_tm.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  SID/SERIAL#, usuário/status/programa, LEGACY estimate e ACTUAL_LOGON_TIME.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Acrescentado LOGON_TIME sem retirar cálculo original; heading do cálculo identifica estimativa legada. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
column sids format a10 heading "Sid,Ser#"
column username format a15 heading Username
column ltime format a20 heading "Legacy Estimate"
column program format a30 heading Program
ttitle 'User Login Times'
spool login_tm.lst
select s.sid||','||n.serial# sids,
       n.username,
       n.status "Status",
       n.program,
       to_char(n.logon_time,'MM/DD/YYYY HH24:MI:SS') actual_logon_time,
       to_char(sysdate-(hsecs-s.value)/(24*3600*100),
          'MM/DD/YYYY HH24:MI:SS') ltime
from sys.V_$sesstat s,
     sys.V_$session n,
     sys.v_$timer
where s.statistic# = 13
and   s.sid = n.sid
and   s.value != 0
order by 2,5;
spool off
