/*
===============================================================================
SCRIPT: profile_report.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/profile_report.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar limites de perfis incluindo classe de recurso.

FUNCIONAMENTO DETALHADO
  Consulta DBA_PROFILES com PROFILE, RESOURCE_NAME, RESOURCE_TYPE e LIMIT, ordenando esses atributos.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_PROFILES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não mostra usuários associados nem garante aplicação de limites de recursos de kernel sem configuração apropriada. Não altera política de senha ou perfil.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @profile_report.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Perfil, recurso, tipo e limite textual; DEFAULT/UNLIMITED não são valores numéricos.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  GROUP BY PROFILE inválido removido em favor de ORDER BY PROFILE/RESOURCE_TYPE/RESOURCE_NAME; spool independente. Wrappers title80/title132 ausentes substituídos por TTITLE local.
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
REM NAME        : PROFILE_REPORT.SQL
REM PURPOSE     : GENERATE USER PROFILES REPORT
REM Revisions:
REM Date          Modified by     Reason for change
REM 08-Apr-1993     MIKE AULT     INITIAL CREATE
REM 14-May-1999     MIKE AULT     Added resource_type
REM
SET FLUSH OFF TERM OFF PAGESIZE 58 LINESIZE 78
COLUMN profile           HEADING Profile
COLUMN resource_name     HEADING 'Resource:'
COLUMN resource_type     HEADING 'Resource|Affects'
COLUMN limit             HEADING Limit
ttitle 'ORACLE PROFILES REPORT'
DEFINE output = profile_report.lst
SPOOL &output
SELECT 
     profile, 
     resource_name,
     resource_type, 
     limit  
FROM 
     sys.dba_profiles
ORDER BY 
     profile, resource_type, resource_name;
SPOOL OFF
CLEAR COLUMNS
SET FLUSH ON TERM ON
TTITLE OFF

