/*
===============================================================================
SCRIPT: check-target.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / misc_scripts/check-target.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Preservar verificação específica de IDs internos para bug 970640 em Oracle 8.1.

FUNCIONAMENTO DETALHADO
  Busca DATAOBJ# duplicado fora de clusters, _NEXT_OBJECT e máximos de IDs; imprime advertências e números para Oracle Support.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_OBJECTS, SYS.OBJ$, SYS.CLU$, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Alvo EXCLUSIVO 8.1 e nota histórica 76670.1; não diagnóstico genérico de corrupção em versões modernas. GREATEST com NULL pode omitir máximo e _NEXT_OBJECT pode não existir. Mensagens DROP/RESET são texto para suporte, nunca comandos autorizados para execução. Não modifica catálogo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente Oracle 8.1 de laboratório, com contexto administrativo autorizado: @check-target.sql.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Dados de IDs/duplicidades e mensagens diagnósticas históricas.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  OBJ$/CLU$ qualificados com SYS; algoritmo e mensagens históricas mantidos sem adaptar limites internos sem homologação. 
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
REM CHECKTARGET.SQL
  REM
  REM This script should be used in conjunction with [NOTE:76670.1]
  REM to check a target database for the side effects of BUG:970640 
  REM
  REM For Oracle 8.1 ONLY
  REM To be run connected INTERNAL or as a SYSDBA user 
  REM
  REM SPOOL THE OUTPUT OF THIS SCRIPT
  REM 
  SET SERVEROUTPUT ON
  REM
  DECLARE
   --
    LIMIT   number:=2147483648;   /* Highest sensible object id   */
    MAXOBJ  number:=4294950911;   /* Max ever object id           */
    next_id number;               /* Current NEXT object_id       */
    high_id number;               /* Current Highest object_id    */
    best_id number;               /* Current Highest Object_id below LIMIT */
    badcnt  number:=0;            /* Number of objects with ID above LIMIT */
    dups    boolean:=false;       /* True if duplicate dataobj#   */
   --
   -- Cursor to get information on OBJECTs with ID above LIMIT
   --
    CURSOR bad_objects IS
      SELECT greatest(object_id, data_object_id) ID,
                  OBJECT_TYPE,OWNER, OBJECT_NAME, SUBOBJECT_NAME
        FROM dba_objects 
       WHERE object_id>=LIMIT OR data_object_id>=LIMIT
      ORDER BY 3,4,5
    ;
   --
   -- Cursor to check for DUPLICATE dataobj# which are not in a cluster
   --
    CURSOR Duplicates IS
          select obj# from sys.obj$ o
           where o.dataobj# in 
           ( select dataobj# from sys.obj$ g
             group by dataobj# having count(*) >1) 
           and not exists
           (select 1 from sys.clu$ c where c.dataobj#=o.dataobj#)
          ;
    CURSOR ObjDesc(ID number) IS
          select * from dba_objects where object_id=id;
    --
  BEGIN
    dbms_output.enable(100000);
   --
    dbms_output.put_line('Checking target database for effects of Bug:970640');
   -- 
   -- First check for DUPLICATE dataobj#
   --
    FOR D in Duplicates
    LOOP
      IF not dups THEN
    dbms_output.put_line('.');
       dbms_output.put_line('** Warning: Objects exist with duplicate DATAOBJ#');
       dbms_output.put_line('** These objects should be checked'||
                            ' to ensure they are NOT in the same tablespace');
       dbms_output.put_line('.');
       dups:=true;
      END IF;
      FOR O in ObjDesc(D.obj#)
      LOOP
       dbms_output.put('. '||O.data_object_id||' ');
       dbms_output.put(O.owner||'.'||O.object_name||' '||O.subobject_name);
       dbms_output.put_line(' ('||O.object_type||')');
      END LOOP;
    END LOOP;
   -- 
   -- Get the NEXT OBJECT ID from the dictionary
   --
    SELECT dataobj# INTO next_id from sys.obj$ WHERE name='_NEXT_OBJECT';
   -- 
   -- Get the highest OBJECT ID that looks sensible (below 2Gb)
   --
    SELECT max(id) INTO best_id FROM 
       (SELECT max(dataobj#) ID from sys.obj$ 
         WHERE dataobj#<LIMIT and name!='_NEXT_OBJECT'
        UNION ALL
        SELECT max(obj#) ID from sys.obj$ 
         WHERE obj#<LIMIT and name!='_NEXT_OBJECT'
       )
    ;
   -- 
   -- Get the actual highest object ID, whether good or bad
   --
    SELECT max(greatest(obj#,dataobj#)) INTO high_id from sys.obj$ 
     WHERE name!='_NEXT_OBJECT';
   --
   -- Output findings
   --
    dbms_output.put_line('.');
    dbms_output.put_line('Base data:');
    dbms_output.put_line('.  NEXT OBJECT Id:    '||next_id);
    dbms_output.put_line('.  HIGHEST OBJECT Id: '||high_id);
    dbms_output.put_line('.  BEST OBJECT Id:    '||best_id);
   --
   -- Comment on findings
   --
    IF next_id>=LIMIT THEN
      dbms_output.put_line('.');
      dbms_output.put_line('NEXT OBJECT Id much too high');
    END IF;
   -- 
    IF high_id>=LIMIT THEN
     dbms_output.put_line('.');
     dbms_output.put_line('The objects listed below have very high object ids.');
     dbms_output.put_line('Determine if they can be dropped/rebuilt:');
     FOR R in bad_objects
     LOOP
       dbms_output.put('. '||R.owner||'.'||R.object_name||' '||R.subobject_name);
       dbms_output.put_line(' ('||R.object_type||')');
       badcnt:=badcnt+1;
     END LOOP;
    END IF;
   --
    IF high_id>=next_id THEN
      dbms_output.put_line('.');
      dbms_output.put_line('Some objects have IDs above "NEXT OBJECT"');
    END IF;
   --
    IF high_id>=LIMIT OR high_id>=next_id OR next_id>=LIMIT THEN
      dbms_output.put_line('.');
      dbms_output.put_line('** Corrective action is required by Oracle Support');
      dbms_output.put_line('** Information below for SUPPORT only');
      dbms_output.put_line('** Best option:');
      dbms_output.put('.     ');
      if badcnt>0 then
        dbms_output.put('DROP the above '||badcnt||' object/s and ');
      end if;
      dbms_output.put_line('RESET to '||(best_id+1));
      if high_id>=LIMIT THEN
        dbms_output.put_line('** Second option:');
        dbms_output.put_line('.     RESET to '||(high_id+1)||' leaving only '||
                  (maxobj-high_id-2)||' objects before DB is in trouble');
      end if;
      dbms_output.put_line('.');
      dbms_output.put('** Remember to RE-RUN this script IMMEDIATELY ');
      dbms_output.put_line('prior to any corrective action');
    ELSE
      IF not dups THEN
        dbms_output.put_line('** Database object IDs look OK');
      END IF;
    END IF;
    IF dups THEN
      dbms_output.put_line('.');
      dbms_output.put_line('** Remember to check the DUPLICATES above');
    END IF;
  END;
  /
       
  REM
