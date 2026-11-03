/*
===============================================================================
SCRIPT: link_rct.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/LINK_RCT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar DDL histórico de database links a partir de tabelas internas.

FUNCIONAMENTO DETALHADO
  Lê metadados de DBA_DB_LINKS, gera DDL textual com placeholders de senha e barreira EXIT; não coleta autenticação nem instala objetos.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e privilégios administrativos conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_DB_LINKS, DBMS_ASSERT, DBMS_OUTPUT e spool local do SQL*Plus; sem dependência de SYS.LINK$/SYS.USER$.

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não restaura segredos, credenciais, links SHARED/authenticated e todos os atributos modernos. CONNECT privado exige autenticação manual; PUBLIC exige conta autorizada sem assumir SYS. Saída é proposta bloqueada, não roteiro aplicável sem revisão. Metadados de HOST podem conter informação sensível e precisam de proteção; rejeitar/remover eventual credencial embutida no catálogo antes de compartilhar o spool. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Revisão somente; não executar contra credenciais reais nem divulgar sua saída.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Rascunho CRT_DBLS.SQL que pode conter material de autenticação extraído.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: pode gerar ou executar DDL/DML, expor hashes/segredos
  do banco consultado ou alterar sessão conforme descrito acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 037 (2026-11-03): Gerador reimplementado por DBA_DB_LINKS sem ler SYS.LINK$/senhas, sem staging DDL e sem minúsculas ou remoção de domínio. Saída contém marcadores de segredo e EXIT bloqueante; HOST é citado com escape de apóstrofo e identificadores por DBMS_ASSERT; marcadores usuais de autenticação no HOST são retidos, sem garantia de anonimização de descriptor arbitrário. Casos de homologação: Link conectado/fixed user; nome com domínio/quoted; host com apóstrofo; PUBLIC versus privado; catálogo vazio; limite DBMS_OUTPUT; saída deve começar com EXIT bloqueante. Comentários/créditos históricos preservados. Não aprovado para implantação.

REFERÊNCIAS TÉCNICAS DA REVISÃO 037
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_DB_LINKS.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_ASSERT.html

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
REM
REM link_rct.sql
REM
REM    comment: SCRIPT FOR RE-CREATING DATABASE LINKS
REM
REM              This script must be run by 'SYS'.  
REM 
REM              This script is intended to run with Oracle7.
REM
REM Running this script will in turn create a script to build all the 
REM database links in the database.  This created script is called 
REM 'crt_dbls.sql'.
REM 
REM Since a DBA cannot create a private database link on behalf of a user,
REM this script will contain various connect clauses before each create 
REM statement.  In order for the database links to be created under
REM the correct schema, it must connect as that individual.  Therefore, 
REM before executing the script, you must add each user's password to the 
REM connect clause.  Duplicate connect clauses can be eliminated being 
REM sure that the database link is being created under the correct schema.  
REM
REM The PUBLIC database links will require a connect as 'SYS'.  However, this 
REM username can be changed to any user with the DBA role or with the 
REM 'CREATE PUBLIC DATABASE LINK' system privilege.
REM
REM The spooled output is ordered by the database link owner, a PUBLIC database 
REM link has 'PUBLIC' as it's owner.
REM
REM Only preliminary testing of this script was performed.  Be sure to test 
REM it completely before relying on it.  
REM
 
REM Revisao 037: comentarios acima sao historicos; nao inserir senhas na saida.
set define off
set verify off feedback off echo off heading off pagesize 0
set linesize 32767
set serveroutput on size unlimited
spool dblink_recreation_review.sql
prompt REM Proposta de recriacao de links; configurar autenticacao em copia privada.
prompt REM Bloqueio incondicional: revisar todos os comandos antes de adaptar.
prompt EXIT FAILURE ROLLBACK
begin
 for r in (select owner,db_link,username,host from dba_db_links order by owner,db_link) loop
  if r.owner='PUBLIC' then
   DBMS_OUTPUT.PUT_LINE('REM Conectar manualmente a conta autorizada para CREATE PUBLIC DATABASE LINK.');
  else
   DBMS_OUTPUT.PUT_LINE('CONNECT '||DBMS_ASSERT.ENQUOTE_NAME(r.owner,FALSE));
  end if;
  DBMS_OUTPUT.PUT_LINE('CREATE '||case when r.owner='PUBLIC' then 'PUBLIC ' end||
   'DATABASE LINK '||DBMS_ASSERT.ENQUOTE_NAME(r.db_link,FALSE));
  if r.username is not null then
   DBMS_OUTPUT.PUT_LINE('CONNECT TO '||DBMS_ASSERT.ENQUOTE_NAME(r.username,FALSE)||
    ' IDENTIFIED BY "<DEFINIR_SENHA_REMOTA>"');
  end if;
  if r.host is not null then
   IF REGEXP_LIKE(r.host,'(PASSWORD|PWD|TOKEN|SECRET)[[:space:]]*=','i')
      OR REGEXP_LIKE(r.host,'[^/[:space:]]+/[^@[:space:]]+@') THEN
    DBMS_OUTPUT.PUT_LINE('REM HOST retido por marcador de autenticacao; configurar servico sem segredo.');
    DBMS_OUTPUT.PUT_LINE('USING '||CHR(39)||'<DEFINIR_SERVICO_REMOTO>'||CHR(39)||';');
   ELSE
    DBMS_OUTPUT.PUT_LINE('USING '||CHR(39)||REPLACE(r.host,CHR(39),CHR(39)||CHR(39))||CHR(39)||';');
   END IF;
  else
   DBMS_OUTPUT.PUT_LINE(';');
  end if;
 end loop;
end;
/
spool off
set heading on feedback on
