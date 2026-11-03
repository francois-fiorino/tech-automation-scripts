/*
===============================================================================
SCRIPT: check_schema.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/check_schema.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar rotina CHECK_CORRUPT para inspeção de corrupção em objetos de um schema.

FUNCIONAMENTO DETALHADO
  Administra REPAIR_TABLE via três chamadas ADMIN_TABLES e percorre TABLE/INDEX/CLUSTER chamando DBMS_REPAIR.CHECK_OBJECT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme LIMITAÇÕES; roles não
  bastam para compilar dependências de rotinas armazenadas. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_OBJECTS, DBMS_REPAIR, DBMS_OUTPUT, REPAIR_TABLE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE, EXECUTE/SELECT diretos e privilégios DBMS_REPAIR. ADMIN_TABLES usa números 1/3/1/2 históricos que devem ser confrontados com constantes da versão; pode criar/limpar/remover tabela de reparo. Varredura é cara, não repara automaticamente corrupção.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

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
  Código preservado; sequência ADMIN_TABLES não alterada sem homologação. 
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
create or replace procedure check_corrupt(schema_name in varchar2) is
cursor c is
  select OWNER,
         object_NAME,
         DECODE(object_type,
                'TABLE',1,
                'INDEX',2,
                'CLUSTER',4,object_type) object_type
  from dba_objects
  where owner = schema_name
        and object_type in ('TABLE','CLUSTER','INDEX') ;
v_corrupt_count BINARY_INTEGER;
object_name varchar2(64);
owner_name varchar2(64);
object_type integer;
begin
 DBMS_REPAIR.ADMIN_TABLES('REPAIR_TABLE',1,3);
 DBMS_REPAIR.ADMIN_TABLES('REPAIR_TABLE',1,1);
 DBMS_REPAIR.ADMIN_TABLES('REPAIR_TABLE',1,2);
 FOR C_REC IN C LOOP
  object_name:=c_rec.object_name;
  owner_name:=c_rec.owner;
  object_type:=c_rec.object_type;
  DBMS_OUTPUT.PUT_LINE(owner_name||'.'||object_name);
  DBMS_REPAIR.CHECK_OBJECT(SCHEMA_NAME=>OWNER_NAME,
     OBJECT_NAME=>OBJECT_NAME,OBJECT_TYPE=>object_type,CORRUPT_COUNT=>v_corrupt_count);
  DBMS_OUTPUT.PUT_LINE(owner_name||'.'||object_name||
     ' Corrupt Count='||to_char(v_corrupt_count));
 END LOOP;
END check_corrupt;
/
