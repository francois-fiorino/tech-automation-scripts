/*
===============================================================================
SCRIPT: ora_kill.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/ORA_KILL.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar chamadas para encerrar sessões não SYS com username definido.

FUNCIONAMENTO DETALHADO
  Spool KILL_ALL.SQL de EXECUTE KILL_SESSION(SID,SERIAL#); execução automática permanece comentada.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme LIMITAÇÕES; roles não
  bastam para compilar dependências de rotinas armazenadas.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION, procedimento KILL_SESSION

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Geração não encerra sessões, mas executar saída derruba conexões e causa rollback. Não exclui a própria sessão nem usuários administrativos além de SYS. SID/SERIAL# devem ser reconferidos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente revisão: @ora_kill.sql; inspecionar KILL_ALL.SQL sem executar.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Arquivo local de chamadas administrativas.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados ou sessão descritos
  acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  OR incorreto substituído por AND, evitando incluir SYS; código gerador preservado. 
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
REM ORA_KILL.SQL
REM FUNCTION	: Kills non-essential Oracle sessions (those that aren't owned
REM			: by SYS or "NULL" 
REM DEPENDANCIES: Depends on kill_session procedure
REM MRA 9/12/96
REM
set heading off termout off verify off echo off
spool kill_all.sql
select 'execute kill_session('||chr(39)||sid||chr(39)||','||
chr(39)||serial#||chr(39)||');' from v$session
where username is not null
and username <> 'SYS'
/
spool off
rem start kill_all.sql

