/*
===============================================================================
SCRIPT: val_proc.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/VAL_PROC.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar pacote que valida índice e copia INDEX_STATS para tabela de staging.

FUNCIONAMENTO DETALHADO
  DBMS_SQL parseia ANALYZE INDEX VALIDATE STRUCTURE e INSERT SELECT INDEX_STATS, executa ambos e faz COMMIT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBMS_SQL, INDEX_STATS, tabela de destino dinâmica; pacote DBMS_LOCAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE/ANALYZE/DML diretos. Nome de schema/índice/tabela sem validação permite injeção; não há cleanup em erro. ANALYZE pode bloquear e consumir I/O; contrato SELECT * depende da versão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente índice pequeno de teste e staging descartável: revisar @val_proc.sql.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Pacote criado; chamada coleta estrutura, grava staging e confirma transação.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  conforme descritos. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código integral preservado com riscos específicos; não homologado para implantação. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 042 — 04/11/2026
  Correções e melhorias: Pacote usa AUTHID CURRENT_USER, nomes validados/citados e cursores fechados em erro; NATIVE substitui V7.
  Limitações e pendências: DBMS_ASSERT não autoriza ANALYZE/DML; exige privilégios do chamador. ANALYZE pode bloquear e confirma DDL; INSERT SELECT* exige contrato INDEX_STATS compatível e COMMIT confirma trabalho do chamador.
  Homologação necessária: Nome inválido, quoted, destino ausente/contrato divergente, falta de grants e erro em cada cursor; analisar apenas índice descartável.
  Parâmetros e execução: contratos descritos acima e no corpo histórico.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  backup/recovery, comandos Windows/Unix ou uso de credenciais reais.

REFERÊNCIA: https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_ASSERT.html

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
create or replace package dbms_local AUTHID CURRENT_USER is
procedure validate_index (schema in varchar2, index_name in varchar2,table_name in varchar2);
end dbms_local;
/
create or replace package body dbms_local is
procedure validate_index (schema in varchar2, index_name in varchar2,table_name in varchar2)
is
cid1 integer := NULL;
cid2 integer := NULL;
rows_processed integer;
begin
cid1:=dbms_sql.open_cursor;
cid2:=dbms_sql.open_cursor;
dbms_output.put_line('ANALYZE INDEX '||dbms_assert.enquote_name(schema)||'.'||dbms_assert.enquote_name(index_name)||' validate structure  '||table_name);
dbms_sql.parse(cid1,'ANALYZE INDEX '||dbms_assert.enquote_name(schema)||'.'||dbms_assert.enquote_name(index_name)||' validate structure',dbms_sql.NATIVE);
dbms_sql.parse(cid2,'INSERT INTO '||dbms_assert.sql_object_name(table_name)||' SELECT * FROM index_stats ',dbms_sql.NATIVE);
rows_processed:=dbms_sql.execute(cid1);
rows_processed:=dbms_sql.execute(cid2);
commit;
dbms_sql.close_cursor(cid1);
cid1 := NULL;
dbms_sql.close_cursor(cid2);
cid2 := NULL;
EXCEPTION WHEN OTHERS THEN
 if cid1 is not null and dbms_sql.is_open(cid1) then dbms_sql.close_cursor(cid1); end if;
 if cid2 is not null and dbms_sql.is_open(cid2) then dbms_sql.close_cursor(cid2); end if;
 raise;
end validate_index;
end dbms_local;
/
