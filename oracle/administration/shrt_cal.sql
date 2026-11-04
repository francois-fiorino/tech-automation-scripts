/*
===============================================================================
SCRIPT: shrt_cal.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/SHRT_CAL.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar coletor JUST_STATISTICS que repovoa staging de métricas e contagens.

FUNCIONAMENTO DETALHADO
  DELETE DBA_TEMP; blocos/cursor leem startup legado, rowcache/sysstat/waitstat/rollstat/librarycache/latches/space e totais de objetos; INSERTs e múltiplos COMMITs.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas conforme limitações individuais.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TEMP, V$INSTANCE KEY/VALUE, V$ROWCACHE, V$SYSSTAT, V$WAITSTAT, V$ROLLSTAT, V$LIBRARYCACHE, V$LATCHNAME, V$LATCH, DBA_OBJECTS, DBA_DATA_FILES, DBA_EXTENTS, V$SGA

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Modelo pré/7.2: KEY/VALUE e nomes antigos não são compatíveis modernos. Muitas razões sem proteção zero, FETCH não gera NO_DATA_FOUND e handlers podem fechar cursor já fechado. Hit ratio original logical/(logical+physical) não é fórmula usual 1-physical/logical; médias/unidades heterogêneas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório com staging descartável e catálogo da versão compatível.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Rotina criada; chamada apaga/regrava métricas e confirma várias etapas.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos de criação, staging, autenticação, sessão
  ou código gerado descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Algoritmo de mais de 10 KB integral preservado e problemas assinalados; sem atualizar métricas/contrato histórico sem ambiente de homologação. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 042 — 04/11/2026
  Correções e melhorias: Startup usa V$INSTANCE.STARTUP_TIME e GET_COUNT usa parâmetro STAT; algoritmos/commits restantes preservados.
  Limitações e pendências: Razões sem proteção zero e handlers que fecham cursores já fechados continuam defeituosos. FETCH vazio não levanta NO_DATA_FOUND; categorias/unidades e fórmula histórica de hit ratio não foram homologadas. DBA_TEMP é compartilhada/destrutiva.
  Homologação necessária: Startup com NLS variável, contador ausente, denominador zero e falha parcial; comparar todas métricas e transações em staging descartável.
  Parâmetros e execução: contratos descritos acima e no corpo histórico.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  backup/recovery, comandos Windows/Unix ou uso de credenciais reais.

REFERÊNCIA: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-INSTANCE.html

AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de qualquer utilização em produção. Sua execução é de responsabilidade do profissional responsável pelo ambiente. Os mantenedores deste repositório não se responsabilizam por indisponibilidade, perda de dados, alterações indevidas ou outros impactos decorrentes de sua utilização.

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
/* cal_stat.sql */
/* FUNCTION: PLSQL script cal_stat.sql, used by do_calst.sql*/
create or replace procedure just_statistics as
    jdate date;
    jsec number;
    hr number;
    minute number;
    sec1 number;
    sec2 number;
    sec number;
    startup_date varchar2(64);
    dd_ratio number := 0; 
    R_CALLS NUMBER  := 0; 
    H_RATIO NUMBER  := 0; 
    SUHW_CONT  NUMBER  := 0;
    SUBW_CONT  NUMBER  := 0;
    UHW_CONT   NUMBER  := 0;
    UBW_CONT   NUMBER  := 0; 
    DB_GETS NUMBER  := 0; 
    CON_GETS NUMBER := 0; 
    P_READS NUMBER  := 0; 
    SUH_WAITS NUMBER := 0;
    SUB_WAITS NUMBER := 0; 
    UH_WAITS NUMBER := 0; 
    UB_WAITS NUMBER := 0;  
    U_CALLS NUMBER  := 0; 
    CALLS_U NUMBER  := 0; 
    RLOG_WAIT NUMBER := 0; 
    STAT_NAME varCHAR2(64); 
    TEMP_NAME varCHAR2(64); 
    STAT_VAL NUMBER := 0;
    temp_value number := 0; 

cursor get_latch is
SELECT 
	A.NAME,100.*B.SLEEPS/B.GETS 
FROM
   	V$LATCHNAME A, V$LATCH B 
WHERE
   	A.LATCH# = B.LATCH# AND B.SLEEPS > 0;

cursor get_totals is
select 
	object_type,count(*)
from 
	dba_objects
where 
	owner not in ('SYS','SYSTEM')
