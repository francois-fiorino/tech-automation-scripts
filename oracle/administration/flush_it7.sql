/*
===============================================================================
SCRIPT: flush_it7.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/flush_it7.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar variante FLUSH_IT com componentes SGA de nomes legados.

FUNCIONAMENTO DETALHADO
  Soma sete categorias de SGASTAT, divide por SHARED_POOL_SIZE, faz flush se ultrapassar P_FREE e grava histórico com COMMIT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme LIMITAÇÕES; roles não
  bastam para compilar dependências de rotinas armazenadas. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SGASTAT, V$PARAMETER, DUAL, DBMS_SQL, DBA_RUNNING_STATS, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Categorias legadas podem estar ausentes. ASMM/AMM e tamanho configurado zero tornam razão inadequada. Privilégios diretos CREATE PROCEDURE/ALTER SYSTEM/INSERT. Flush pode degradar todo banco; P_FREE é limiar de uso apesar do nome.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente revisão: não instalar junto a outras variantes FLUSH_IT.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Rotina criada e possível purge/log/commit quando chamada.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados ou sessão descritos
  acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF, fechamento dos cursores e terminador /; heurística e efeitos administrativos preservados. 
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
create or replace procedure flush_it(p_free IN NUMBER) as
cursor get_share is
SELECT 
  SUM(bytes)
FROM  
  v$sgastat 
WHERE 
  name in ( 
  'reserved stopper',             
  'table definiti',                  
  'dictionary cache',           
  'library cache',              
  'sql area',
  'PL/SQL DIANA',
  'SEQ S.O.'); 
cursor get_var is
 select value from v$parameter where name like 'shared_pool_size';
cursor get_time is 
 select sysdate from dual;
  todays_date date;
  mem_ratio number;
share_mem number;
variable_mem number;
cur integer;
sql_com varchar2(60);
row_proc number;
begin
 open get_share;
 open get_var;
 fetch get_share into share_mem;
dbms_output.put_line('share_mem: '||to_char(share_mem));
 fetch get_var into variable_mem;
dbms_output.put_line('variable_mem: '||to_char(variable_mem));
 close get_share;
 close get_var;
 mem_ratio:=share_mem/nullif(variable_mem,0);
dbms_output.put_line(to_char(mem_ratio));
 if mem_ratio>(p_free/100) Then
  cur:=dbms_sql.open_cursor;
  sql_com:='alter system flush shared_pool';
  dbms_sql.parse(cur,sql_com,dbms_sql.v7);
  row_proc:=dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);
  open get_time;
  fetch get_time into todays_date;
 close get_time;
  insert into dba_running_stats values ('Flush of Shared Pool',mem_ratio,35,todays_date,0);
  commit;
 end if;
end;
/
