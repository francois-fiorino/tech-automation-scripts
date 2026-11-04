/*
===============================================================================
SCRIPT: db_rct91a.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/db_rct91a.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Instalar/executar RECREATE_DB2 que grava CREATE DATABASE 9i em arquivo de servidor.

FUNCIONAMENTO DETALHADO
  DROP/CREATE LINENO_SEQ, coleção de linhas em memória, cursores SYSTEM/undo/temp/redo/charset/timezone/limites e UTL_FILE.FOPEN Windows.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas/SO conforme limitações; ler todos
  os nomes e caminhos antes de qualquer teste em ambiente descartável.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  LINENO_SEQ, UTL_FILE, DBA_TABLESPACES, DBA_DATA_FILES, DBA_TEMP_FILES, DATABASE_PROPERTIES, V$PARAMETER, V$LOG, V$LOGFILE, V$DATABASE, V$CONTROLFILE_RECORD_SECTION

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DDL confirma transações; arquivo sobrescrito no servidor e handler pode ocultar falha. Linhas255/256 e coleção indexada por sequência supõem índices contíguos. REUSE na saída pode destruir banco. LOG_ARCHIVE_START/layout9i não homologados modernos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório com diretório autorizado; não sobrescrever rebuild_db91.sql útil.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Procedimento persistente e arquivo d:\oracle\sql_scripts\rebuild_db91.sql quando chamado ao final.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cópia/restauração, DDL, estatísticas ou DML massivo
  conforme acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  DB_BLOCK_SIZE antecipado, UNIFORM SIZE e ordenação de grupos corrigidos; flag de primeiro member passa a avançar para gerar vírgulas nos demais members. Fluxo UTL_FILE e modelo completo preservados. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 043 — 04/11/2026
  Correções e melhorias: Bloco vazio recebe NULL; MAXSIZE ampliado; FIRST/NEXT para coleção esparsa; UTL_FILE fecha com proteção e relança erro; cursor timezone fechado. Interrupção SQL antes de criar sequência/rotina.
  Limitações e pendências: DROP da sequência continua destrutivo e pode invalidar dependentes. Caminho UTL_FILE_DIR Windows/arquivo W e linhas255/256 mantidos; LOG_ARCHIVE_START obsoleto, limites/undo/temp/REUSE não compõem restore homologado.
  Homologação necessária: Sequência existente/ausente, coleção vazia/índices com lacunas, erro de arquivo e parâmetros ausentes; inspecionar saída sem executar CREATE DATABASE.
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

/*  */
REM FUNCTION: SCRIPT FOR CREATING 9.1 DB FROM EXISTING DB
REM           This script must be run by a user with the DBA role.
REM           This script is intended to run with Oracle9i.
REM           Running this script will in turn create a script to 
REM           rebuild the database.  This created 
REM           script, crt_db91.sql,  is run by SQLDBA
REM           Only preliminary testing of this script was performed.
REM           Be sure to test it completely before relying on it.
REM M. Ault 8/23/01 Burleson Consulting Consulting
REM
rem SET VERIFY OFF FEEDBACK OFF ECHO OFF PAGES 0
SET TERMOUT ON
PROMPT Creating db build script...
DROP SEQUENCE lineno_seq;
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
CREATE SEQUENCE lineno_seq MINVALUE 1 INCREMENT BY 1 NOCACHE; 
set verify on feedback on echo on
CREATE OR REPLACE PROCEDURE recreate_db2 AS
--
lineno_count INTEGER;
output_index BINARY_INTEGER;
file_handle UTL_FILE.FILE_TYPE;
--
TYPE db_temp IS TABLE OF VARCHAR2(255)
 INDEX BY BINARY_INTEGER;
db_table DB_TEMP;
--
CURSOR get_block IS
     SELECT value
          FROM v$parameter
          WHERE name='db_block_size';
--
CURSOR sys_ts_cursor IS
     SELECT   initial_extent,
              next_extent,
              min_extents,
              max_extents,
              pct_increase,
              min_extlen,
              extent_management,
              allocation_type
            FROM    dba_tablespaces
            WHERE tablespace_name = 'SYSTEM';
