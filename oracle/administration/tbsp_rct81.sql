/*
===============================================================================
SCRIPT: tbsp_rct81.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _tablespace_scripts/tbsp_rct81.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar e executar RECREATE_TBSP usando TS_TEMP preexistente.

FUNCIONAMENTO DETALHADO
  Instala procedimento que insere fragmentos de DDL 8i na tabela, chama imediatamente, spool e mantém staging.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas conforme limitações individuais.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLESPACES, DBA_DATA_FILES, V$PARAMETER, TS_TEMP, V$DATABASE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Difere de TBSP1 por não criar/limpar TS_TEMP e executar objeto persistente; pode misturar dados antigos. Modelo LMT/DMT/REUSE incompleto para recursos modernos e block size padrão pode estar errado. DDL confirma transações.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório com TS_TEMP de contrato compatível e dados descartáveis.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Procedimento instalado, staging preenchido e CRT_TBSP.SQL.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos de criação, staging, autenticação, sessão
  ou código gerado descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Cláusula UNIFORM SIZE corrigida; chamada/estado persistente e todos os atributos preservados. 
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
REM TBSP_RCT81.SQL
REM
REM FUNCTION: SCRIPT FOR CREATING TABLESPACES
REM
REM FUNCTION: This script must be run by a user with the DBA role.
REM
REM This script is intended to run with 8i.
REM
REM FUNCTION: Running this script will in turn create a script to build
REM           all the tablespaces in the database.  This created script, 
REM           crt_tbsp.sql, can be run by any user with the DBA role 
REM           or with the 'CREATE TABLESPACE' system privilege.
REM
REM Only preliminary testing of this script was performed.  Be sure to
REM test it completely before relying on it.
REM
REM
rem SET VERIFY OFF TERMOUT OFF FEEDBACK OFF ECHO OFF PAGESIZE 0
SET TERMOUT ON
PROMPT 'Creating tablespace build script...' 
rem SET TERMOUT OFF;
rem

CREATE OR REPLACE PROCEDURE recreate_tbsp as
   CURSOR get_block IS
     SELECT value 
          FROM v$parameter 
          WHERE name='db_block_size';
   CURSOR ts_cursor IS 
     SELECT   tablespace_name,
              initial_extent,
              next_extent,
              min_extents,
              max_extents,
              pct_increase,
              min_extlen,
              logging,
              status,
              contents,
              extent_management,
              allocation_type,
              contents
            FROM    sys.dba_tablespaces
            WHERE tablespace_name != 'SYSTEM'
                  AND status != 'INVALID'
            ORDER BY tablespace_name;
   CURSOR df_cursor (c_ts VARCHAR2) IS 
     SELECT
               file_name,
               bytes,
               autoextensible,
               maxbytes,
               increment_by
      FROM     sys.dba_data_files
      WHERE    tablespace_name = c_ts
               and tablespace_name != 'SYSTEM'
      ORDER BY file_name;
--
   block_size           NUMBER;
   lv_tablespace_name   sys.dba_tablespaces.tablespace_name%TYPE;
   lv_initial_extent    sys.dba_tablespaces.initial_extent%TYPE;
   lv_next_extent       sys.dba_tablespaces.next_extent%TYPE;
   lv_min_extents       sys.dba_tablespaces.min_extents%TYPE;
   lv_max_extents       sys.dba_tablespaces.max_extents%TYPE;
   lv_pct_increase      sys.dba_tablespaces.pct_increase%TYPE;
   lv_status            sys.dba_tablespaces.status%TYPE;
   lv_file_name         sys.dba_data_files.file_name%TYPE;
   lv_bytes             sys.dba_data_files.bytes%TYPE;
   lv_max_extend        sys.dba_data_files.maxbytes%TYPE;
   lv_ext_incr          sys.dba_data_files.increment_by%TYPE;
   lv_autoext           sys.dba_data_files.autoextensible%TYPE;
   lv_contents          sys.dba_tablespaces.contents%TYPE;
   lv_first_rec         BOOLEAN;
   lv_string            VARCHAR2(2000);
   lv_lineno            NUMBER := 0;
   lv_min_extlen        sys.dba_tablespaces.min_extlen%TYPE;
   lv_logging           sys.dba_tablespaces.logging%TYPE;
   lv_extent_man        sys.dba_tablespaces.extent_management%TYPE;
   lv_allocation        sys.dba_tablespaces.allocation_type%TYPE;
   sub_strg             VARCHAR2(20); 
   PROCEDURE write_out(p_line INTEGER, p_name VARCHAR2, 
             p_string VARCHAR2) is
   BEGIN
     INSERT INTO ts_temp (lineno, ts_name, text) 
     VALUES (p_line, p_name, p_string);
   END;
BEGIN
   OPEN get_block;
   FETCH get_block INTO block_size;
   CLOSE get_block;
   OPEN ts_cursor;
   LOOP
      FETCH ts_cursor INTO lv_tablespace_name,
              Lv_initial_extent,
              Lv_next_extent,
              Lv_min_extents,
              Lv_max_extents,
              Lv_pct_increase,
              Lv_min_extlen,
              Lv_logging,
              Lv_status,
              Lv_contents,
              Lv_extent_man,
              Lv_allocation,
              lv_contents;
      EXIT WHEN ts_cursor%NOTFOUND;
      lv_lineno := 1;
      lv_string := ('CREATE TABLESPACE '||lower(lv_tablespace_name));
      lv_first_rec := TRUE;
      write_out(lv_lineno, lv_tablespace_name, lv_string);
      OPEN df_cursor(lv_tablespace_name);
      LOOP
         FETCH df_cursor INTO lv_file_name,
                              lv_bytes,
                              lv_autoext,
                              lv_max_extend,
                              lv_ext_incr;
         EXIT WHEN df_cursor%NOTFOUND;
         IF (lv_first_rec) THEN
            lv_first_rec := FALSE;
            lv_string := 'DATAFILE ';
         ELSE
            lv_string := lv_string || ',';
         END IF;
         lv_string:=lv_string||''''||lv_file_name||''''||
                    ' SIZE '||to_char(lv_bytes) || ' REUSE';
         IF lv_autoext='YES' THEN
          IF lv_max_extend=0 THEN 
               sub_strg:='MAXSIZE UNLIMITED';
          ELSE
               sub_strg:=' MAXSIZE '||TO_CHAR(lv_max_extend);
          END IF;
          IF lv_ext_incr != 0 THEN
           lv_string:=lv_string||chr(10)||' AUTOEXTEND ON NEXT '||
           to_char(lv_ext_incr*block_size)||sub_strg;
          END IF;
         END IF;
         IF lv_min_extlen != 0 AND lv_extent_man!='LOCAL' THEN
           lv_string:=lv_string||chr(10)||
          'MINIMUM EXTENT '||TO_CHAR(lv_min_extlen);
         END IF;
      END LOOP;
      CLOSE df_cursor;
         lv_lineno := lv_lineno + 1;
         write_out(lv_lineno, lv_tablespace_name, lv_string);
         lv_lineno := lv_lineno + 1;
         lv_string := ('   '||lv_contents);
         write_out(lv_lineno, lv_tablespace_name, lv_string);
         lv_lineno := lv_lineno + 1;
      IF lv_extent_man!='LOCAL' THEN
         lv_string := (' DEFAULT STORAGE (INITIAL ' ||
                      TO_CHAR(lv_initial_extent) ||
                      ' NEXT ' || lv_next_extent);
      ELSE
         Lv_string:=('EXTENT MANAGEMENT '||lv_extent_man);
       IF lv_allocation='UNIFORM' THEN
         Lv_string:=lv_string||' UNIFORM SIZE '||lv_initial_extent;
       ELSE
         Lv_string:=lv_string||' AUTOALLOCATE';
       END IF;
      END IF;
         write_out(lv_lineno, lv_tablespace_name, lv_string);
         lv_lineno := lv_lineno + 1;
      IF lv_extent_man!='LOCAL' THEN
         lv_string := (' MINEXTENTS ' ||
                      lv_min_extents ||
                      ' MAXEXTENTS ' || lv_max_extents);
         write_out(lv_lineno, lv_tablespace_name, lv_string);
         lv_lineno := lv_lineno + 1;
         lv_string := (' PCTINCREASE ' ||
                      lv_pct_increase || ')');
         write_out(lv_lineno, lv_tablespace_name, lv_string);
      END IF;
         lv_lineno := lv_lineno + 1;
         lv_string := ('   '||lv_logging);
         write_out(lv_lineno, lv_tablespace_name, lv_string);
         lv_lineno := lv_lineno + 1;
         lv_string := ('   '||lv_status);
         write_out(lv_lineno, lv_tablespace_name, lv_string);
         lv_lineno := lv_lineno + 1;
         lv_string:='/';
         write_out(lv_lineno, lv_tablespace_name, lv_string);
         lv_lineno := lv_lineno + 1;
         lv_string:=chr(10);
         write_out(lv_lineno, lv_tablespace_name, lv_string);
   END LOOP;
   CLOSE ts_cursor;
END;
/
show err
EXECUTE recreate_tbsp;
COLUMN dbname NEW_VALUE db NOPRINT
SELECT name dbname FROM v$database;
SPOOL rep_out\&db\crt_tbsp.sql
SET PAGES 0
COLUMN text FORMAT a80 WORD_WRAP
SELECT   text
FROM     ts_temp
ORDER BY ts_name, lineno;
SPOOL OFF;
SET VERIFY ON TERMOUT ON HEADING ON FEEDBACK ON
SET PAGESIZE 22 LINES 80
CLEAR COLUMNS

