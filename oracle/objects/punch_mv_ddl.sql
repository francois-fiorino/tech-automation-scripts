/*
===============================================================================
SCRIPT: punch_mv_ddl.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/punch_mv_ddl.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Extrair DDL de materialized view e dos logs de tabelas referenciadas.

FUNCIONAMENTO DETALHADO
  GET_DDL da MV selecionada; percorre dependências TABLE distintas e chama GET_DEPENDENT_DDL para logs, imprimindo CLOB em blocos.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBMS_METADATA, DBA_MVIEWS, DBA_DEPENDENCIES, DBMS_LOB, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Exige acesso aos metadados (próprio schema ou privilégios de catálogo adequados) e EXECUTE nos pacotes. MV pode referenciar várias tabelas; linha de saída limitada e chunks acrescentam quebras, logo não é export byte a byte. Proteger código/caminhos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE enter_mview_owner = HR
  DEFINE enter_mview_name = MV_TESTE
  @punch_mv_ddl.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  DDL textual e avisos por tabela sem log/acesso; não executa DDL extraída.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Filename solto comentado; nomes 128, VARCHAR2(4000) trocado por CLOB, loop de dependências em vez de SELECT INTO escalar, erros deixam de ser silenciosos e output é dividido em 8000 caracteres para limite de bytes multibyte. 
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

-- punch_mv_ddl.sql

 

set serveroutput on
set feedback off
undef v_sql
 
declare
   v_task_name       varchar2 (100);
   v_mview_owner     varchar2 (128)   := upper ('&&enter_mview_owner');
   v_mview_name      varchar2 (128)   := upper ('&&enter_mview_name');
   v_mview_sql       clob;
   v_mview_log_sql   clob;
   procedure emit_clob(p_text clob) is
     v_pos pls_integer:=1;
   begin
     while v_pos<=dbms_lob.getlength(p_text) loop
       dbms_output.put_line(dbms_lob.substr(p_text,8000,v_pos));
       v_pos:=v_pos+8000;
     end loop;
   end;
begin
   -- get mview text from data dictionary
   select dbms_metadata.get_ddl ('MATERIALIZED_VIEW', mview_name, owner)
     into v_mview_sql
     from dba_mviews
    where owner = v_mview_owner and mview_name = v_mview_name;
 
   dbms_output.put_line('mview sql is:');
   emit_clob(v_mview_sql);
   for dep in (select distinct referenced_name,referenced_owner
     from dba_dependencies where referenced_type='TABLE'
       and referenced_name!=v_mview_name and owner=v_mview_owner
       and name=v_mview_name and type='MATERIALIZED VIEW') loop
     begin
       v_mview_log_sql:=dbms_metadata.get_dependent_ddl(
         'MATERIALIZED_VIEW_LOG',dep.referenced_name,dep.referenced_owner);
       dbms_output.put_line('mview log sql is:');emit_clob(v_mview_log_sql);
     exception when others then
       dbms_output.put_line('Aviso de log '||dep.referenced_owner||'.'||dep.referenced_name||': '||sqlerrm);
     end;
   end loop;
exception
   when others
   then
      dbms_output.put_line(sqlerrm);
      raise;
end;
/

 
