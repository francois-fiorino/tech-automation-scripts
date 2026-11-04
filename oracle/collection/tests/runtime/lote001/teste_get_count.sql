set echo on
set verify off
set define off
set feedback on
set serveroutput on size unlimited
set linesize 200
set pagesize 100

whenever oserror exit failure rollback
whenever sqlerror exit failure rollback

spool oracle_lab_lote001.log

prompt === CONTEXTO ===
select sys_context('USERENV','SESSION_USER') usuario,
       sys_context('USERENV','CON_NAME') container
from dual;

begin
  if sys_context('USERENV','SESSION_USER') <> 'ORACLE_SCRIPT_LAB'
     or sys_context('USERENV','CON_NAME') <> 'PDB1'
  then
    raise_application_error(-20001,'Usuario/container incorretos.');
  end if;
end;
/

prompt === INSTALACAO DA FUNCAO REVISADA ===
@get_count2.sql

show errors function get_count

declare
  v_n number;
begin
  select count(*) into v_n
  from user_objects
  where object_name = 'GET_COUNT'
    and object_type = 'FUNCTION'
    and status = 'VALID';

  if v_n <> 1 then
    raise_application_error(-20002,'GET_COUNT nao compilou.');
  end if;

  select count(*) into v_n
  from user_procedures
  where object_name = 'GET_COUNT'
    and authid = 'CURRENT_USER';

  if v_n <> 1 then
    raise_application_error(-20003,'AUTHID inesperado.');
  end if;
end;
/

prompt === DADOS FICTICIOS ===
create table lab_count_fixture (id number, texto varchar2(30));
create table "Lab Count" (id number);

prompt === TESTES ===
declare
  v_count    number;
  v_rejected boolean := false;

  procedure conferir(p_nome varchar2, p_esperado number) is
    v_obtido number;
  begin
    v_obtido := get_count(p_nome);

    if v_obtido is null or v_obtido <> p_esperado then
      raise_application_error(-20010,
        'FALHA: ' || p_nome || ' esperado=' || p_esperado ||
        ' obtido=' || nvl(to_char(v_obtido),'NULL'));
    end if;

    dbms_output.put_line('PASS: ' || p_nome || ' = ' || v_obtido);
  end;
begin
  conferir('LAB_COUNT_FIXTURE', 0);

  insert into lab_count_fixture values (1, 'linha 1');
  insert into lab_count_fixture values (2, null);
  insert into lab_count_fixture values (null, null);

  conferir('LAB_COUNT_FIXTURE', 3);
  conferir('lab_count_fixture', 3);
  conferir('ORACLE_SCRIPT_LAB.LAB_COUNT_FIXTURE', 3);

  insert into "Lab Count" values (1);
  insert into "Lab Count" values (2);

  conferir('"Lab Count"', 2);

  begin
    v_count := get_count('LAB_COUNT_FIXTURE where 1=1');
  exception
    when others then
      if sqlcode not in (-44002, -44003, -44004) then
        raise;
      end if;
      v_rejected := true;
      dbms_output.put_line('PASS: entrada SQL rejeitada: ' || sqlcode);
  end;

  if not v_rejected then
    raise_application_error(-20011,'Entrada SQL nao foi rejeitada.');
  end if;

  conferir('LAB_COUNT_FIXTURE', 3);

  delete from lab_count_fixture;
  conferir('LAB_COUNT_FIXTURE', 0);

  dbms_output.put_line('RESULTADO: TODOS OS TESTES DESTE LOTE PASSARAM.');
end;
/

commit;

select object_name, object_type, status
from user_objects
order by object_type, object_name;

spool off
