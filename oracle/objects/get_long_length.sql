/*
===============================================================================
SCRIPT: get_long_length.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/get_long_length.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar L_LENGTH para obter comprimento de LONG de uma linha por ROWID.

FUNCIONAMENTO DETALHADO
  Parse/fetch via DBMS_SQL, leitura de chunks COLUMN_VALUE_LONG a partir de offset zero, soma bytes e limpa cursor.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBMS_SQL, DBMS_ASSERT.SQL_OBJECT_NAME/SIMPLE_SQL_NAME; tabela/coluna LONG

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE/EXECUTE/SELECT diretos. DBMS_ASSERT valida forma/nome, não autorização de acesso; direitos do invocador requerem revisar grants do chamador. Não é comprimento de CLOB nem suporte genérico de UROWID; byte/charset precisa validação no alvo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente Oracle 10.2+ laboratório: revisar @get_long_length.sql.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Função criada; chamada retorna comprimento lido ou NULL sem linha.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  conforme descritos. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Offset 1 corrigido para zero; nomes validados, ROWID bindado, SQL buffer ampliado e cleanup+RAISE em erro; algoritmo de chunks preservado. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 040 — 04/11/2026
  Correções e melhorias: L_LENGTH usa AUTHID CURRENT_USER para não emprestar privilégios do definidor ao SQL dinâmico.
  Limitações e pendências: DBMS_ASSERT não autoriza acesso. Retorna bytes dos chunks, NULL sem linha e zero para LONG nulo; ROWID textual não garante suporte IOT/UROWID. Limites multibyte e dois GB exigem laboratório.
  Homologação necessária: LONG de 0/1/32766/32767/32768 bytes, multibyte, ROWID ausente e chamador sem SELECT; inspecionar cleanup após erro.
  Parâmetros e execução: contrato detalhado acima e no corpo; somente laboratório.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  sem Windows, exportação, job ou comando administrativo executado.

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
CREATE OR REPLACE FUNCTION l_length(cTabName varchar2, 
                                       cColName varchar2, 
                                       cRowid   varchar2) 
    RETURN NUMBER 
    AUTHID CURRENT_USER
    IS 
           cur_id integer:=null; 
           buff   varchar2(32767); 
           len    integer; 
           offset integer; 
           v_length integer; 
           stmt varchar2(32767); 
           ret    integer; 
    BEGIN 
 
          stmt :=  ' SELECT  '|| dbms_assert.simple_sql_name(cColName) || ' FROM  ' || dbms_assert.sql_object_name(cTabName) || 
                   ' WHERE rowid = :rid'; 
 
          cur_id := dbms_sql.open_cursor; 
          dbms_sql.parse(cur_id, stmt, dbms_sql.NATIVE); 
          dbms_sql.bind_variable(cur_id,':rid',cRowid);
          dbms_sql.define_column_long(cur_id, 1); 
          ret := dbms_sql.execute(cur_id); 
 
          IF (dbms_sql.fetch_rows(cur_id) > 0 ) 
          THEN 
              offset := 0; 
              len := 0; 
              LOOP 
                 dbms_sql.column_value_long(cur_id, 1,32767, offset, 
                                            buff,  v_length); 
                 len := len + v_length; 
                 EXIT  WHEN v_length < 32767; 
                 offset := offset + v_length; 
              END LOOP; 
          END IF; 
          dbms_sql.close_cursor(cur_id); 
          return( len ); 
    EXCEPTION WHEN OTHERS THEN
      if cur_id is not null and dbms_sql.is_open(cur_id) then dbms_sql.close_cursor(cur_id); end if;
      raise;
    END; 
/

