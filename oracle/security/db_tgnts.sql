/*
===============================================================================
SCRIPT: db_tgnts.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / misc_scripts/DB_TGNTS.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar grants de objetos excluindo owners SYS/SYSTEM.

FUNCIONAMENTO DETALHADO
  Consulta TAB_PRIVS e ordena owner/objeto/grantor/grantee; usa quebras por destinatário.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TAB_PRIVS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não inclui privilégios de coluna, sistema ou herdados por roles; não calcula acesso efetivo. Contrariamente ao comentário de input, não há filtro interativo de owner.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @db_tgnts.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner/objeto, grantee, grantor, privilégio e grant option.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  OUTPUT local; consulta preservada. 
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
rem******************************************************************* 
rem  NAME: db_tgnts.sql      
rem 
rem  FUNCTION: Produce report of table or procedure grants showing 
rem  GRANTOR, GRANTEE or ROLE and specific GRANTS.  
rem 
rem  INPUTS: Owner name 
rem ******************************************************************** 
rem 
COLUMN grantee         FORMAT A18     HEADING "Grantee|or Role" 
COLUMN owner           FORMAT A18     HEADING "Owner" 
COLUMN table_name      FORMAT A30     HEADING "Table|or Proc" 
COLUMN grantor         FORMAT A18     HEADING "Grantor" 
COLUMN privilege       FORMAT A10     HEADING "Privilege" 
COLUMN grantable       FORMAT A19     HEADING "Grant|Option?" 
rem 
BREAK ON owner SKIP 4 ON table_name SKIP 1 ON grantee ON grantor ON REPORT 
rem 
SET LINESIZE 130 PAGES 56 VERIFY OFF FEEDBACK OFF 
ttitle "TABLE GRANTS BY OWNER AND TABLE"
define output = db_tgnts.lst
SPOOL &output 
REM 
SELECT 
     owner, 
     table_name, 
     grantee, 
     grantor,  
     privilege, 
     grantable 
FROM 
     dba_tab_privs 
WHERE 
     owner NOT IN ('SYS','SYSTEM') 
ORDER BY 
     owner, 
     table_name, 
     grantor, 
     grantee; 
REM 
SPOOL OFF 
PAUSE Press enter to continue

