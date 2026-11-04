/*
===============================================================================
SCRIPT: umaint.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / misc_scripts/umaint.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar pacote histórico para salvar verifier de senha, alterar e restaurar autenticação.

FUNCIONAMENTO DETALHADO
  SAVE_PASS lê DBA_USERS.PASSWORD para estado global; CHANGE_PASS executa ALTER USER via DBMS_SQL; RESET_PASS reutiliza hash salvo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS de criação/execução/consulta e permissões administrativas
  conforme limitações; não instalar variantes sobre objetos de trabalho. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado pelo chamador (não configurado aqui).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_USERS (PASSWORD legado), DBMS_SQL, DBMS_OUTPUT; pacote UMAINT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  ALTER USER/CREATE PROCEDURE/SELECT direto. Estado OLD_PASS único não vincula hash ao username e CHANGE_PASS chama SAVE_PASS, podendo sobrescrever estado de restauração. Hash legado não representa autenticação moderna, injeção por concatenação e handlers ocultam falhas/cursor leak. Não pronto para implantação.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Não usar contas/credenciais reais; revisão de segurança somente.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Pacote criado; chamadas podem alterar senhas e confirmar DDL.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: DDL/DML, staging, autenticação ou efeitos da saída
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código completo preservado para revisar contrato de autenticação sem alterar sequência silenciosamente; nenhum verifier coletado. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 044 — 04/11/2026
  Correções e melhorias: EXIT incondicional antes de instalar UMAINT ou consultar verificadores.
  Limitações e pendências: OLD_PASSglobal não vincula usuário; RESET_PASS chama CHANGE_PASS que sobrescreve OLD_PASS. Hashlegado/injeção/definerrights e erros ocultos impedem adaptação segura sem contrato de autenticação moderno.
  Homologação necessária: Confirmar barreira antes de CREATE PACKAGE; definir processo homologado de autenticação/rotação sem usar contas reais.
  Parâmetros/execução: contratos descritos acima e no corpo; somente laboratório.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  submissão de jobs, backup/recovery, Shell/Windows/VMS ou coleta de credenciais.

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
PROMPT BLOQUEADO: operacao legada critica; somente revisao.
EXIT FAILURE ROLLBACK


/*  */
create or replace package umaint as
    procedure save_pass (uname in dba_users.username%type);
    procedure change_pass (uname in dba_users.username%type,
                           passwd in dba_users.password%type);
    procedure reset_pass (uname in dba_users.username%type);
    procedure prt_mess (mess_text varchar2);

    old_pass  dba_users.password%type := null;
end umaint;
/

create or replace package body umaint as

procedure save_pass (uname in dba_users.username%type) is

cursor get_pass is
       select du.password 
       from   dba_users du
       where  du.username = upper(uname);
begin
  open get_pass;
  fetch get_pass into old_pass;
  close get_pass;
exception
  when others then
    prt_mess('ERROR: Unable to save password for user '||uname);
end;

procedure change_pass (uname in dba_users.username%type,
                       passwd in dba_users.password%type) is
  c_pass_set integer;
  r_pass_set integer;

begin
  save_pass(uname);
  c_pass_set := dbms_sql.open_cursor;
  dbms_sql.parse(c_pass_set,'alter user '||uname||' identified by '||passwd, dbms_sql.native); 
  r_pass_set := dbms_sql.execute(c_pass_set);
  dbms_sql.close_cursor(c_pass_set);
  prt_mess('Password successfully changed for user '||uname);
exception
  when others then
    prt_mess('ERROR: Unable to change password for user '||uname);
end;

procedure reset_pass (uname in dba_users.username%type) is

begin
  if old_pass is null then
     prt_mess('ERROR: No saved password for user '||uname);
   else
     change_pass(uname,'values '''||old_pass||'''');
  end if;
end;

procedure prt_mess (mess_text in varchar2) is

begin
  dbms_output.put_line(' ');
  dbms_output.put_line(mess_text);
  dbms_output.put_line(' ');
end;

end umaint;
/
