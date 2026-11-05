/*
===============================================================================
SCRIPT: check_schema.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/check_schema.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar rotina CHECK_CORRUPT para inspeção de corrupção em objetos de um schema.

FUNCIONAMENTO DETALHADO
  Verifica existência da tabela de reparo SYS, cria se ausente com constantes documentadas e chama CHECK_OBJECT por objeto; preserva evidência em vez de remover a tabela.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme LIMITAÇÕES; roles não
  bastam para compilar dependências de rotinas armazenadas. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_OBJECTS, DBMS_REPAIR, DBMS_OUTPUT, REPAIR_TABLE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Rotina de DBA com acesso especial SYS/DBMS_REPAIR; checagem de existência não valida estrutura nem elimina corrida de criação. Tabela existente é reutilizada e pode acumular evidência. CHECK_OBJECT documenta TABLE/INDEX; suporte de CLUSTER deve ser confirmado antes de uso. Não repara nem marca blocos automaticamente. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Somente revisão/ambiente descartável: @check_schema.sql; não chamar em produção.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Procedimento criado; chamada imprime objeto e CORRUPT_COUNT.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados ou sessão descritos
  acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 037 (2026-11-03): Sequência de três ADMIN_TABLES numéricos substituída por CREATE_ACTION somente se SYS.REPAIR_TABLE não existe. Não apaga/purga evidências antes do CHECK_OBJECT. Tipos usam constantes DBMS_REPAIR no PL/SQL e buffers ancorados. Casos de homologação: Tabela de reparo ausente/existente/estrutura incorreta; corrida de criação; TABLE/INDEX/CLUSTER; schema vazio; falha em objeto intermediário; custo de varredura em cópia descartável. Comentários/créditos históricos preservados. Não aprovado para implantação.

REFERÊNCIAS TÉCNICAS DA REVISÃO 037
 https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_REPAIR.html

AVISO DE RESPONSABILIDADE
AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de
qualquer utilização em produção. Sua execução é de responsabilidade do
profissional responsável pelo ambiente. Os mantenedores deste repositório não
se responsabilizam por indisponibilidade, perda de dados, alterações indevidas
ou outros impactos decorrentes de sua utilização.

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
create or replace procedure check_corrupt(schema_name in varchar2) is
cursor c is
  select OWNER,
         object_NAME,
         object_type
  from dba_objects
  where owner = schema_name
        and object_type in ('TABLE','CLUSTER','INDEX') ;
v_corrupt_count BINARY_INTEGER;
object_name dba_objects.object_name%TYPE;
owner_name dba_objects.owner%TYPE;
object_type integer;
repair_exists integer;
begin
 SELECT COUNT(*) INTO repair_exists FROM sys.dba_tables WHERE owner='SYS' AND table_name='REPAIR_TABLE';
 IF repair_exists=0 THEN
  DBMS_REPAIR.ADMIN_TABLES(table_name=>'REPAIR_TABLE',table_type=>DBMS_REPAIR.REPAIR_TABLE,
   action=>DBMS_REPAIR.CREATE_ACTION);
 END IF;
 FOR C_REC IN C LOOP
  object_name:=c_rec.object_name;
  owner_name:=c_rec.owner;
  object_type:=CASE c_rec.object_type WHEN 'TABLE' THEN DBMS_REPAIR.TABLE_OBJECT WHEN 'INDEX' THEN DBMS_REPAIR.INDEX_OBJECT ELSE DBMS_REPAIR.CLUSTER_OBJECT END;
  DBMS_OUTPUT.PUT_LINE(owner_name||'.'||object_name);
  DBMS_REPAIR.CHECK_OBJECT(SCHEMA_NAME=>OWNER_NAME,
     OBJECT_NAME=>OBJECT_NAME,OBJECT_TYPE=>object_type,REPAIR_TABLE_NAME=>'REPAIR_TABLE',CORRUPT_COUNT=>v_corrupt_count);
  DBMS_OUTPUT.PUT_LINE(owner_name||'.'||object_name||
     ' Corrupt Count='||to_char(v_corrupt_count));
 END LOOP;
END check_corrupt;
/
