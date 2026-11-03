/*
===============================================================================
SCRIPT: waits_file.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _wait_event_scripts/waits_file.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Apresentar contadores internos de contenção por datafile.

FUNCIONAMENTO DETALHADO
  Une X$KCBFWAIT a V$DATAFILE por INDX+1=FILE# e filtra TIME>0; configura quebras e totais no SQL*Plus.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Acesso administrativo autorizado a X$KCBFWAIT e SELECT em V$DATAFILE; não conceder privilégios amplos apenas para rodar este relatório.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  X$KCBFWAIT, V$DATAFILE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Tabela fixa interna sem contrato estável de compatibilidade; confirmar mapeamento e unidades. Métrica não equivale a serviço de I/O.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @waits_file.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Arquivo, contagem, tempo e razão; saída ordenada por contagem e NULL para razão indefinida.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF(COUNT,0) evita divisão por zero; removido primeiro SPOOL redundante que era substituído imediatamente por waits_file.lst. Wrappers title80/title132 ausentes substituídos por TTITLE local.
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
col name format a50 heading 'Data File Name'
col count format 999,999,999 heading 'Wait|Count'
col file# heading 'File#' format 9,999
col wait_time heading 'Time'
col ratio heading 'Time|Count' format 999.99
set pages 47
compute sum of count on report 
break on report
ttitle 'Waits Per Datafile'
set lines 132
spool waits_file.lst
SELECT file#, name, count, time wait_time,
time/nullif(count,0) ratio
FROM x$kcbfwait, v$datafile
WHERE indx + 1 = file#
AND time>0
Order By count DESC
/
spool off
clear columns
clear computes
ttitle off
set pages 22 lines 80
