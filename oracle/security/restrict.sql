/*
===============================================================================
SCRIPT: restrict.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / misc_scripts/RESTRICT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Inserir restrições de comandos SQL*Plus em PRODUCT_USER_PROFILE.

FUNCIONAMENTO DETALHADO
  Dezesseis INSERTs de ATTRIBUTE DISABLED para username e COMMIT, incluindo SELECT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e privilégios administrativos conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  PRODUCT_USER_PROFILE (estrutura SQL*Plus legada)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não controla privilégios do servidor e pode ser contornado por outros clientes. Original desabilita SELECT também, contrariando comentário de somente SELECT; comportamento preservado para revisão. DML e COMMIT podem confirmar trabalho do chamador.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório compatível; não aplicar em usuário de trabalho.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Regras persistidas para cliente que respeita a tabela.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: pode gerar ou executar DDL/DML, expor hashes/segredos
  do banco consultado ou alterar sessão conforme descrito acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  CHAR_VALUE. corrigido para CHAR_VALUE, na lista de colunas do AUDIT; todas as restrições mantidas. 
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
REM*********************************************************
REM PRODUCT_USER_PROFILE.SQL
REM
REM SCRIPT RESTRICTS A USERS ABILITY TO USE SQL FOR ANYTHING
REM OTHER THAN SELECT. RESTRICTS ALTER, AUDIT, CONNECT,
REM CREATE, DELETE, DROP, GRANT, INSERT, LOCK, NOAUDIT,
REM RENAME, REVOKE, INSERT INTO, HOST AND ANALYZE COMMANDS.
REM
REM USE: SQLPLUS SYSTEM/PW @USER_PRODUCT_PROFILE USERNAME
REM
REM    DATE        CHANGE          	REASON      	NAME
REM    -------     -------------------------- 	------------	------------
REM    8/6/92      INITIAL CREATE  	N/A         	M. AULT
REM    1/11/97	Updated to V7		V6 not used	M.Ault
REM******************************************************************
SET VERIFY OFF
INSERT INTO PRODUCT_USER_PROFILE (
PRODUCT,
USERID,
ATTRIBUTE,
CHAR_VALUE)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'ALTER','DISABLED');

INSERT INTO PRODUCT_USER_PROFILE (
PRODUCT,
USERID,
ATTRIBUTE,
CHAR_VALUE,
DATE_VALUE)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'AUDIT','DISABLED',sysdate);

INSERT INTO PRODUCT_USER_PROFILE (
PRODUCT,
USERID,
ATTRIBUTE,
CHAR_VALUE,
DATE_VALUE)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'CONNECT','DISABLED',sysdate);

INSERT INTO PRODUCT_USER_PROFILE (
PRODUCT,
USERID,
ATTRIBUTE,
CHAR_VALUE,
DATE_VALUE)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'CREATE','DISABLED',sysdate);

INSERT INTO PRODUCT_USER_PROFILE (
PRODUCT,
USERID,
ATTRIBUTE,
CHAR_VALUE,
DATE_VALUE)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'DELETE','DISABLED',sysdate);

INSERT INTO PRODUCT_USER_PROFILE (
PRODUCT,
USERID,
ATTRIBUTE,
CHAR_VALUE,
DATE_VALUE)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'DROP','DISABLED',sysdate);

INSERT INTO PRODUCT_USER_PROFILE (
PRODUCT,
USERID,
ATTRIBUTE,
CHAR_VALUE,
DATE_VALUE)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'GRANT','DISABLED',sysdate);

INSERT INTO PRODUCT_USER_PROFILE (
PRODUCT,
USERID,
ATTRIBUTE,
CHAR_VALUE,
DATE_VALUE)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'INSERT','DISABLED',sysdate);

INSERT INTO PRODUCT_USER_PROFILE (
PRODUCT,
USERID,
ATTRIBUTE,
CHAR_VALUE,
DATE_VALUE)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'LOCK','DISABLED',sysdate);

INSERT INTO PRODUCT_USER_PROFILE (
PRODUCT,
USERID,
ATTRIBUTE,
CHAR_VALUE,
DATE_VALUE)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'NOAUDIT','DISABLED',sysdate);

INSERT INTO PRODUCT_USER_PROFILE (
PRODUCT,
USERID,
ATTRIBUTE,
CHAR_VALUE,
DATE_VALUE)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'RENAME','DISABLED',sysdate);

INSERT INTO PRODUCT_USER_PROFILE (
PRODUCT,
USERID,
ATTRIBUTE,
CHAR_VALUE,
DATE_VALUE)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'REVOKE','DISABLED',sysdate);

INSERT INTO PRODUCT_USER_PROFILE (
PRODUCT,
USERID,
ATTRIBUTE,
CHAR_VALUE,
DATE_VALUE)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'UPDATE','DISABLED',sysdate);

INSERT INTO PRODUCT_USER_PROFILE (
PRODUCT,
USERID,
ATTRIBUTE,
CHAR_VALUE,
DATE_VALUE)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'ANALYZE','DISABLED',sysdate);

INSERT INTO PRODUCT_USER_PROFILE (
PRODUCT,
USERID,
ATTRIBUTE,
CHAR_VALUE,
DATE_VALUE)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'HOST','DISABLED',sysdate);

INSERT INTO PRODUCT_USER_PROFILE (
PRODUCT,
USERID,
ATTRIBUTE,
CHAR_VALUE,
DATE_VALUE)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'SELECT','DISABLED',sysdate);

COMMIT;

