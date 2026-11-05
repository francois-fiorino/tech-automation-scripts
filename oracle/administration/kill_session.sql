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
  DBMS_SQL; procedimento KILL_SESSION com direitos do invocador.

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Exige CREATE PROCEDURE, EXECUTE DBMS_SQL e ALTER SYSTEM autorizado no contexto invocador. Validação lexical não autoriza o alvo, não evita corrida/reutilização de SID e não protege sessões críticas. Não tem parâmetro de instância RAC; não deve ser exposto indiscriminadamente por GRANT EXECUTE. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

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
  Revisão complementar 036 (2026-11-03): SID/SERIAL limitados a até 10 dígitos ASCII antes da concatenação, sem aspas ou metacaracteres. AUTHID CURRENT_USER evita emprestar ALTER SYSTEM do definidor; DBMS_SQL.NATIVE substitui flag V7. Casos de homologação: NULL/vazio; espaços; números normais; aspas, vírgula, comentário, newline, expoente e payload; privilégio ausente; sessão já encerrada; alvo descartável. Comentários/créditos históricos preservados. Não aprovado para implantação.

REFERÊNCIAS TÉCNICAS DA REVISÃO 036
 https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/ALTER-SYSTEM.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_SQL.html

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
-- comment: creates procedure kill_session which accepts SID and serial number as input

/*  */
create or replace procedure kill_session ( session_id in varchar2,
serial_num in varchar2)
authid current_user
as
cur integer:=null;
ret integer;
string varchar2(100);
begin
 if session_id is null or serial_num is null
    or length(trim(session_id))>10 or length(trim(serial_num))>10
    or translate(trim(session_id),'x0123456789','x') is not null
    or translate(trim(serial_num),'x0123456789','x') is not null
    or trim(session_id) is null or trim(serial_num) is null then
   raise_application_error(-20010,'SID e SERIAL devem conter somente digitos ASCII.');
 end if;
 string :=
        'alter system kill session '||''''||trim(session_id)||','||trim(serial_num)||'''';
   cur := dbms_sql.open_cursor;
   dbms_sql.parse(cur,string,dbms_sql.native);
   ret := dbms_sql.execute(cur)  ;
   dbms_sql.close_cursor(cur); cur:=NULL;
exception
   when OTHERS then
      if cur is not null and dbms_sql.is_open(cur) then
        dbms_sql.close_cursor(cur); cur:=NULL;
      end if;
      raise_application_error(-20001,'Error in execution',TRUE);
end;
/
