/*
===============================================================================
SCRIPT: tbsp_it_rct81.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _tablespace_scripts/tbsp_it_rct81.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar RCT_IT_TBSP para gravar DDL de tablespaces em arquivo no servidor.

FUNCIONAMENTO DETALHADO
  Cursores catálogo e coleção associativa indexada por LINENO_SEQ; UTL_FILE escreve rebuild_tbsp81.sql em diretório Windows fixo e imprime linhas.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas conforme limitações individuais. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLESPACES, DBA_DATA_FILES, V$PARAMETER, LINENO_SEQ, UTL_FILE, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE/SELECT/EXECUTE/grants de diretório diretos. Usa caminho UTL_FILE_DIR antigo; coleção esparsa se sequência não inicia em 1 e loop 1..lineno_count falha. Handler esconde erros e fecha handle sem validar. REUSE na saída é perigoso; buffers800/2048 limitam linhas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório com diretório/UTL_FILE autorizado e sequência reiniciada em 1.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Procedimento criado; chamada grava arquivo de servidor e mostra DDL.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos de criação, staging, autenticação, sessão
  ou código gerado descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  UNIFORM SIZE corrigido; não traduzido caminho do servidor ou estado da sequência por suposição. 
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
CREATE OR REPLACE PROCEDURE RCT_IT_TBSP AS
lineno_count INTEGER;
file_handle UTL_FILE.FILE_TYPE;
--
TYPE ts_temp IS TABLE OF VARCHAR2(2048)
 INDEX BY BINARY_INTEGER;
ts_table TS_TEMP;
--
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
   lv_string            VARCHAR2(800);
   lv_lineno            NUMBER := 0;
   lv_min_extlen        sys.dba_tablespaces.min_extlen%TYPE;
   lv_logging           sys.dba_tablespaces.logging%TYPE;
   lv_extent_man        sys.dba_tablespaces.extent_management%TYPE;
   lv_allocation        sys.dba_tablespaces.allocation_type%TYPE;
   sub_strg             VARCHAR2(20); 
PROCEDURE write_out(
                 p_string VARCHAR2) IS
   BEGIN
    SELECT lineno_seq.nextval into lineno_count from dual;
    SELECT p_string INTO ts_table (lineno_count)
    FROM dual; 
    dbms_output.put_line(p_string);
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
      lv_string := ('CREATE TABLESPACE '||lower(lv_tablespace_name));
      lv_first_rec := TRUE;
      write_out(lv_string);
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
         write_out(lv_string);
         lv_string := ('   '||lv_contents);
         write_out(lv_string);
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
         write_out(lv_string);
      IF lv_extent_man!='LOCAL' THEN
         lv_string := (' MINEXTENTS ' ||
                      lv_min_extents ||
                      ' MAXEXTENTS ' || lv_max_extents);
         write_out(lv_string);
         lv_string := (' PCTINCREASE ' ||
                      lv_pct_increase || ')');
         write_out(lv_string);
      END IF;
         lv_string := ('   '||lv_logging);
         write_out(lv_string);
         lv_string := ('   '||lv_status);
         write_out(lv_string);
         lv_string:='/';
         write_out(lv_string);
         lv_string:=chr(10);
         write_out(lv_string);
   END LOOP;
   CLOSE ts_cursor;
BEGIN
 file_handle:=UTL_FILE.FOPEN('d:\oracle\sql_scripts\','rebuild_tbsp81.sql','W',2048);
 FOR i in 1..lineno_count LOOP
  UTL_FILE.PUT_LINE(file_handle,ts_table(i));
  DBMS_OUTPUT.PUT_LINE(ts_table(i));
 END LOOP;
 UTL_FILE.FCLOSE(file_handle);
EXCEPTION
WHEN others THEN
UTL_FILE.FCLOSE(file_handle);
END;
BEGIN
dbms_output.put_line(to_char(lineno_count));
 FOR i in 1..lineno_count LOOP
  DBMS_OUTPUT.PUT_LINE(ts_table(i));
 END LOOP;
EXCEPTION
WHEN others THEN
dbms_output.put_line(sqlerrm);
END;
END;
/
show err
