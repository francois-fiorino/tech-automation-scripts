/*
===============================================================================
SCRIPT: insert_user.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / misc_scripts/insert_user.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar gerador fraco de senhas e rotinas de criação em lote a partir de USER_TEMP.

FUNCIONAMENTO DETALHADO
  GEN_PWORD usa timer/pi/seis letras; CREATE_USER aplica CREATE/GRANT, grava senha clara em staging e COMMIT; INSERT_USERS percorre ausentes.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS de criação/execução/consulta e permissões administrativas
  conforme limitações; não instalar variantes sobre objetos de trabalho. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado pelo chamador (não configurado aqui).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  USER_TEMP(CUID/PWORD), DBA_USERS, V$TIMER, DBMS_SQL, DBMS_OUTPUT, USERS/TEMP

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE USER/GRANT/CREATE PROCEDURE/DML diretos. Senhas curtas/previsíveis, SQL sem validação e staging claro são inseguros. INSERT_USERS chama CREATE_USER com um argumento apesar de três obrigatórios: não compila. Def_role/profile não podem ser inferidos; buffers/cleanup exigem revisão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Revisão somente em laboratório sem credenciais reais.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Rotinas criadas se compilação compatível; chamadas podem criar contas e registrar senhas claras.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: DDL/DML, staging, autenticação ou efeitos da saída
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código completo preservado com erro de contrato explícito; não escolhidas role/profile arbitrárias nem geradas contas/senhas. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 043 — 04/11/2026
  Correções e melhorias: EXIT incondicional antes de instalar gerador fraco e rotinas de provisionamento.
  Limitações e pendências: CREATE_USER exige3argumentos mas INSERT_USERS passa1; roles/profile não definidos. Senha6 previsível e gravação clara permanecem só como código histórico inacessível pelo fluxo normal.
  Homologação necessária: Confirmar barreira antes de CREATE; definir contrato de provisionamento seguro sem escolher roles/profile ou publicar credenciais.
  Parâmetros/execução: contratos acima e corpo histórico; somente laboratório.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral/análise estática; sem compilação ou execução Oracle,
  Windows, escrita de arquivo no servidor, backup/recovery ou alteração de contas.

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
PROMPT BLOQUEADO: provisionamento legado inseguro; somente revisao.
EXIT FAILURE ROLLBACK


/*  */
-- this requires a user_temp table that has been pre-loaded with:
-- cuid varchar2(6) (common userid - or username) the user to be created and a
-- pword varchar2(6) column for a generated password.
-- Will generate a password and load into the user_temp field pword
CREATE OR REPLACE FUNCTION gen_pword RETURN VARCHAR2 AS
   pi        NUMBER := 3.141592653589793238462643 ;
   seed      NUMBER ;
   pwd       VARCHAR2(6);
   pwd_len   NUMBER := 6;          /* length of password */
BEGIN
   dbms_output.enable(1000000);
   SELECT TO_NUMBER(TO_CHAR(hsecs)) / 8640000 INTO seed FROM v$timer ; /* 0<= seed  < 1 */
   pwd := NULL ;
       FOR  j  IN 1..pwd_len LOOP
          seed := POWER(pi + seed,5)  - TRUNC (POWER(pi + seed,5) );
          pwd := pwd || CHR( 64 + 1 + TRUNC (seed * 26)) ;
       END LOOP;
--       dbms_output.put_line (pwd);
RETURN pwd;
END;
/
show err

CREATE OR REPLACE PROCEDURE create_user(username IN VARCHAR2, def_role IN VARCHAR2, def_profile IN VARCHAR2) IS
def_tbsp VARCHAR2(20):='USERS';
tmp_tbsp VARCHAR2(20):='TEMP';
cur INTEGER;
row_proc NUMBER;
comm_line VARCHAR2(200);
pword VARCHAR2(6);
BEGIN
 pword:=gen_pword;
 dbms_output.put_line(comm_line);
--
 comm_line:='CREATE USER '||username||' IDENTIFIED BY '||pword||
  ' DEFAULT TABLESPACE '||def_tbsp||
  ' TEMPORARY TABLESPACE '||tmp_tbsp||
  ' QUOTA UNLIMITED ON '||def_tbsp||
  ' PROFILE '||def_profile;
 cur:=dbms_sql.open_cursor;
 dbms_sql.parse(cur,comm_line,dbms_sql.v7);
 row_proc:=dbms_sql.execute(cur);
 dbms_sql.close_cursor(cur);
--
 comm_line:='GRANT CREATE SESSION,'||def_role||' TO '||username;
 dbms_output.put_line(comm_line);
 cur:=dbms_sql.open_cursor;
 dbms_sql.parse(cur,comm_line,dbms_sql.v7);
 row_proc:=dbms_sql.execute(cur);
 dbms_sql.close_cursor(cur);
--
 comm_line:='UPDATE USER_TEMP SET pword='||CHR(39)||pword||CHR(39)||
  'WHERE cuid='||CHR(39)||username||CHR(39);
 cur:=dbms_sql.open_cursor;
 dbms_sql.parse(cur,comm_line,dbms_sql.v7);
 row_proc:=dbms_sql.execute(cur);
 dbms_sql.close_cursor(cur);
 COMMIT;
--
END;
/
show err

CREATE OR REPLACE PROCEDURE insert_users AS
CURSOR get_user_record IS
 SELECT upper(cuid), pword 
 FROM user_temp where pword is null;
user_rec user_temp%rowtype;
--
CURSOR check_db_user (cuid IN VARCHAR2) IS
 SELECT COUNT(*) FROM dba_users 
 WHERE UPPER(cuid)=username;
user_count NUMBER;
--
BEGIN
OPEN get_user_record;
--
LOOP
 FETCH get_user_record INTO user_rec;
 EXIT WHEN get_user_record%NOTFOUND;
 dbms_output.put_line('Processing CUID: '||user_rec.cuid);
--
 OPEN check_db_user(user_rec.cuid);
 FETCH check_db_user INTO user_count;
 CLOSE check_db_user;
--
  IF user_count=0 THEN
  dbms_output.put_line('User: '||user_rec.CUID||' does not exist');
  create_user(user_rec.cuid);
--
   COMMIT;
--
 END IF;
--
END LOOP;
--
END;
/
show err

