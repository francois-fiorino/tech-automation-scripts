/*
===============================================================================
SCRIPT: parm_desc.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/parm_desc.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar parâmetros visíveis e sua descrição no contexto da sessão.

FUNCIONAMENTO DETALHADO
  Consulta V$PARAMETER ordenada por NAME e exibe valor/default e modificabilidade.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$PARAMETER

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não é conteúdo completo de SPFILE nem inventário de parâmetros underscore. VALUE pode ser truncado pela largura 30; proteger valores e caminhos do relatório. Não executa ALTER.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @parm_desc.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Nome, valor, default, sessão/sistema modificável e descrição.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta preservada; título local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
REM NAME        : PARAM_desc.SQL
REM FUNCTION    : GENERATE LIST OF DB PARAMETERS
REM USE         : GENERAL
REM Limitations : None
REM
SET NEWPAGE 0 VERIFY OFF
SET PAGES 10000 lines 131
column name  format a37
column value format a30 
column description format a40 word_wrapped
ttitle "INIT.ORA PARAMETER LISTING"
spool parm_desc.lst
SELECT name,value,isdefault default,isses_modifiable ses, 
issys_modifiable sys, description 
FROM V$PARAMETER order by name;
SPOOL OFF
CLEAR COLUMNS
pause Press enter to continue
SET VERIFY ON termout on PAGES 22 lines 80
undef output
