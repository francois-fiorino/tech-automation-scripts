/*
===============================================================================
SCRIPT: map_db.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/map_db.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exportar mapa de extents usados/livres e encerrar cliente.

FUNCIONAMENTO DETALHADO
  UNION de EXTENTS/FREE_SPACE ordenada por tablespace/arquivo/bloco; spool nomeado com host/instância/banco e QUIT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_EXTENTS, DBA_FREE_SPACE, V$DATABASE, V$INSTANCE, DUAL, SQL*Plus QUIT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  QUIT pode confirmar transação; não é seguro chamar como consulta isolada em sessão de trabalho. Varredura do mapa de extents pode ser cara; saída expõe topologia e nomes de segmentos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente sessão descartável sem transação pendente: revisar @map_db.sql.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Mapa com bytes/KiB/MiB, bloco inicial/tamanho e próximo bloco.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Continuação BREAK incompleta corrigida; consulta UNION e QUIT preservados. 
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
column today noprint new_value xdate
select substr(to_char(sysdate,'fmMonth DD, YYYY HH:MI:SS P.M.'),1,35) today
from dual;
column name noprint new_value dbname
column created noprint new_value dbcreated
column host_name noprint new_value hostname
column instance_name noprint new_value instname
select name,created from v$database;
select host_name from v$instance;
select instance_name from v$instance;

set pagesize 59
set linesize 132
set echo off
set feedback off
set termout off

spool &instname..&dbname..&hostname..db_extent_usage.out

prompt Date:      &xdate
prompt DATABASE:  &dbname
prompt INSTANCE:  &instname
prompt HOST:      &hostname
prompt Created:   &dbcreated
prompt

column "Kbytes"	format 99,999,999;
column "Mbytes"	format 99,999.99;
column "NextBlock" format 9999999;
column tablespace_name	format a20;
column segment_name format a25;
column file_id format 999;

ttitle left 'Database Extent Usage Report' skip 1 -
left 'Page: ' format 99  sql.pno skip 2

break on report -
	on tablespace_name skip 1

compute count of block_id on tablespace_name;
compute sum max of "Blocks" "Kbytes" "Mbytes" on tablespace_name;
compute sum of "Kbytes" "Mbytes" on report;

select tablespace_name,file_id,segment_name,
bytes, bytes/1024 as "Kbytes", bytes/1024/1024 as "Mbytes", 
block_id, blocks, block_id+blocks as "NextBlock"
from dba_extents
union 
select tablespace_name,file_id,'***** FREE *****' ,
bytes, bytes/1024 as "Kbytes", bytes/1024/1024 as "Mbytes", 
block_id, blocks, block_id+blocks as "NextBlock"
from dba_free_space
order by tablespace_name,file_id,block_id;

spool off
quit

