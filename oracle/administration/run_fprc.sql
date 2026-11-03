/*
===============================================================================
SCRIPT: run_fprc.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/RUN_FPRC.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Orquestrar extração de fonte por chamadas ao helper FPRC_RCT.

FUNCIONAMENTO DETALHADO
  Gera DO_FPRC.SQL com START FPRC_RCT para módulos selecionados; pretende capturar execução em EXE_FPRC.SQL.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme LIMITAÇÕES; roles não
  bastam para compilar dependências de rotinas armazenadas.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_SOURCE, DBA_OBJECTS, V$PARAMETER, FPRC_RCT.SQL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Original executava o mesmo arquivo que estava sendo escrito. Helper ainda depende de revisão/publicação; SQLPATH e diretórios rep_out precisam existir. Fonte pode conter segredos e saída pode ser executável.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Revisão de código em laboratório; não executar sem revisar FPRC_RCT e caminhos.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Lista de chamadas e captura de documentação de código.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados ou sessão descritos
  acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  START final corrigido para DO_FPRC.SQL em vez de autoexecutar EXE_FPRC.SQL aberto para spool; nomes e ramos preservados. 
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
REM NAME        : RUN_FPRC.SQL 
REM FUNCTION    : Generate and execute the exe_fprc.sql procedure
REM USE         : Document the procedures and packages and functions
REM               for a user or users
REM Limitations : Must have access to dba_source and dba_objects.
rem               The FPRC_RCT.SQL procedure must be in same directory
REM
set termout on
column dbname new_value db noprint
pause Use % for a wildcard - Press enter to continue
accept owner prompt 'Enter object owner:'
accept type  prompt 'Enter object type:'
accept name  prompt 'Enter object name:'
prompt Working....
set echo off heading off verify off feedback off
select value dbname from v$parameter where name='db_name';
spool rep_out\&db\do_fprc.sql
select unique('start fprc_rct '||a.owner||' '||'"'||a.type||'"'||' '||a.name)
from 
	dba_source a, dba_objects b
where
	a.owner like upper('&owner') and
	a.type like upper('&type') and
	a.name like upper('&name')
	and a.owner=b.owner and
	a.type=b.object_type and
	a.name=b.object_name;
spool off
set termout off 
spool rep_out\&db\exe_fprc.sql
start rep_out\&db\do_fprc.sql
spool off
undef owner
undef type
undef name
clear columns
set echo on heading on verify on feedback on