--
CURSOR undo_ts_cursor IS
     SELECT   initial_extent,
              next_extent,
              min_extents,
              max_extents,
              pct_increase,
              min_extlen,
              extent_management,
              allocation_type,
              tablespace_name
            FROM    dba_tablespaces,v$parameter
            WHERE name='undo_tablespace'
            AND tablespace_name = value;
--
CURSOR temp_ts_cursor IS
     SELECT   initial_extent,
              next_extent,
              min_extents,
              max_extents,
              pct_increase,
              min_extlen,
              extent_management,
              allocation_type,
              tablespace_name
            FROM    dba_tablespaces, database_properties
            WHERE   property_name='DEFAULT_TEMP_TABLESPACE'
            AND     property_value = tablespace_name;
--
CURSOR sys_df_cursor IS
     SELECT    file_name,
               bytes,
               autoextensible,
               maxbytes,
               increment_by
      FROM     dba_data_files
      WHERE    tablespace_name = 'SYSTEM'
      ORDER BY file_id;
--
CURSOR undo_df_cursor IS
     SELECT    file_name,
               bytes,
               autoextensible,
               maxbytes,
               increment_by
      FROM     dba_data_files, v$parameter
      WHERE    name='undo_tablespace'
      AND      tablespace_name = value
      ORDER BY file_id;
--
CURSOR temp_df_cursor IS
     SELECT    a.file_name,
               a.bytes,
               a.autoextensible,
               a.maxbytes,
               a.increment_by
      FROM     dba_temp_files a, database_properties b
      WHERE    b.property_name='DEFAULT_TEMP_TABLESPACE'
      AND      a.tablespace_name=b.property_value
      ORDER BY file_id;
--
CURSOR get_timezone IS
      SELECT   property_value
      FROM     database_properties
      WHERE    property_name='DBTIMEZONE';
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
CURSOR get_char_sets IS
     SELECT   property_name,property_value
     FROM     database_properties
     WHERE    property_name IN ('NLS_CHARACTERSET','NLS_NCHAR_CHARACTERSET');
--
CURSOR get_max_values IS
     SELECT type, records_total
     FROM  v$controlfile_record_section
     WHERE type in ('DATABASE','REDO LOG','DATAFILE','LOG HISTORY');
--
-- Variable Declarations
--
   block_size           NUMBER;
   lv_initial_extent    dba_tablespaces.initial_extent%TYPE;
   lv_next_extent       dba_tablespaces.next_extent%TYPE;
   lv_min_extents       dba_tablespaces.min_extents%TYPE;
   lv_max_extents       dba_tablespaces.max_extents%TYPE;
   lv_pct_increase      dba_tablespaces.pct_increase%TYPE;
   lv_file_name         dba_data_files.file_name%TYPE;
   lv_bytes             dba_data_files.bytes%TYPE;
   lv_max_extend        dba_data_files.maxbytes%TYPE;
   lv_ext_incr          dba_data_files.increment_by%TYPE;
   lv_autoext           dba_data_files.autoextensible%TYPE;
   lv_first_rec         BOOLEAN;
   lv_min_extlen        dba_tablespaces.min_extlen%TYPE;
   lv_extent_man        dba_tablespaces.extent_management%TYPE;
   lv_allocation        dba_tablespaces.allocation_type%TYPE;
   lv_ts_name		dba_tablespaces.tablespace_name%TYPE;
   lv_timezone		database_properties.property_value%TYPE;
   lv_char_set		database_properties.property_value%TYPE;
   lv_type		database_properties.property_name%TYPE;
   lv_max_var		VARCHAR2(15);
   lv_max_val           NUMBER;
   sub_strg             VARCHAR2(128);
   grp_member           v$logfile.member%TYPE;
   bytes                v$log.bytes%TYPE;
   db_name              VARCHAR2(8);
   db_string            VARCHAR2(255);
   thrd                 NUMBER;
   grp                  NUMBER;
   sz                   NUMBER;
   begin_count          NUMBER;
   max_group            NUMBER;
--
-- Local use procedures
--
PROCEDURE write_out(
                 p_string VARCHAR2) IS
   BEGIN
    SELECT lineno_seq.nextval into lineno_count from dual;
    SELECT p_string INTO db_table (lineno_count)
    FROM dual; 
   END;
