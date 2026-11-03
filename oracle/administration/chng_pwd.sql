/*
===============================================================================
SCRIPT: chng_pwd.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/CHNG_PWD.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar função que altera senha do usuário Oracle corrente por SQL dinâmico.

FUNCIONAMENTO DETALHADO
  Obtém USER, monta ALTER USER, parseia/executa via DBMS_SQL e fecha cursor.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/execução e SELECT DIRETO conforme LIMITAÇÕES; roles
  podem não atender compilação de objetos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBMS_SQL, DUAL; função CHANGE_PASSWORD

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Privilégios de alteração e contexto definer rights precisam revisão. Concatenar senha sem validação/escaping é inseguro; buffer de senha 32 é legado. Não está pronta para implantação.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Não executar com credenciais reais; revisar em usuário de teste e sessão descartável.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Função criada; chamadas podem mudar autenticação e confirmar DDL.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cria/modifica objetos, dados, credenciais ou sessão
  conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  P_USER não declarado corrigido; impressão de SQL com senha removida para impedir vazamento. Segurança completa e cleanup de erro permanecem pendentes. 
  Revisão estática somente; implantação depende de laboratório e aprovação do PR.
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
create or replace FUNCTION Change_password(
newpass in VARCHAR2) RETURN NUMBER AS
p_password VARCHAR2(32) := newpass;
p_user varchar2(128);
no_of_rows number;
cursor_name INTEGER;
sqlStmt varchar2(300);

BEGIN
   select user into p_user from dual;
   cursor_name := dbms_sql.open_cursor;
   SqlStmt := 'alter user '||p_user||' identified by '||p_password;
   -- A instrução contém senha: não imprimir nem registrar em log.
   dbms_sql.parse(cursor_name,sqlstmt,dbms_sql.v7);
   no_of_rows := dbms_sql.execute(cursor_name);
   dbms_sql.close_cursor(cursor_name);
   RETURN no_of_rows;
END;
/
