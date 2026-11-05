/*
===============================================================================
SCRIPT: grant_rc.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / _security_scripts/GRANT_RC.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Capturar grants de objetos em ordem de dependência e grantor.

FUNCIONAMENTO DETALHADO
  CREATE G_TEMP, consulta OBJAUTH$/OBJ$/USER$/mapa de privilégios por SEQUENCE#, grava GRANTs e CONNECTs e remove staging.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e privilégios administrativos conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.OBJAUTH$, SYS.OBJ$, SYS.USER$, SYS.TABLE_PRIVILEGE_MAP, DUAL, G_TEMP

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Tabelas internas Oracle7 sem contrato moderno; DDL confirma dados do chamador. Buffers 20/255 limitam nomes e texto. Sequência de grants deve ser preservada; saída revela acesso e não calcula privilégios efetivos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório; não executar grants gerados sem revisão de destinatários.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Script de grants com grant option, excluindo grantor SYS e grants de coluna.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: pode gerar ou executar DDL/DML, expor hashes/segredos
  do banco consultado ou alterar sessão conforme descrito acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  CONNECT gerado sem / incompleto, permitindo prompt de autenticação em vez de exigir senha escrita; ordem por SEQUENCE# e toda lógica preservadas. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 039 — 04/11/2026
  Correções e melhorias: WRITE_OUT agora usa seus parâmetros; falhas SQL interrompem antes de reutilizar G_TEMP.
  Limitações e pendências: SYS.OBJAUTH$ é interface interna; buffers 20/255, nomes LOWER e ordem de grantor ainda limitam fidelidade. Não adicionar senhas ao arquivo apesar da recomendação histórica.
  Homologação necessária: G_TEMP preexistente, falha intermediária, grants em cadeia e nomes quoted; comparar grantor e ordem.
  Parâmetros/execução: manter contrato descrito acima e no corpo histórico.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação realizada: leitura integral e comparação estática; sem compilação
  ou execução Oracle, sem execução de comandos administrativos.

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

/*  */
REM
REM  FUNCTION: SCRIPT FOR CAPTURING OBJECT GRANTS
REM
REM  FUNCTION: This script must be run by a user with the DBA role.
REM
REM This script is intended to run with Oracle7.
REM
REM  FUNCTION: Running this script will create a script of all the object
REM  FUNCTION: grants to users and roles.  This created script is called 
REM  FUNCTION: grant_rc.sql.
REM
REM Since a DBA cannot grant objects other than his own, this script will 
REM contain various connect clauses before each set of grant statements.  
REM You must add the passwords for each user before executing the script.  
REM Object grants are very dependant on the user who issues the grant, 
REM therefore, it is important that the correct user issue the grant.
REM 
REM In addition, DO NOT change the order of the grant statement.  They are 
REM spooled in sequence order, so that dependant grants are executed in 
REM the correct order.  For example, lets say that Scott grants Jack select on 
REM emp with grant option, and in turn Jack grants select on Scott.emp to 
REM Steve.  It is essential that Scott's grant be issued before Jack's.  
REM Otherwise, Jack's grant will fail.
REM
REM NOTE:  This script DOES NOT include grants made by 'SYS'.
REM
REM Only preliminary testing of this script was performed.  Be sure to test
REM it completely before relying on it.
REM
 
set verify off
set feedback off
rem set termout off
set echo off
set pagesize 500
set heading off
set recsep off
define cr='chr(10)'
set termout on
select 'Creating object grant script by user...' from dual;
rem set termout off
 
whenever sqlerror exit failure rollback
create table g_temp (seq NUMBER, grantor_owner varchar2(20),
                    text VARCHAR2(255))
/ 
DECLARE
   cursor grant_cursor is 
       SELECT ur$.name, uo$.name, o$.name, ue$.name,
              m$.name, t$.sequence#, 
              decode(NVL(t$.option$,0), 1, ' WITH GRANT OPTION;',';')
       FROM sys.objauth$ t$, sys.obj$ o$, sys.user$ ur$,
            sys.table_privilege_map m$, sys.user$ ue$, sys.user$ uo$
       WHERE o$.obj# = t$.obj# AND t$.privilege# = m$.privilege AND
             t$.col# IS NULL AND t$.grantor# = ur$.user# AND
             t$.grantee# = ue$.user# and 
             o$.owner#=uo$.user# and 
             t$.grantor# != 0
       order by sequence#;
   lv_grantor    sys.user$.name%TYPE;
   lv_owner      sys.user$.name%TYPE;
   lv_table_name sys.obj$.name%TYPE;
   lv_grantee    sys.user$.name%TYPE;
   lv_privilege  sys.table_privilege_map.name%TYPE;
   lv_sequence   sys.objauth$.sequence#%TYPE;
   lv_option     VARCHAR2(30);
   lv_string     VARCHAR2(255);
   lv_first      BOOLEAN;
 
   procedure write_out(p_seq INTEGER, p_owner VARCHAR2, p_string VARCHAR2) is
   begin
      insert into g_temp (seq, grantor_owner,text)
             values (p_seq, p_owner, p_string);
   end;
 
BEGIN
  OPEN grant_cursor;
    LOOP
      FETCH grant_cursor INTO lv_grantor,lv_owner,lv_table_name,lv_grantee,
         lv_privilege,lv_sequence,lv_option;
      EXIT WHEN grant_cursor%NOTFOUND;
      lv_string := 'GRANT ' ||lv_privilege||' ON '||lower(lv_owner)||'.'||
                   lower(lv_table_name) ||&&cr||
		   ' TO ' ||lower(lv_grantee) ||&&cr||
                   lv_option;
      write_out(lv_sequence, lv_grantor,lv_string);
    END LOOP;
  CLOSE grant_cursor;
END;
/
@title80 ''
ttitle off 
spool rep_out\&db\grt_o_gr.sql
break on guser skip 1
col text format a60 word_wrap
 
select   'connect ' || grantor_owner guser, text
from     g_temp
order by seq, grantor_owner
/
 
spool off
 set verify on
set feedback on
set termout on
set echo on
set pagesize 22
set heading on
set recsep on
clear columns
clear computes
clear breaks
drop table g_temp;
