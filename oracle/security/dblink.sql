/*
===============================================================================
SCRIPT: dblink.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / misc_scripts/DBLINK.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Inventariar metadados de database links.

FUNCIONAMENTO DETALHADO
  Consulta DBA_DB_LINKS e ordena owner/host; saída de HOST/DB_LINK/USERNAME/CREATED.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_DB_LINKS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não mostra senha nem testa conectividade; configuração pode expor topologia/usuários, proteger spool. Grants de acesso variam conforme versão/política.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @dblink.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  String de conexão, owner/nome do link, usuário remoto e criação.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  COLUMN PASSWORD histórico não projeta credencial; SELECT preservado. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
REM NAME         : DBLINK.SQL
REM FUNCTION     : GENERATE REPORT OF DATABASE LINKS
REM USE          : FROM SQLPLUS
REM Limitations  : None
REM
set pages 58 lines 130 verify off term off
ttitle "Db Links Report"
spool dblink.lst
column host             format a60      heading "Connect String Used"
column owner            format a15      heading "Creator of DB Link"
column db_link          format a10      heading " DB Link Name" 
column username         format a15      heading "Connecting User"
column password         format a15      heading "Password"
column create                           heading "Date Created" 
select 
	host, 
	owner, 
	db_link, 
	username, 
	created
from 
	dba_db_links
order by 
	owner, 
	host;
spool off
pause Press enter to continue
set pages 22 lines 80 verify on termout on
ttitle off
clear columns
