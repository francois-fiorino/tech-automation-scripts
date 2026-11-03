/*
===============================================================================
SCRIPT: utl_long.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/utl_long.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar pacote para localizar substring em LONG de linha identificada por ROWID.

FUNCIONAMENTO DETALHADO
  Resolve coluna LONG no catálogo acessível, lê chunks DBMS_SQL para CLOB temporário e usa DBMS_LOB.INSTR.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS de criação/execução/consulta e permissões administrativas
  conforme limitações; não instalar variantes sobre objetos de trabalho.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  ALL_OBJECTS, ALL_TAB_COLUMNS, DBMS_ROWID, DBMS_SQL, DBMS_LOB; UTL_LONG

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE/grants diretos. ROWID físico/segmento e acesso definer rights requerem revisão; nomes de catálogo concatenados não são quoted. V_LEN de LONG e offsets CLOB podem divergir byte/char multibyte; sem homologação para esse caso.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: testar LONG vazio/nulo, vários chunks e charset multibyte.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Pacote criado; função devolve posição ou zero conforme DBMS_LOB.INSTR.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: DDL/DML, staging, autenticação ou efeitos da saída
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  DATA_OBJECT_ID substitui OBJECT_ID na resolução de ROWID_OBJECT; CLOB temporário liberado no retorno/erro e cursor fechado só se aberto; leitura em chunks preservada. 
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
CREATE OR REPLACE PACKAGE utl_long AS

  /* SubType for object names */
  SUBTYPE st_object_name IS all_objects.object_name%TYPE;
  
  /* Record type for column info */
  TYPE rt_column IS RECORD
    (owner st_object_name, 
	 table_name st_object_name, 
	 column_name st_object_name);
	 
  /* INSTR mimic for LONG columns */
  FUNCTION INSTR (
    vp_row IN ROWID,
    vp_exp IN VARCHAR2)
    RETURN NUMBER;
  
END;
/

CREATE OR REPLACE PACKAGE BODY utl_long AS
  
  /* Get LONG column name from ROWID */
  FUNCTION rowid_to_column (
    vp_row IN ROWID)
	RETURN rt_column  
  IS
    v_rtn rt_column;
	CURSOR c_column IS
    SELECT a.owner, a.object_name, t.column_name
    FROM   all_objects a, all_tab_columns t
    WHERE  t.data_type = 'LONG'
    AND    t.table_name = a.object_name
    AND    t.owner = a.owner
    AND    a.data_object_id = DBMS_ROWID.ROWID_OBJECT (vp_row);
  BEGIN
    OPEN c_column;
	FETCH c_column INTO v_rtn;
	CLOSE c_column;
	RETURN v_rtn;
  END;
  
  /* INSTR mimic for LONG columns */
  FUNCTION INSTR (
    vp_row IN ROWID,
    vp_exp IN VARCHAR2)
    RETURN NUMBER 
  IS
    v_clb CLOB := NULL;
    v_result number;
	v_exe INTEGER := 0;
    v_pos PLS_INTEGER := 0;
    v_len PLS_INTEGER := 0;
    v_pce VARCHAR2 (32767);
    v_cur PLS_INTEGER := DBMS_SQL.OPEN_CURSOR;
    v_col rt_column := rowid_to_column (vp_row);
  BEGIN
    DBMS_LOB.CREATETEMPORARY (v_clb, TRUE, DBMS_LOB.CALL);
	DBMS_SQL.PARSE (v_cur, 'SELECT ' || v_col.column_name || ' FROM ' || 
	  v_col.owner || '.' || v_col.table_name || ' WHERE ROWID = :v_row', DBMS_SQL.NATIVE);
	DBMS_SQL.BIND_VARIABLE (v_cur, 'v_row', vp_row);
    DBMS_SQL.DEFINE_COLUMN_LONG (v_cur, 1);
    v_exe := DBMS_SQL.EXECUTE_AND_FETCH (v_cur);
	LOOP
      DBMS_SQL.COLUMN_VALUE_LONG (v_cur, 1, 32767, v_pos, v_pce, v_len);
      EXIT WHEN v_len = 0;
      DBMS_LOB.WRITE(v_clb, v_len, v_pos + 1, v_pce);
      v_pos := v_pos + v_len;
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR (v_cur);
	v_result:=DBMS_LOB.INSTR(v_clb,vp_exp);
    DBMS_LOB.FREETEMPORARY(v_clb);
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
	  if DBMS_SQL.IS_OPEN(v_cur) then DBMS_SQL.CLOSE_CURSOR(v_cur); end if;
      if DBMS_LOB.ISTEMPORARY(v_clb)=1 then DBMS_LOB.FREETEMPORARY(v_clb); end if;
	RAISE;
  END;
 
END;
/
