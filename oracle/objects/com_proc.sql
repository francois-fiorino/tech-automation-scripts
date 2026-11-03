/*
===============================================================================
SCRIPT: com_proc.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/COM_PROC.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar comandos de recompilação para objetos inválidos.

FUNCIONAMENTO DETALHADO
  Consulta DBA_OBJECTS, monta ALTER por tipo e grava recompile.sql; não executa o arquivo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_OBJECTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Nem todo tipo aceita COMPILE genérico; nomes não escapados e dependências exigem revisão. Recompilar pode invalidar dependentes ou consumir recursos se comandos forem executados.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @com_proc.sql
  -- Revisar recompile.sql antes de qualquer execução.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Texto DDL para objetos STATUS=INVALID.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  PACKAGE BODY/TYPE BODY geram COMPILE BODY no tipo base, evitando recompilar especificação desnecessariamente. Outros tipos preservados para revisão. 
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
rem
rem Function: Create a compile list for invalid objects
rem
rem MRA 5/1/96
rem
set heading off pages 0 echo off termout off feedback off verify off
spool recompile.sql
select 'alter '||decode(object_type,'PACKAGE BODY','PACKAGE','TYPE BODY','TYPE',object_type)||' '||owner||'.'||object_name||' compile'||case when object_type in ('PACKAGE BODY','TYPE BODY') then ' body;' else ';' end
from dba_objects where status='INVALID'
/
spool off
set heading on echo on termout on feedback on verify on
undef cr
