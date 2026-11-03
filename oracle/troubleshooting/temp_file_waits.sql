/*
===============================================================================
SCRIPT: temp_file_waits.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/temp_file_waits.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar contenção de buffers por datafile apesar do nome temp_file_waits.

FUNCIONAMENTO DETALHADO
  Consulta X$KCBFWAIT junto a V$DATAFILE por INDX+1=FILE#; filtra TIME>0 e ordena COUNT na subconsulta, preservando a estrutura histórica.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Acesso administrativo autorizado aos objetos internos listados; não conceder privilégios amplos apenas para rodar este relatório.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  X$KCBFWAIT, V$DATAFILE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Estrutura interna sem contrato estável; mapeamento INDX+1 e unidades precisam de validação por versão. Ordem da subconsulta não garante ordenação final pela linguagem SQL.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @temp_file_waits.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  FILE#, NAME, COUNT, WAIT_TIME e RATIO; não corresponde a tempfiles de V$TEMPFILE.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  TIME/COUNT protegido por NULLIF; nome original mantido com escopo real explicitado. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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

-- comment:  Waits Per Datafile

col name format a66 heading 'Data File Name'
col count format 999,999,999 heading 'Wait Count'
col file# heading 'File#' format 9,999
col wait_time heading 'Time'
col ratio heading 'Time/Count' format 999.99
set pages 47
compute sum of count on report 
break on report
ttitle 'Waits Per Datafile'
set lines 132
spool temp_file_waits.lst
select * from (select file#,name, count, time wait_time,time/nullif(count,0) ratio
from x$kcbfwait, v$datafile
where indx + 1 = file#
and time>0
order by count desc)
/
spool off
clear columns
clear computes
ttitle off
set pages 22 lines 80
