/*
===============================================================================
SCRIPT: kill_session.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/kill_session.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar procedimento que solicita encerramento de sessão por SID/SERIAL#.

FUNCIONAMENTO DETALHADO
  Monta ALTER SYSTEM KILL SESSION e executa via DBMS_SQL; fecha cursor e propaga erro.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme LIMITAÇÕES; roles não
  bastam para compilar dependências de rotinas armazenadas.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBMS_SQL; procedimento KILL_SESSION

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE/ALTER SYSTEM diretos. Entradas VARCHAR2 concatenadas são superfície de SQL injection e precisam validação completa antes de deployment; definer rights torna grants EXECUTE especialmente sensíveis. Não inclui instância RAC.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Revisão somente: não chamar contra sessões reais.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Rotina criada; chamada pode interromper transação e disparar rollback.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados ou sessão descritos
  acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Cleanup movido antes de RAISE_APPLICATION_ERROR que antes tornava fechamento inalcançável. Cursor inicializado NULL e erro original preservado na pilha; restante não homologado. 
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

-- comment: creates procedure kill_session which accepts SID and serial number as input

/*  */
create or replace procedure kill_session ( session_id in varchar2,
serial_num in varchar2)
as
cur integer:=null;
ret integer;
string varchar2(100);
begin
 string :=
        'alter system kill session '||''''||session_id||','||serial_num||'''';
   cur := dbms_sql.open_cursor;
   dbms_sql.parse(cur,string,dbms_sql.v7);
   ret := dbms_sql.execute(cur)  ;
   dbms_sql.close_cursor(cur);
exception
   when OTHERS then
      if cur is not null and dbms_sql.is_open(cur) then
        dbms_sql.close_cursor(cur);
      end if;
      raise_application_error(-20001,'Error in execution',TRUE);
end;
/
