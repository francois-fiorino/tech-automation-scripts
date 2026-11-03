/*
===============================================================================
SCRIPT: exe_fprc.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / misc_scripts/EXE_FPRC.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar rotina P_DISCO_MONTH_END de habilitação/desabilitação de roles Discoverer.

FUNCIONAMENTO DETALHADO
  Lê EUL_EUL_USERS, altera senha de roles ou NOT IDENTIFIED e muda default roles de contas por SQL dinâmico, conforme ENABLE/DISABLE.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas conforme limitações individuais. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  EUL_EUL_USERS no schema informado, DBA_USERS, DBA_ROLE_PRIVS, V$TIMER, EXECUTE IMMEDIATE, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE/ALTER ROLE/ALTER USER/grants diretos. Gerador de seis letras previsível; exclusões/listas concatenadas e quoting incorreto podem invalidar SQL/injetar. DEFAULT exclude literal NULL pode excluir tudo por NOT IN. Handler oculta erros após alterações parciais, sem rollback de DDL.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente clone Discoverer isolado; nunca usar credenciais reais.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Procedimento criado; chamada pode alterar autenticação/delegação de roles e defaults de usuários.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos de criação, staging, autenticação, sessão
  ou código gerado descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Rotina completa preservada com dependências de negócio explícitas; nenhuma role/conta alterada. 
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
create or replace PROCEDURE  p_disco_month_end (    
schema IN VARCHAR2 DEFAULT USER,     
status IN VARCHAR2 DEFAULT 'ENABLE', 
exclude IN VARCHAR2 DEFAULT 'NULL')  
AS    
--    
TYPE EuCursor IS REF CURSOR;   
c_u    EuCursor;     
c_g    EuCursor;     
c_r    EuCursor;     
--    
v_sql_stmt  VARCHAR2(1000);     
v_sql_stmt2 VARCHAR2(1000);     
v_sql_stmt3 VARCHAR2(1000);     
v_sql_stmt4 VARCHAR2(1000);     
v_sql_stmt5 VARCHAR2(1000);     
--    
v_eu_user   VARCHAR2(64); 
v_pword     VARCHAR2(6);  
v_action    VARCHAR2(10); 
v_owner     VARCHAR2(64); 
v_granted	   dba_role_privs.grantee%TYPE; 
v_g_role    dba_role_privs.granted_role%TYPE;  
v_excluded_users VARCHAR2(256); 
v_exclude_role   VARCHAR2(256); 
--    
e_invalid_status EXCEPTION;    
--    
FUNCTION f_gen_pword 
RETURN VARCHAR2 AS   
pi_constant  NUMBER := 3.141592653589793238462643 ; 
v_seed 	NUMBER ;     
v_pwd  	VARCHAR2(6); 
pwd_len_constant   	NUMBER := 6;     /* length of password */ 
BEGIN 
--dbms_output.enable(1000000); 
SELECT TO_NUMBER(TO_CHAR(hsecs)) / 8640000 INTO v_seed FROM v$timer ;  /*  0<= seed  < 1 */  
v_pwd := NULL ; 
FOR  j  IN 1..pwd_len_constant LOOP  
v_seed := POWER(pi_constant + v_seed,5)  - TRUNC (POWER(pi_constant + v_seed,5) ); 
v_pwd := v_pwd || CHR( 64 + 1 + TRUNC (v_seed * 26)) ;   
END LOOP;  
-- dbms_output.put_line (v_pwd);     
RETURN v_pwd;   
END f_gen_pword;     
--    
BEGIN 
v_exclude_role:=chr(39)||'DW_DISRPT_ADMIN_SELECT'||chr(39)||','||chr(39)||'DEFAULT_BUSINESS'||chr(39); 
v_action:=UPPER(status);  
v_owner:=UPPER(schema);   
v_excluded_users:=UPPER(exclude);    
--    
v_sql_stmt:='SELECT eu_username FROM '||v_owner||'.eul_eul_users   
WHERE eu_role_flag=1 and eu_username not in ('||v_exclude_role||')';
-- dbms_output.put_line('v_sql_stmt: '||v_sql_stmt);  
--    
OPEN c_u FOR v_sql_stmt;  
--    
IF v_action='DISABLE' THEN     
--    
LOOP  
FETCH c_u INTO v_eu_user; 
EXIT WHEN c_u%NOTFOUND;   
v_pword:=f_gen_pword;     
--    
v_sql_stmt2:='ALTER ROLE '||v_eu_user||' IDENTIFIED BY '||v_pword; 
--    
EXECUTE IMMEDIATE v_sql_stmt2; 
-- DBMS_OUTPUT.PUT_LINE('sql_stmt2:'||v_sql_stmt2); 
END LOOP;  
--    
v_sql_stmt3:='select distinct username    
from dba_users,dba_role_privs  
where (username not in ('||chr(39)||v_excluded_users||chr(39)||')) AND (username=grantee and 
granted_role in (select eu_username from '||v_owner||'.eul_eul_users    
WHERE eu_username not in ('||chr(39)||v_exclude_role||chr(39)||')))';   
--    
-- DBMS_OUTPUT.PUT_LINE('sql_stmt3:got here'); 
OPEN c_g FOR v_sql_stmt3; 
--    
LOOP  
FETCH c_g INTO v_granted; 
EXIT WHEN c_g%NOTFOUND;   
--    
v_sql_stmt4:='ALTER USER '||v_granted||' DEFAULT ROLE ALL EXCEPT ';     
--    
v_sql_stmt5:='SELECT distinct granted_role FROM dba_role_privs,'||v_owner||'.eul_eul_users   
WHERE (grantee='||chr(39)||v_granted||chr(39)||     
' AND granted_role IN (SELECT eu_username FROM '||v_owner||'.eul_eul_users   
WHERE eu_username not in ('||chr(39)||v_exclude_role||chr(39)||')))     
OR grantee='||chr(39)||v_granted||chr(39)||' AND default_role='||chr(39)||'NO'||chr(39);     
--    
-- DBMS_OUTPUT.PUT_LINE('sql_stmt5:got_here'); 
OPEN c_r FOR v_sql_stmt5; 
FETCH c_r INTO v_g_role;  
--    
v_sql_stmt4:=v_sql_stmt4||v_g_role;  
--    
LOOP  
FETCH c_r INTO v_g_role;  
EXIT WHEN c_r%NOTFOUND;   
--    
v_sql_stmt4:=v_sql_stmt4||','||v_g_role;  
--    
END LOOP;  
-- DBMS_OUTPUT.PUT_LINE(v_sql_stmt4);     
EXECUTE IMMEDIATE v_sql_stmt4; 
CLOSE c_r; 
END LOOP;  
CLOSE c_g; 
--    
ELSIF v_action='ENABLE' THEN   
--    
LOOP  
FETCH c_u INTO v_eu_user; 
EXIT WHEN c_u%NOTFOUND;   
--    
v_sql_stmt2:='ALTER ROLE '||v_eu_user||' NOT IDENTIFIED';     
--    
-- DBMS_OUTPUT.PUT_LINE('sql_stmt2:'||v_sql_stmt2); 
EXECUTE IMMEDIATE v_sql_stmt2; 
--    
END LOOP;  
--    
v_sql_stmt3:='select distinct username    
from dba_users,dba_role_privs  
where (username not in ('||chr(39)||v_excluded_users||chr(39)||')) AND (username=grantee and 
granted_role in (select eu_username from '||v_owner||'.eul_eul_users    
WHERE eu_username not in ('||chr(39)||v_exclude_role||chr(39)||')))';   
--    
-- DBMS_OUTPUT.PUT_LINE('sql_stmt3:got_here'); 
OPEN c_g FOR v_sql_stmt3; 
--    
LOOP  
FETCH c_g INTO v_granted; 
EXIT WHEN c_g%NOTFOUND;   
--    
v_sql_stmt4:='ALTER USER '||v_granted||' DEFAULT ROLE '; 
--    
v_sql_stmt5:='SELECT distinct granted_role FROM dba_role_privs,'||v_owner||'.eul_eul_users   
WHERE (grantee='||chr(39)||v_granted||chr(39)||     
' AND granted_role IN (SELECT eu_username FROM '||v_owner||'.eul_eul_users   
WHERE eu_username not in ('||chr(39)||v_exclude_role||chr(39)||')))     
OR grantee='||chr(39)||v_granted||chr(39)||' AND default_role='||chr(39)||'YES'||chr(39);    
--    
-- DBMS_OUTPUT.PUT_LINE('sql_stmt5:got_here'); 
OPEN c_r FOR v_sql_stmt5; 
--    
FETCH c_r INTO v_g_role;  
--    
v_sql_stmt4:=v_sql_stmt4||v_g_role;  
--    
LOOP  
FETCH c_r INTO v_g_role;  
EXIT WHEN c_r%NOTFOUND;   
--    
v_sql_stmt4:=v_sql_stmt4||','||v_g_role;  
--    
END LOOP;  
-- DBMS_OUTPUT.PUT_LINE('SQL_stmt4:'||v_granted||'got here'); 
EXECUTE IMMEDIATE v_sql_stmt4; 
CLOSE c_r; 
END LOOP;  
--    
CLOSE c_g; 
--    
ELSE  
RAISE e_invalid_status;   
END IF;    
--    
CLOSE c_u; 
--    
EXCEPTION  
WHEN e_invalid_status THEN     
  DBMS_OUTPUT.PUT_LINE('Status Change Request '||v_action||' invalid');   
WHEN others THEN     
  DBMS_OUTPUT.PUT_LINE('Error: '||sqlerrm); 
--    
END;  
/     
