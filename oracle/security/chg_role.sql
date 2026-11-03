/*
===============================================================================
SCRIPT: chg_role.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / misc_scripts/CHG_ROLE.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar função histórica para habilitar role protegida por senha.

FUNCIONAMENTO DETALHADO
  Monta bloco DBMS_SESSION.SET_ROLE com role/senha de parâmetros, executa via DBMS_SQL e retorna código.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBMS_SQL, DBMS_SESSION; função CHANGE_ROLE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE/EXECUTE diretos. SET ROLE em rotina definer rights tem restrições; concatenação sem validação/escaping é insegura e buffers 32/300 são legados. Não pronta para implantação.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Não usar senhas reais; somente revisão de contexto e política em laboratório.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Função criada; chamada pode alterar conjunto de roles ou falhar por contexto.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Impressão de SQL com senha removida; demais pontos de segurança/contexto explicitados sem reescrita especulativa. 
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
create or replace FUNCTION Change_role(
	role_in in varchar2,
	newpass in VARCHAR2) RETURN NUMBER AS
p_password VARCHAR2(32) := newpass;
p_role     varchar(32) := role_in;
no_of_rows number;
cursor_name INTEGER;
sqlStmt varchar2(300);

BEGIN
   cursor_name := dbms_sql.open_cursor;
   SqlStmt:='begin dbms_session.set_role('||chr(39)||p_role||' identified by '||p_password||chr(39)||'); END;';
   -- SQL contém senha: não imprimir nem registrar em log.
   dbms_sql.parse(cursor_name,sqlstmt,dbms_sql.v7);
   no_of_rows := dbms_sql.execute(cursor_name);
   dbms_sql.close_cursor(cursor_name);
   RETURN no_of_rows;
END;
/