--
-- Start of actual code
--
BEGIN
BEGIN
   SELECT MAX(group#) INTO max_group FROM sys.v$log;
   SELECT 'CREATE DATABASE '||name INTO db_string
     FROM sys.v$database;
     write_out(db_string);
   SELECT 'CONTROLFILE REUSE' INTO db_string
     FROM dual;
     write_out(db_string);
END;
BEGIN
OPEN get_max_values;
LOOP
     FETCH get_max_values INTO lv_max_var,lv_max_val;
     EXIT WHEN get_max_values%NOTFOUND;
     IF lv_max_var='DATABASE' THEN
      lv_max_var:='MAXINSTANCES';
      ELSIF lv_max_var = 'REDO LOG' THEN
      lv_max_var:='MAXLOGFILES';
      ELSIF lv_max_var = 'LOG HISTORY' THEN
      lv_max_var:='MAXLOGHISTORY';
      ELSIF lv_max_var = 'DATAFILE' THEN
      lv_max_var:='MAXDATAFILES';
      END IF;
     db_string:=lv_max_var||' '||to_char(lv_max_val);
     write_out(db_string);
END LOOP;
CLOSE get_max_values;
END;
BEGIN
OPEN get_block;
  FETCH get_block INTO block_size;
CLOSE get_block;
OPEN sys_ts_cursor;
  FETCH sys_ts_cursor INTO Lv_initial_extent,
              Lv_next_extent,
              Lv_min_extents,
              Lv_max_extents,
              Lv_pct_increase,
              Lv_min_extlen,
              Lv_extent_man,
              Lv_allocation;
lv_first_rec := TRUE;
CLOSE sys_ts_cursor;
OPEN sys_df_cursor;
      LOOP
         FETCH sys_df_cursor INTO lv_file_name,
                              lv_bytes,
                              lv_autoext,
                              lv_max_extend,
                              lv_ext_incr;
         EXIT WHEN sys_df_cursor%NOTFOUND;
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
      CLOSE sys_df_cursor;
         write_out(db_string);
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
         write_out(db_string);
      IF lv_extent_man!='LOCAL' THEN
         db_string := (' MINEXTENTS ' ||
                      lv_min_extents ||
                      ' MAXEXTENTS ' || lv_max_extents);
         write_out(db_string);
         db_string := (' PCTINCREASE ' ||
                      lv_pct_increase || ')');
         write_out(db_string);
      END IF;
END;
BEGIN
   SELECT MAX(group#) INTO max_group FROM sys.v$log;
   SELECT 'LOGFILE ' INTO db_string
     FROM dual;
     write_out(db_string);

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
     db_string:= ' GROUP '||grp||' (';
     write_out(db_string);
     IF mem_cursor%ISOPEN THEN
          CLOSE mem_cursor;
          OPEN mem_cursor(grp);
     ELSE
          OPEN mem_cursor(grp);
     END IF;
     begin_count:=0;
     LOOP
          FETCH mem_cursor INTO grp_member, bytes;
          EXIT when mem_cursor%NOTFOUND;
          IF begin_count=0 THEN
               db_string:=chr(39)||grp_member||chr(39);
               write_out(db_string);
          begin_count:=1;
          ELSE
               db_string:=' ,'||chr(39)||grp_member||chr(39);
               write_out(db_string);
          END IF;
     END LOOP;
     IF grp=max_group THEN
          db_string:=' ) SIZE '||bytes;
          write_out(db_string);
     ELSE
          db_string:=' ) SIZE '||bytes||',';
          write_out(db_string);
     END IF;
END LOOP;
END;
BEGIN
 NULL; -- bloco historico sem operacao
END;
BEGIN
OPEN undo_ts_cursor;
  FETCH undo_ts_cursor INTO Lv_initial_extent,
              Lv_next_extent,
              Lv_min_extents,
              Lv_max_extents,
              Lv_pct_increase,
              Lv_min_extlen,
              Lv_extent_man,
              Lv_allocation,
              LV_ts_name;
lv_first_rec := TRUE;
CLOSE undo_ts_cursor;
OPEN undo_df_cursor;
      LOOP
         FETCH undo_df_cursor INTO lv_file_name,
                              lv_bytes,
                              lv_autoext,
                              lv_max_extend,
                              lv_ext_incr;
         EXIT WHEN undo_df_cursor%NOTFOUND;
         IF (lv_first_rec) THEN
            lv_first_rec := FALSE;
            db_string := 'UNDO TABLESPACE '||lv_ts_name||' DATAFILE ';
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
      CLOSE undo_df_cursor;
         write_out(db_string);
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
         write_out(db_string);
      IF lv_extent_man!='LOCAL' THEN
         db_string := (' MINEXTENTS ' ||
                      lv_min_extents ||
                      ' MAXEXTENTS ' || lv_max_extents);
         write_out(db_string);
         db_string := (' PCTINCREASE ' ||
                      lv_pct_increase || ')');
         write_out(db_string);
      END IF;
END;
BEGIN
OPEN temp_ts_cursor;
  FETCH temp_ts_cursor INTO Lv_initial_extent,
              Lv_next_extent,
              Lv_min_extents,
              Lv_max_extents,
              Lv_pct_increase,
              Lv_min_extlen,
              Lv_extent_man,
              Lv_allocation,
              LV_ts_name;
lv_first_rec := TRUE;
CLOSE temp_ts_cursor;
OPEN temp_df_cursor;
      LOOP
         FETCH temp_df_cursor INTO lv_file_name,
                              lv_bytes,
                              lv_autoext,
                              lv_max_extend,
                              lv_ext_incr;
         EXIT WHEN temp_df_cursor%NOTFOUND;
         IF (lv_first_rec) THEN
            lv_first_rec := FALSE;
            db_string := 'DEFAULT TEMPORARY TABLESPACE '||lv_ts_name||' TEMPFILE ';
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
      CLOSE temp_df_cursor;
         write_out(db_string);
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
         write_out(db_string);
      IF lv_extent_man!='LOCAL' THEN
         db_string := (' MINEXTENTS ' ||
                      lv_min_extents ||
                      ' MAXEXTENTS ' || lv_max_extents);
         write_out(db_string);
         db_string := (' PCTINCREASE ' ||
                      lv_pct_increase || ')');
         write_out(db_string);
      END IF;
END;
BEGIN
OPEN get_char_sets;
LOOP
  FETCH get_char_sets INTO lv_type,lv_char_set;
  EXIT WHEN get_char_sets%NOTFOUND;
  IF lv_type='NLS_CHARACTERSET' THEN
    db_string:='CHARACTER SET '||lv_char_set;
  ELSE
    db_string:='NATIONAL CHARACTER SET '||lv_char_set;
  END IF;
  write_out(db_string);
END LOOP;
CLOSE get_char_sets;
END;
BEGIN
OPEN get_timezone;
FETCH get_timezone into lv_timezone;
CLOSE get_timezone;
     db_string:='SET TIME_ZONE ='||chr(39)||lv_timezone||chr(39);
     write_out(db_string);
END;
BEGIN
SELECT DECODE(value,'TRUE','ARCHIVELOG','FALSE','NOARCHIVELOG')
     INTO db_string FROM v$parameter WHERE name='log_archive_start';
     write_out(db_string);
SELECT ';' INTO db_string from  dual;
     write_out(db_string);
CLOSE mem_cursor;
CLOSE grp_cursor;
END;
BEGIN
 file_handle:=UTL_FILE.FOPEN('d:\oracle\sql_scripts\','rebuild_db91.sql','W',256);
 output_index := db_table.FIRST;
 WHILE output_index IS NOT NULL LOOP
  UTL_FILE.PUT_LINE(file_handle,db_table(output_index));
  output_index := db_table.NEXT(output_index);
 END LOOP;
 UTL_FILE.FCLOSE(file_handle);
EXCEPTION
WHEN others THEN
 BEGIN
  IF UTL_FILE.IS_OPEN(file_handle) THEN UTL_FILE.FCLOSE(file_handle); END IF;
 EXCEPTION WHEN OTHERS THEN NULL; -- preservar erro original
 END;
 RAISE;
END;
END;
/
show error
execute recreate_db2;
