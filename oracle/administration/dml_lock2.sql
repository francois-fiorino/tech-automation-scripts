/*
===============================================================================
SCRIPT: dml_lock2.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/dml_lock2.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar DML locks locais e encerrar o cliente.

FUNCIONAMENTO DETALHADO
  Consulta DBA_DML_LOCKS, grava spool, faz pausa e EXIT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/execução e SELECT DIRETO conforme LIMITAÇÕES; roles
  podem não atender compilação de objetos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_DML_LOCKS, SQL*Plus EXIT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  EXIT do SQL*Plus pode confirmar transação pendente; não é seguro encaixar em sessão de trabalho como consulta comum. Não mostra grafo RAC ou deadlock completo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente sessão descartável sem transação pendente: @dml_lock2.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, sessão, nome e modos mantido/solicitado; depois fecha sessão.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cria/modifica objetos, dados, credenciais ou sessão
  conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  SELECT e EXIT preservados, com efeito de sessão explicitado. 
  Revisão estática somente; implantação depende de laboratório e aprovação do PR.
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
rem FUNCTION: Document DML locks currently in use
rem
column owner format a15 heading 'User'
column session_id heading 'SID'
column mode_held format a20 heading 'Mode|Held'
column mode_requested format a20 heading 'Mode|Requested'
set feedback off echo off pages 59 lines 131
ttitle 'Report on All DML Locks Held'
spool dml_lock
select nvl(owner,'SYS') owner,session_id,name,
mode_held,mode_requested
from  sys.dba_dml_locks
order by 2
/
spool off
pause press enter/return to continue
clear columns
set feedback on echo on pages 22 lines 80
ttitle off
exit
