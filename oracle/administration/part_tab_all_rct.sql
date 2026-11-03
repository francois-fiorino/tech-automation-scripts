/*
===============================================================================
SCRIPT: part_tab_all_rct.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _table_scripts/part_tab_all_rct.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Orquestrar geração de DDL de todas as tabelas particionadas por RECREATE_TABLE.

FUNCIONAMENTO DETALHADO
  TRUNCATE T_TEMP, DROP/CREATE LINENO_SEQ, EXECUTE RECREATE_TABLE, spool ordenado e DROP T_TEMP.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas conforme limitações individuais.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  T_TEMP, LINENO_SEQ, RECREATE_TABLE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DDL confirma transações e pode invalidar dependentes. Não cria T_TEMP aqui e DROP final destrói estrutura preexistente. Helper gera DROP TABLE e modelos RANGE/HASH legados, não backup completo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema descartável com RECREATE_TABLE revisado na mesma branch.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  CREATE_PART_TABLE.SQL; staging apagado e sequência recriada.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos de criação, staging, autenticação, sessão
  ou código gerado descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Fluxo completo preservado; dependência agora proposta em RECREATE_TABLE.SQL, sem instalação automática. 
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
REM
REM part_tab_rct.sql
REM
REM FUNCTION: SCRIPT FOR CREATING PARTITIONED TABLES
REM
REM           This script can be run by any user .
REM
REM           This script is intended to run with Oracle8i.
REM
REM           Running this script will in turn create a script to 
REM           build all the partitioned tables owned by the user in the database.  
REM           This created script, create_part_table.sql, can be run by any user 
REM           with the 'CREATE TABLE' system privilege. 
REM
REM NOTE:     The script will NOT include constraints on tables.  This 
REM           script will also NOT capture tables created by user 'SYS'.
REM
REM Only preliminary testing of this script was performed.  Be sure to test
REM it completely before relying on it.
REM
 
set verify off
rem set feedback off
rem set echo off;
set pagesize 0 lines 132 embedded on
 
set termout on
select 'Creating table build script...' from dual;
rem set termout off
 
truncate table t_temp;
drop sequence lineno_seq;
create sequence lineno_seq start with 1 increment by 1 nocache nocycle;

 
set heading off trimspool on
execute recreate_table
spool create_part_table.sql
 
select   text
from     T_temp
order by  tb_name, lineno;
 
spool off
 
drop table t_temp;
set verify on
set feedback on
set termout on
set pagesize 22 lines 80


