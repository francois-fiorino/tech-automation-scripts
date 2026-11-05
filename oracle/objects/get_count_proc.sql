/*
===============================================================================
SCRIPT: get_count_proc.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/get_count_proc.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar procedimento GET_COUNT para contagem exata de objeto autorizado.

FUNCIONAMENTO DETALHADO
  DBMS_SQL parseia COUNT, define/fetch/lê coluna e devolve parâmetro OUT; limpa cursor e propaga erro.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado pelo chamador (não configurado aqui).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBMS_SQL, DBMS_ASSERT.SQL_OBJECT_NAME, DBMS_OUTPUT; GET_COUNT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE/grants diretos. Pode fazer full scan; definer rights exige revisar grants EXECUTE e autorização de leitura. Substitui função homônima GET_COUNT de outros exemplos, com contrato incompatível.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório Oracle 10.2+: @get_count_proc.sql; testar tabela pequena e nome inválido.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Procedimento criado; chamada imprime/devolve contagem.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  DBMS_ASSERT valida nome e buffer ampliado; WHEN OTHERS NULL substituído por cleanup+RAISE e / adicionado. Não afirma validação de acesso apenas por nome válido. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 043 — 04/11/2026
  Correções e melhorias: AUTHID CURRENT_USER e NATIVE no procedimento GET_COUNT; contrato OUT preservado.
  Limitações e pendências: Grants/autorizações do invocador passam a governar leitura. DBMS_OUTPUT não habilitado aqui; fullscan caro e contrato homônimo da função é incompatível.
  Homologação necessária: Tabela vazia, nome inválido, falta deSELECT e erro no cliente/DBMS_OUTPUT; verificar OUT e cleanup em laboratório.
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
create or replace PROCEDURE get_count (
 	tab_name  IN VARCHAR2, 
	rows OUT NUMBER
) AUTHID CURRENT_USER AS
  cur     INTEGER:=null;
  ret     INTEGER;
 com_string   VARCHAR2(32767);
 row_count      NUMBER;
BEGIN
 com_string :=
  'SELECT count(1) row_count FROM '||dbms_assert.sql_object_name(tab_name);
 cur := DBMS_SQL.OPEN_CURSOR;
 DBMS_SQL.PARSE(cur,com_string,dbms_sql.NATIVE);
 DBMS_SQL.DEFINE_COLUMN(cur, 1, row_count);
 ret := DBMS_SQL.EXECUTE(cur);
 ret := DBMS_SQL.FETCH_ROWS(cur);
 DBMS_SQL.COLUMN_VALUE(cur, 1, row_count);
 DBMS_SQL.CLOSE_CURSOR(cur);
 DBMS_OUTPUT.PUT_LINE('Count='||TO_CHAR(row_count));
 rows:=row_count;
EXCEPTION
WHEN others THEN
 if cur is not null and dbms_sql.is_open(cur) then dbms_sql.close_cursor(cur); end if;
 raise;
END;
/
