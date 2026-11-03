/*
TESTE DE LABORATÓRIO — REVISÃO 036
Não executado neste trabalho. Requer Oracle e instalação individual prévia de
DEC2HEX/HEXTOINTEGER/INTEGERTOHEX, TIME_DELTA e STARTUP_DATE revisados, somente
em schema descartável. Não instala objetos nem chama rotinas administrativas.
Necessita SELECT autorizado em V$INSTANCE para conferir o retorno de startup.
Asserções cobrem conversões e duração; não homologam os demais 16 scripts.
AVISO: avaliar e testar em ambiente controlado. Execução sob responsabilidade
do profissional responsável pelo ambiente; mantenedores não se responsabilizam
por indisponibilidade, perda de dados ou outros impactos decorrentes do uso.
*/
set define off
set serveroutput on size unlimited
whenever sqlerror exit failure rollback
declare
 h varchar2(200);
 n number;
 d date;
 expected_start date;
 procedure expect(actual varchar2,expected varchar2,label_text varchar2) is
 begin
  if (actual is null and expected is not null) or
     (actual is not null and expected is null) or actual<>expected then
   raise_application_error(-20990,'Falhou: '||label_text);
  end if;
 end;
begin
 dec2hex(null,h); expect(h,null,'dec2hex null');
 dec2hex(0,h); expect(h,'0','dec2hex zero');
 dec2hex(15,h); expect(h,'F','dec2hex 15');
 dec2hex(16,h); expect(h,'10','dec2hex 16');
 dec2hex(2147483647,h); expect(h,'7FFFFFFF','dec2hex max');
 expect(integertohex(0),'0','integertohex zero');
 expect(integertohex(255),'FF','integertohex 255');
 expect(integertohex(null),null,'integertohex null');
 n:=hextointeger('ff'); if n<>255 then raise_application_error(-20990,'lowercase'); end if;
 n:=hextointeger('7FFFFFFF'); if n<>2147483647 then raise_application_error(-20990,'max int'); end if;
 for i in 0..1000 loop
  dec2hex(i,h);
  n:=hextointeger(h);
  if n<>i then raise_application_error(-20990,'roundtrip'); end if;
 end loop;
 begin
  dec2hex(-1,h); raise_application_error(-20990,'negativo aceito');
 exception when others then if sqlcode<>-20012 then raise; end if;
 end;
 begin
  dec2hex(0.5,h); raise_application_error(-20990,'fracao aceita');
 exception when others then if sqlcode<>-20012 then raise; end if;
 end;
 begin
  n:=hextointeger('G'); raise_application_error(-20990,'digito invalido aceito');
 exception when others then if sqlcode<>-20013 then raise; end if;
 end;
 begin
  n:=hextointeger('80000000'); raise_application_error(-20990,'overflow aceito');
 exception when others then if sqlcode<>-20013 then raise; end if;
 end;
 begin
  h:=integertohex(-1); raise_application_error(-20990,'inteiro negativo aceito');
 exception when others then if sqlcode<>-20014 then raise; end if;
 end;
 expect(time_delta(date '2026-11-03',date '2026-11-03'),'00:00:00','duracao zero');
 expect(time_delta(date '2026-11-03',date '2026-11-04'+1/24),'25:00:00','duracao 25h');
 expect(time_delta(date '2026-11-04'+1/24,date '2026-11-03'),'25:00:00','ordem invertida');
 expect(time_delta(date '2026-11-03'+86399/86400,date '2026-11-04'),'00:00:01','meia-noite');
 expect(time_delta(null,date '2026-11-03'),null,'duracao null');
 startup_date(d);
 select startup_time into expected_start from v$instance;
 if d is null or d<>expected_start then raise_application_error(-20990,'startup'); end if;
 dbms_output.put_line('PASS: testes de conversao/duracao/startup da revisao 036.');
end;
/
