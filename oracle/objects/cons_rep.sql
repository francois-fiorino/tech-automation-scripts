/*
===============================================================================
SCRIPT: cons_rep.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/CONS_REP.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Documentar relação de PK/FK de owners fora SYS/SYSTEM com staging.

FUNCIONAMENTO DETALHADO
  CREATE/TRUNCATE CONS_TEMP, coleta DBA_CONSTRAINTS/COLUMNS por posição, numera FKs, cria índices, relatório e DROP staging.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS de criação/execução/consulta e permissões administrativas
  conforme limitações; não instalar variantes sobre objetos de trabalho.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_CONSTRAINTS, DBA_CONS_COLUMNS, CONS_TEMP, DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DML/commits/DDL confirmam transações. Consulta colunas de todos owners repetidamente para nome; buffers2000/30 e LONG limitam dados modernos. Metadados podem mudar entre coleta e relatório; não mostra status/deferrability.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema descartável com catálogo autorizado.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Relatório de owners/tabelas/colunas pai-filho.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: DDL/DML, staging, autenticação ou efeitos da saída
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Owner da referência adicionado ao join final para evitar associar FK a constraint homônima de outro schema; escopo DBA preservado. 
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
REM FUNCTION: SCRIPT FOR DOCUMENTING DATABASE CONSTRAINTS 
REM
REM FUNCTION: This script must be run by the constraint owner.  
REM 
REM FUNCTION: This script is intended to run with Oracle7 or Oracle8.
REM
REM FUNCTION: Running this script will document the 
REM FUNCTION: primary key - foreign key
REM FUNCTION: constraints in the database 
REM 
REM
REM Only preliminary testing of this script was performed.  
REM Be sure to test 
REM it completely before relying on it.  
REM
REM MRA 6/14/97 Verified for Oracle8
REM
SET ARRAYSIZE 1 VERIFY OFF  FEEDBACK OFF TERMOUT OFF ECHO OFF PAGESIZE 0 
SET LONG 4000
SET TERMOUT ON
SELECT 'Creating constraint documentation script...' FROM dual;
SET TERMOUT OFF
 
CREATE TABLE cons_temp (owner VARCHAR2(30),
          constraint_name VARCHAR2(30),
          constraint_type VARCHAR2(11),
          search_condition VARCHAR2(2000),
          table_name VARCHAR2(30),
          referenced_owner VARCHAR2(30),
          referenced_constraint VARCHAR2(30),
          delete_rule VARCHAR2(9),
          constraint_columns VARCHAR2(2000),
          con_number NUMBER); 
TRUNCATE TABLE cons_temp;

DECLARE
 
   CURSOR cons_cursor IS 
     SELECT     
     owner,
        constraint_name, 
        DECODE(constraint_type,'P','Primary Key',
               'R','Foreign Key',
               'U','Unique',
               'C','Check',
               'D','Default'),
        search_condition, 
        table_name,
        r_owner,
        r_constraint_name,
        delete_rule
       FROM 
        dba_constraints 
       WHERE 
        owner NOT IN ('SYS','SYSTEM')
       ORDER BY 
        owner; 

     CURSOR cons_col (cons_name in VARCHAR2) IS 
       SELECT 
         owner,
         constraint_name,
         column_name
       FROM 
         dba_cons_columns 
       WHERE 
         owner NOT IN ('SYS','SYSTEM') AND
         constraint_name = UPPER(cons_name)
       ORDER BY 
         owner, 
         constraint_name, 
         position;

      CURSOR get_cons (tab_nam in VARCHAR2) IS
        SELECT DISTINCT 
          owner,
          table_name,
          constraint_name,
          constraint_type
        FROM 
          cons_temp
        WHERE 
          table_name=tab_nam
          AND constraint_type='Foreign Key'
        ORDER BY 
          owner,
          table_name,
          constraint_name;

      CURSOR get_tab_nam is
        SELECT 
         DISTINCT table_name
        FROM 
         cons_temp
        WHERE 
         constraint_type='Foreign Key'
        ORDER BY 
         table_name;

        tab_nam        user_constraints.table_name%TYPE;
        cons_owner     user_constraints.owner%TYPE;
        cons_name      user_constraints.constraint_name%TYPE;
        cons_type      VARCHAR2(11);
        cons_sc        user_constraints.search_condition%TYPE;
        cons_tname     user_constraints.table_name%TYPE;
        cons_rowner     user_constraints.r_owner%TYPE;
        cons_rcons     user_constraints.r_constraint_name%TYPE;
        cons_dr        user_constraints.delete_rule%TYPE;   
        cons_col_own   user_cons_columns.owner%TYPE;
        cons_col_nam   user_cons_columns.constraint_name%TYPE;
        cons_column    user_cons_columns.column_name%TYPE;
        cons_tcol_name user_cons_columns.table_name%TYPE;
        all_columns    VARCHAR2(2000);
        counter        INTEGER:=0;
        cons_nbr       INTEGER;

BEGIN
   OPEN cons_cursor;
   LOOP
      FETCH cons_cursor INTO cons_owner,
                cons_name,
                cons_type,
                cons_sc,
                cons_tname,
                cons_rowner,
                cons_rcons,
                cons_dr;
      EXIT WHEN cons_cursor%NOTFOUND;
     all_columns :='';
     counter := 0;
     OPEN cons_col (cons_name);
     LOOP
     FETCH cons_col  INTO
             cons_col_own,
             cons_col_nam,
             cons_column;
     EXIT WHEN cons_col%NOTFOUND; 
     IF cons_owner = cons_col_own AND cons_name=cons_col_nam
     THEN
       counter := counter+1;
       IF counter = 1 THEN
         all_columns := all_columns||cons_column;
       ELSE
         all_columns := all_columns||', '||cons_column;
       END IF;
     END IF;
     END LOOP;
     CLOSE cons_col;
     INSERT INTO cons_temp VALUES (cons_owner,
                     cons_name,
                     cons_type,
                     cons_sc,
                     cons_tname,
                     cons_rowner,
                     cons_rcons,
                     cons_dr,
                     all_columns,
                     0);
   COMMIT;
   END LOOP;
   CLOSE cons_cursor;
   COMMIT;
BEGIN
 OPEN get_tab_nam;
LOOP
  FETCH get_tab_nam INTO tab_nam;
  EXIT WHEN get_tab_nam%NOTFOUND;
/*sys.dbms_output.put_line(tab_nam);*/
  OPEN get_cons (tab_nam);
  cons_nbr:=0;
  LOOP
    FETCH get_cons INTO cons_owner,
               cons_tname,
               cons_name,
               cons_type;
    EXIT WHEN get_cons%NOTFOUND;
    cons_nbr:=cons_nbr+1;
