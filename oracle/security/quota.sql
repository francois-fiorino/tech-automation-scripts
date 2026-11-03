/*
===============================================================================
SCRIPT: quota.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/QUOTA.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar quotas de tablespace para padrão de username.

FUNCIONAMENTO DETALHADO
  Aceita username com wildcard, consulta DBA_TS_QUOTAS e converte bytes para KiB.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TS_QUOTAS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  MAX_BYTES=-1 não é quota negativa em bytes nem erro; UNLIMITED TABLESPACE pode conceder acesso não representado por esta view. Não mede autoextend ou espaço livre.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @quota.sql
  -- Informar HR ou % para todos.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tablespace, usuário, KiB usados e quota KiB; MAXB=-1 sinaliza ilimitado.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Operador = substituído por LIKE para corresponder ao prompt de wildcard; -1 preservado como sentinela antes da divisão. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem *******************************************************************
rem  NAME: quota.sql     
rem  FUNCTION: Print the tablespace quotas of users. 
rem *******************************************************************
prompt Percent signs are wild cards
accept username prompt 'Enter user name or wild card '
prompt Print the details of the Users Tablespace Quotas
ttitle "Database Users Space Quotas by Tablespace"
col un 		format a25 		heading 'User Name'
col ta 		format a25 		heading 'Tablespace' 
col usd 		format 9,999,999 	heading 'K Used' 
col maxb  	format 9,999,999 	heading 'Max K ' 
set verify off feedback off newpage 0 heading on
spool quota.lst
break on ta skip 2
select 
 TABLESPACE_NAME  	ta,
 USERNAME    		un,
 BYTES/1024       		usd, 
 decode(MAX_BYTES,-1,-1,MAX_BYTES/1024)   	maxb
from dba_ts_quotas
   where username like upper('&&username')
order by tablespace_name,username;
prompt End of Report
spool off
set verify on 
undef username
clear breaks
clear columns
clear computes
set verify on feedback on heading on
ttitle off