group by 
	object_type
order by 
	object_type;

cursor get_stat(stat in varchar2) is
select 
	name,value 
from 
	v$sysstat 
where 
	NAME = STAT;

cursor get_count(stat in varchar2) is
select 
	class,"COUNT" 
from 
	v$waitstat  
where 
	CLASS = STAT; 

BEGIN 
  DELETE DBA_TEMP;
begin
  SELECT TO_CHAR(startup_time,'YYYY-MM-DD HH24:MI:SS')
  INTO startup_date FROM v$instance;
	insert into dba_temp values ('Startup Date: '||startup_date,0,1);
EXCEPTION
    when no_data_found then
	insert into dba_temp values ('Startup Date: unknown',0,1);
end; 
begin
  STAT_NAME := 'recursive calls';
	open get_stat(stat_name);
	fetch get_stat into TEMP_name, r_calls;
	close get_stat;
EXCEPTION
    when no_data_found then
close get_stat;
end; 
begin  
  STAT_NAME := 'Data Dictionary Miss Percent'; 
	select stat_name, (sum(getmisses)/sum(gets))*100 into TEMP_name, dd_ratio 
	from v$rowcache; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, dd_ratio,17); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,17); 
    commit; 
end; 
begin 
  STAT_NAME := 'user calls'; 
	open  get_stat(stat_name);
	fetch get_stat into TEMP_name, u_calls;
	close get_stat;
EXCEPTION 
    when no_data_found then 
close get_stat;
end; 
begin 
  STAT_NAME := 'db block gets'; 
	open get_stat(stat_name);
	fetch get_stat into TEMP_name, db_gets;
	close get_stat;
EXCEPTION 
    when no_data_found then 
close get_stat;
end; 
begin 
  STAT_NAME := 'consistent gets'; 
	open get_stat(stat_name);
	fetch get_stat into TEMP_name, con_gets;
	close get_stat;
EXCEPTION 
    when no_data_found then 
close get_stat;
end; 
begin 
  STAT_NAME := 'physical reads'; 
	open get_stat(stat_name);
	fetch get_stat into TEMP_name, p_reads;
	close get_stat;
EXCEPTION 
    when no_data_found then 
close get_stat;
end; 
begin 
  STAT_NAME := 'system undo header'; 
	open get_count(stat_name);
	fetch get_count into TEMP_name, suh_waits;
	close get_count;
EXCEPTION 
    when no_data_found then 
close get_count;
end; 
begin 
  STAT_NAME := 'system undo block'; 
	open get_count(stat_name);
	fetch get_count into TEMP_name, sub_waits;
	close get_count;
EXCEPTION 
    when no_data_found then 
close get_count;
end; 
begin 
  STAT_NAME := 'undo header'; 
	open get_count(stat_name);
	fetch get_count into TEMP_name, uh_waits;
	close get_count;
EXCEPTION 
    when no_data_found then 
close get_count;
end; 
begin 
  STAT_NAME := 'undo block'; 
	open get_count(stat_name);
	fetch get_count into TEMP_name, ub_waits;
	close get_count;
EXCEPTION 
    when no_data_found then 
close get_count;
end; 
begin 
    CALLS_U := (R_CALLS/U_CALLS); 
    H_RATIO := ((DB_GETS+CON_GETS)/(DB_GETS+CON_GETS+P_READS)); 
    SUHW_CONT  := (SUH_WAITS/(DB_GETS+CON_GETS)*100);
    SUBW_CONT  := (SUB_WAITS/(DB_GETS+CON_GETS)*100);
    UHW_CONT  := (UH_WAITS/(DB_GETS+CON_GETS)*100);
    UBW_CONT  := (UB_WAITS/(DB_GETS+CON_GETS)*100);
  STAT_NAME := 'RECURSIVE CALLS PER USER'; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, CALLS_U,18); 
  STAT_NAME := 'CUMMULATIVE HIT RATIO'; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, H_RATIO,2); 
  STAT_NAME := 'SYS UNDO HDR WAIT CONTENTION'; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, SUHW_CONT,3); 
  STAT_NAME := 'SYS UNDO BLK WAIT CONTENTION'; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, SUBW_CONT,3); 
  STAT_NAME := 'UNDO HDR WAIT CONTENTION'; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, UHW_CONT,3);
  STAT_NAME := 'UNDO BLK WAIT CONTENTION'; 
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, UBW_CONT,3);  
  STAT_NAME := 'freelist'; 
	open get_count(stat_name);
	fetch get_count into TEMP_name, stat_val;
	close get_count;
  STAT_NAME := 'Free List Contention Ratio';
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL/(db_gets+con_gets),18); 
EXCEPTION 
    WHEN ZERO_DIVIDE THEN 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,32);
	close get_count; 
    COMMIT; 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,32); 
	close get_count;
    commit; 
