/*
===============================================================================
SCRIPT: v$view_def.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/v$view_def.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar definições internas de views fixas Oracle.

FUNCIONAMENTO DETALHADO
  SELECT * em SYS.V_$FIXED_VIEW_DEFINITION com formatação de nome/definição.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$FIXED_VIEW_DEFINITION

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Definição interna não é API estável nem script completo de recriação. Texto pode ser truncado pela view/cliente. Requer leitura administrativa e pode expor estruturas internas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @v$view_def.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  VIEW_NAME, VIEW_DEFINITION e colunas adicionais da versão.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta preservada. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
column view_name format a20 heading 'V$ View Name'
column view_definition format a50 word_wrapped heading 'View SQL Definition'
set lines 78 pages 47 verify off feedback off
ttitle 'V$ View Definitions'
spool v$view_def.lst
select * from sys.v_$fixed_view_definition 
/
spool off
set pages 22 verify on feedback on
ttitle off
clear columns