/*    sys.dbms_output.put_line('cons_nbr='||cons_nbr);*/
/*sys.dbms_output.put_line(cons_owner||'.'||cons_name||' '||cons_type);*/
    UPDATE cons_temp SET con_number=cons_nbr 
    WHERE
     constraint_name=cons_name AND
     constraint_type=cons_type AND
     owner=cons_owner;
  END LOOP;
  CLOSE get_cons;
  COMMIT;
END LOOP;
CLOSE get_tab_nam;
COMMIT;
END;
END;
/
CREATE INDEX pk_cons_temp ON cons_temp(constraint_name);
CREATE INDEX lk_cons_temp2 ON cons_temp(referenced_constraint);
SET FEEDBACK OFF TERMOUT OFF ECHO OFF
SET VERIFY OFF
SET PAGES 48 LINES 132
COLUMN pri_own FORMAT a10 HEADING 'Pri Table|Owner'
COLUMN for_own FORMAT a10 HEADING 'For Table|Owner'
COLUMN pri_tab FORMAT a25 HEADING 'Pri Table|Name'
COLUMN for_tab FORMAT a25 HEADING 'For Table|Name'
COLUMN pri_col FORMAT a25 HEADING 'Pri Key|COLUMNs' word_wrapped
COLUMN for_col FORMAT a25 HEADING 'For Key|COLUMNs' word_wrapped
START title132 'Primary Key - Foreign Key Report'
SPOOL rep_out\&db\pk_fk
BREAK ON pri_own ON pri_tab ON for_own ON for_tab
SELECT 
     b.owner pri_own,
     b.table_name pri_tab,
     RTRIM(b.constraint_columns) pri_col,
     a.owner for_own, 
     a.table_name for_tab,
     RTRIM(a.constraint_columns) for_col
FROM 
     cons_temp a, 
     cons_temp b
WHERE
     a.referenced_constraint=b.constraint_name and a.referenced_owner=b.owner
ORDER BY
     b.owner,b.table_name,a.owner,a.table_name;
SPOOL OFF
DROP TABLE cons_temp;
SET VERIFY ON FEEDBACK ON TERMOUT ON PAGESIZE 22 LINES 80
CLEAR COLUMNS
CLEAR BREAKS 
TTITLE OFF

