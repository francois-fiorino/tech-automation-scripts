/*
===============================================================================
SCRIPT: chng_pwd.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/CHNG_PWD.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar função que altera senha do usuário Oracle corrente por SQL dinâmico.

FUNCIONAMENTO DETALHADO
  Opera sobre SESSION_USER com AUTHID CURRENT_USER; constrói ALTER USER com nomes citados e senha protegida contra quebra de aspas; executa via DBMS_SQL e fecha cursor em sucesso/erro.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/execução e SELECT DIRETO conforme LIMITAÇÕES; roles
  podem não atender compilação de objetos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBMS_SQL, DBMS_ASSERT, SYS_CONTEXT; função CHANGE_PASSWORD.

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  ALTER USER altera autenticação e pode confirmar transações; testar regras de senha/versão e contas proxy/common. O parâmetro deve vir por bind de cliente autorizado, sem literal em histórico. RETURN de DBMS_SQL não comprova número de contas alteradas. Limpar variáveis PL/SQL não garante apagamento de cópias em memória/auditoria. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

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
  Revisão complementar 036 (2026-11-03): Direitos do invocador e SESSION_USER explícitos; username validado/citado; senha entre aspas, com rejeição de aspas duplas e caracteres de controle; cleanup em exceção e sem impressão da instrução. Casos de homologação: Senha com espaços, apóstrofo, ponto-e-vírgula e ampersand por bind; doublequote/control rejeitados; usuário quoted; privilégio ausente; verify function; erro de parse; conta descartável. Comentários/créditos históricos preservados. Não aprovado para implantação.

REFERÊNCIAS TÉCNICAS DA REVISÃO 036
 https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/ALTER-USER.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_ASSERT.html
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
/*  */
create or replace FUNCTION Change_password(
newpass in VARCHAR2) RETURN NUMBER AUTHID CURRENT_USER AS
p_password VARCHAR2(32767) := newpass;
p_user varchar2(128);
no_of_rows number;
cursor_name INTEGER:=NULL;
sqlStmt varchar2(32767);

BEGIN
   IF p_password IS NULL OR INSTR(p_password,CHR(34))>0 OR
      INSTR(p_password,CHR(0))>0 OR INSTR(p_password,CHR(10))>0 OR INSTR(p_password,CHR(13))>0 THEN
      RAISE_APPLICATION_ERROR(-20011,'Senha vazia ou com caractere nao suportado.');
   END IF;
   p_user:=SYS_CONTEXT('USERENV','SESSION_USER');
   cursor_name := dbms_sql.open_cursor;
   SqlStmt := 'alter user '||DBMS_ASSERT.ENQUOTE_NAME(p_user,FALSE)||
              ' identified by "'||p_password||'"';
   -- A instrução contém senha: não imprimir nem registrar em log.
   dbms_sql.parse(cursor_name,sqlstmt,dbms_sql.native);
   no_of_rows := dbms_sql.execute(cursor_name);
   dbms_sql.close_cursor(cursor_name); cursor_name:=NULL;
   p_password:=NULL; sqlStmt:=NULL;
   RETURN no_of_rows;
EXCEPTION WHEN OTHERS THEN
   p_password:=NULL; sqlStmt:=NULL;
   BEGIN
      IF cursor_name IS NOT NULL AND DBMS_SQL.IS_OPEN(cursor_name) THEN
         DBMS_SQL.CLOSE_CURSOR(cursor_name); cursor_name:=NULL;
      END IF;
   EXCEPTION WHEN OTHERS THEN NULL;
   END;
   RAISE;
END;
/
