/*
===============================================================================
SCRIPT: db_rct81.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/db_rct81.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar rascunho de CREATE DATABASE 8i com SYSTEM/redo e autoextend.

FUNCIONAMENTO DETALHADO
  CREATE DB_TEMP, cursores de storage SYSTEM/datafiles/redo e DB_BLOCK_SIZE, gera REUSE/extent management/LOG_ARCHIVE_START, spool e DROP.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas/SO conforme limitações; ler todos
  os nomes e caminhos antes de qualquer teste em ambiente descartável.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLESPACES, DBA_DATA_FILES, V$LOG, V$LOGFILE, V$DATABASE, V$PARAMETER, DB_TEMP, DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DDL/commits confirmam transações; REUSE pode sobrescrever dados. Omite outros tablespaces/usuários/charset/configuração e parâmetros atuais. Buffers255 e file list podem truncar; histórico Oracle7/8 não garante compilação moderna.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema descartável; não usar saída como restore ou executar CREATE DATABASE sobre arquivos existentes.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  CRT_DB.SQL parcial com caminhos/tamanhos/REUSE e modo de archive legado.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cópia/restauração, DDL, estatísticas ou DML massivo
  conforme acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  LOCAL LOCAL SIZE corrigido para LOCAL UNIFORM SIZE; demais atributos/algoritmo preservados e não apresentados como backup completo. 
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
REM FUNCTION: SCRIPT FOR CREATING 8.1 DB FROM EXISTING DB
REM           This script must be run by a user with the DBA role.
REM           This script is intended to run with Oracle7 or 8.
REM           Running this script will in turn create a script to 
REM           rebuild the database.  This created 
REM           script, crt_db.sql,  is run by SQLDBA 
REM           Only preliminary testing of this script was performed.  
REM           Be sure to test it completely before relying on it.
REM M. Ault 2/18/99 DMR Consulting, REVELNET
REM
rem SET VERIFY OFF FEEDBACK OFF ECHO OFF PAGES 0
SET TERMOUT ON
PROMPT Creating db build script...
rem SET TERMOUT OFF; 
set echo on
CREATE TABLE db_temp
     (lineno NUMBER,  text VARCHAR2(255))
/
DECLARE
CURSOR get_block IS
     SELECT value 
          FROM v$parameter 
          WHERE name='db_block_size';
--
CURSOR ts_cursor IS 
     SELECT   initial_extent,
              next_extent,
              min_extents,
              max_extents,
              pct_increase,
              min_extlen,
              extent_management,
              allocation_type
            FROM    sys.dba_tablespaces
            WHERE tablespace_name = 'SYSTEM';
-- 
CURSOR df_cursor IS 
     SELECT    file_name,
               bytes,
               autoextensible,
               maxbytes,
               increment_by
      FROM     sys.dba_data_files
      WHERE    tablespace_name = 'SYSTEM'
      ORDER BY file_name;
--
CURSOR grp_cursor IS
     SELECT group# 
     FROM   v$log ORDER BY group#; 
--
CURSOR mem_cursor (grp_num number) IS
     SELECT   a.member, 
              b.bytes 
     FROM     v$logfile a, 
              v$log b
     WHERE    a.group#=grp_num
          AND a.group#=b.group#
     ORDER BY 
          member;
--
-- Variable Declarations
--
   block_size           NUMBER;
   lv_initial_extent    sys.dba_tablespaces.initial_extent%TYPE;
   lv_next_extent       sys.dba_tablespaces.next_extent%TYPE;
   lv_min_extents       sys.dba_tablespaces.min_extents%TYPE;
   lv_max_extents       sys.dba_tablespaces.max_extents%TYPE;
   lv_pct_increase      sys.dba_tablespaces.pct_increase%TYPE;
   lv_file_name         sys.dba_data_files.file_name%TYPE;
   lv_bytes             sys.dba_data_files.bytes%TYPE;
   lv_max_extend        sys.dba_data_files.maxbytes%TYPE;
   lv_ext_incr          sys.dba_data_files.increment_by%TYPE;
   lv_autoext           sys.dba_data_files.autoextensible%TYPE;
   lv_first_rec         BOOLEAN;
   lv_min_extlen        sys.dba_tablespaces.min_extlen%TYPE;
   lv_extent_man        sys.dba_tablespaces.extent_management%TYPE;
   lv_allocation        sys.dba_tablespaces.allocation_type%TYPE;
   sub_strg             VARCHAR2(20); 
   grp_member           v$logfile.member%TYPE;
   bytes                v$log.bytes%TYPE;
   db_name              VARCHAR2(8);
   db_string            VARCHAR2(255);
   db_lineno            NUMBER := 0;
   thrd                 NUMBER;
   grp                  NUMBER;
   sz                   NUMBER;
   begin_count          NUMBER;
   max_group            NUMBER;
--
-- Local use procedures
--
PROCEDURE write_out(p_line INTEGER, 
                 p_string VARCHAR2) IS
   BEGIN
    INSERT INTO db_temp (lineno,text) 
    VALUES (p_line,p_string);
   END;
--
-- Start of actual code
--
BEGIN
   SELECT MAX(group#) INTO max_group FROM v$log;
     db_lineno:=db_lineno+1;
   SELECT 'CREATE DATABASE '||name INTO db_string  
     FROM v$database;
     write_out(db_lineno,db_string);
     db_lineno:=db_lineno+1;
   SELECT 'CONTROLFILE REUSE' INTO db_string
     FROM dual;
     write_out(db_lineno,db_string);
     db_lineno:=db_lineno+1;
   SELECT 'LOGFILE ' INTO db_string 
     FROM dual;
     write_out(db_lineno,db_string);
COMMIT;
IF grp_cursor%ISOPEN 
THEN
     CLOSE grp_cursor;
     OPEN grp_cursor;
ELSE
     OPEN grp_cursor;
END IF;
LOOP
     FETCH grp_cursor INTO grp;
     EXIT WHEN grp_cursor%NOTFOUND;
     db_lineno:=db_lineno+1;
     db_string:= ' GROUP '||grp||' (';
     write_out(db_lineno,db_string);
     IF mem_cursor%ISOPEN THEN
          CLOSE mem_cursor;
          OPEN mem_cursor(grp);
     ELSE
          OPEN mem_cursor(grp);
     END IF;
     db_lineno:=db_lineno+1;
     begin_count:=db_lineno;
     LOOP
          FETCH mem_cursor INTO grp_member, bytes;
          EXIT when mem_cursor%NOTFOUND;
          IF begin_count=db_lineno THEN
               db_string:=chr(39)||grp_member||chr(39);
               write_out(db_lineno,db_string);
               db_lineno:=db_lineno+1;
          ELSE
               db_string:=' ,'||chr(39)||grp_member||chr(39);
               write_out(db_lineno,db_string);
               db_lineno:=db_lineno+1;
          END IF;
     END LOOP;
     db_lineno:=db_lineno+1;
     IF grp=max_group THEN
          db_string:=' ) SIZE '||bytes;
          write_out(db_lineno,db_string);
     ELSE
          db_string:=' ) SIZE '||bytes||',';
          write_out(db_lineno,db_string);
     END IF;
END LOOP;
OPEN get_block;
  FETCH get_block INTO block_size;
CLOSE get_block;
OPEN ts_cursor;
  FETCH ts_cursor INTO Lv_initial_extent,
              Lv_next_extent,
              Lv_min_extents,
              Lv_max_extents,
              Lv_pct_increase,
              Lv_min_extlen,
              Lv_extent_man,
              Lv_allocation;
lv_first_rec := TRUE;
CLOSE ts_cursor;
OPEN df_cursor;
      LOOP
         FETCH df_cursor INTO lv_file_name,
                              lv_bytes,
                              lv_autoext,
                              lv_max_extend,
                              lv_ext_incr;
         EXIT WHEN df_cursor%NOTFOUND;
         IF (lv_first_rec) THEN
            lv_first_rec := FALSE;
            db_string := 'DATAFILE ';
         ELSE
            db_string := db_string ||chr(10)|| ',';
         END IF;
         db_string:=db_string||chr(39)||lv_file_name||chr(39)||
                    ' SIZE '||to_char(lv_bytes) || ' REUSE';
         IF lv_autoext='YES' THEN
          IF lv_max_extend=0 THEN 
               sub_strg:=' MAXSIZE UNLIMITED';
          ELSE
               sub_strg:=' MAXSIZE '||TO_CHAR(lv_max_extend);
          END IF;
          IF lv_ext_incr != 0 THEN
           db_string:=db_string||chr(10)||' AUTOEXTEND ON NEXT '||
           to_char(lv_ext_incr*block_size)||sub_strg;
          END IF;
         END IF;
         IF lv_min_extlen != 0 AND lv_extent_man!='LOCAL' THEN
           db_string:=db_string||chr(10)||
          'MINIMUM EXTENT '||TO_CHAR(lv_min_extlen);
         END IF;
      END LOOP;
      CLOSE df_cursor;
         db_lineno := db_lineno + 1;
         write_out(db_lineno, db_string);
         db_lineno := db_lineno + 1;
      IF lv_extent_man!='LOCAL' THEN
         db_string := (' DEFAULT STORAGE (INITIAL ' ||
                      TO_CHAR(lv_initial_extent) ||
                      ' NEXT ' || lv_next_extent);
      ELSE
         db_string:=('EXTENT MANAGEMENT '||lv_extent_man);
       IF lv_allocation='UNIFORM' THEN
         db_string:=db_string||' UNIFORM SIZE ' 
         ||lv_initial_extent;
       ELSE
         db_string:=db_string||' AUTOALLOCATE';
       END IF;
      END IF;
         write_out(db_lineno, db_string);
         db_lineno := db_lineno + 1;
      IF lv_extent_man!='LOCAL' THEN
         db_string := (' MINEXTENTS ' ||
                      lv_min_extents ||
                      ' MAXEXTENTS ' || lv_max_extents);
         write_out(db_lineno, db_string);
         db_lineno := db_lineno + 1;
         db_string := (' PCTINCREASE ' ||
                      lv_pct_increase || ')');
         write_out(db_lineno, db_string);
      END IF;
COMMIT;
SELECT DECODE(value,'TRUE','ARCHIVELOG','FALSE','NOARCHIVELOG')
     INTO db_string FROM v$parameter WHERE name='log_archive_start';
     db_lineno:=db_lineno+1;
     write_out(db_lineno,db_string);
SELECT ';' INTO db_string from  dual;
     db_lineno:=db_lineno+1;
     write_out(db_lineno,db_string);
CLOSE mem_cursor;
CLOSE grp_cursor;
COMMIT;
END;
/
rem The next section could be converted to use
rem UTLFILE so the entire anonymous PL/SQL section
rem and this report section would become a stored
rem procedure, but to keep it generic I will leave as 
rem is.
COLUMN dbname NEW_VALUE db NOPRINT
SELECT name dbname FROM v$database;
SET HEADING OFF PAGES 0 VERIFY OFF RECSEP OFF
SPOOL rep_out\&db\crt_db.sql
COLUMN text FORMAT a80 WORD_WRAP
SELECT text 
FROM db_temp 
ORDER BY lineno;
SPOOL OFF
SET FEEDBACK ON VERIFY ON TERMOUT ON
DROP TABLE db_temp;
PROMPT Press enter to continue
SET VERIFY ON FEEDBACK ON PAGES 22 TERMOUT ON
CLEAR COLUMNS

