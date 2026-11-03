/*
===============================================================================
SCRIPT: db_rct91b.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/db_rct91b.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Preparar sequência de numeração e chamar gerador RECREATE_DB2 previamente instalado.

FUNCIONAMENTO DETALHADO
  DROP/CREATE LINENO_SEQ NOCACHE e EXECUTE RECREATE_DB2.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e privilégios administrativos conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  LINENO_SEQ, procedimento RECREATE_DB2

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DDL confirma transações, drop pode invalidar dependentes; helper específico não é definido neste arquivo. Não é um script completo de CREATE DATABASE e não deve ser usado como restauração automática.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema descartável; revisar definição de RECREATE_DB2 antes.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Sequência substituída e efeitos do gerador chamado.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: pode gerar ou executar DDL/DML, expor hashes/segredos
  do banco consultado ou alterar sessão conforme descrito acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código, chamada e créditos preservados. 
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
REM FUNCTION: SCRIPT FOR CREATING 9.1 DB FROM EXISTING DB
REM           This script must be run by a user with the DBA role.
REM           This script is intended to run with Oracle9i.
REM           Running this script will in turn create a script to 
REM           rebuild the database.  This created 
REM           script, crt_db91.sql,  is run by SQLDBA
REM           Only preliminary testing of this script was performed.
REM           Be sure to test it completely before relying on it.
REM M. Ault 8/23/01 Burleson Consulting Consulting
REM
rem SET VERIFY OFF FEEDBACK OFF ECHO OFF PAGES 0
SET TERMOUT ON
PROMPT Creating db build script...
DROP SEQUENCE lineno_seq;
CREATE SEQUENCE lineno_seq MINVALUE 1 INCREMENT BY 1 NOCACHE; 
set verify on feedback on echo on

execute recreate_db2;