end; 
/* If post 7.2 uncomment this next block */
/*begin
  STAT_NAME := 'Latch Miss%'; 
	select (1-((sum(sleeps)+sum(immediate_misses))/(
	sum(gets)+sum(immediate_misses)+sum(immediate_gets)))*100) into stat_val 
	from v$latch;
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,4); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,4); 
    commit; 
end; */
begin
  STAT_NAME := 'Rollback Wait %'; 
	select (sum(waits)/sum(gets))*100 into stat_val 
	from v$rollstat;
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,5); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,5); 
    commit; 
end; 
begin
  STAT_NAME := 'Library Reload %'; 
	select sum(reloads)/sum(pins)*100  into stat_val 
	from v$librarycache;
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,5); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,5); 
    commit; 
end; 
begin
  STAT_NAME := 'table fetch by rowid';
	open get_stat(stat_name);
	fetch get_stat into TEMP_name, stat_val;
	close get_stat;
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,9);
EXCEPTION
    when no_data_found then
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,9);
close get_stat;
    commit;
end;
begin
  STAT_NAME:='Non-Index Lookups Ratio';
  select a.value/(a.value+b.value) into STAT_VAL
   from v$sysstat a, v$sysstat b
   where a.name='table scans (long tables)' 
   and b.name='table scans (short tables)';
       INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,8); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,8); 
	close get_stat;
    commit; 
end; 
begin 
  STAT_NAME := 'table fetch continued row'; 
	open get_stat(stat_name);
	fetch get_stat into TEMP_name, stat_val;
	close get_stat;
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,14); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,14); 
	close get_stat;
    commit; 
end; 
begin 
  STAT_NAME := 'sorts (memory)'; 
	open get_stat(stat_name);
	fetch get_stat into TEMP_name, stat_val;
	close get_stat;
    INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,15); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,15); 
	close get_stat;
    commit; 
end; 
begin 
  STAT_NAME := 'sorts (disk)'; 
	open get_stat(stat_name);
	fetch get_stat into TEMP_name, stat_val;
	close get_stat;
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,16); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,16); 
	close get_stat;
    commit; 
end; 
begin 
  STAT_NAME := 'redo log space requests'; 
	open get_stat(stat_name);
	fetch get_stat into TEMP_name, stat_val;
	close get_stat;
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,6); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,6); 
	close get_stat;
    commit; 
end; 
begin 
  STAT_NAME := 'redo log space wait time'; 
	open get_stat(stat_name);
	fetch get_stat into TEMP_name, stat_val;
	close get_stat;
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL, 6); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,6); 
	close get_stat;
    commit; 
end; 
begin 
  STAT_NAME := 'TOTAL ALLOCATED MEG'; 
	select SUM(BYTES)/1048576 into stat_val 
	from dba_DATA_FILES where 
	STATUS = 'AVAILABLE'; 
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,25); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,25); 
    commit; 
end; 
begin 
  STAT_NAME := 'TOTAL USED MEG'; 
	select SUM(BYTES)/1048576 into stat_val 
	from dba_EXTENTS; 
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,26); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,26); 
    commit; 
end; 
begin 
  STAT_NAME := 'TOTAL SGA SIZE'; 
	select STAT_NAME, SUM(b.value) into TEMP_NAME, stat_val 
	from v$sGA b; 
  INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,31); 
EXCEPTION 
    when no_data_found then 
	INSERT INTO DBA_TEMP VALUES (STAT_NAME,0,31); 
    commit; 
end; 
begin
open get_latch;
loop
	fetch get_latch into stat_name,stat_val;
	exit when get_latch%NOTFOUND;
  	INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,33);
end loop;
	close get_latch;
	commit;
end; 
begin
open get_totals;
loop
	fetch get_totals into stat_name,stat_val;
	exit when get_totals%NOTFOUND;
  	INSERT INTO DBA_TEMP VALUES (STAT_NAME, STAT_VAL,34);
end loop;
	close get_totals;
	commit;
end; 
  COMMIT; 
END;         
/
