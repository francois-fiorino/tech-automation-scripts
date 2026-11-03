/*
===============================================================================
SCRIPT: free2_spc.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _tablespace_scripts/free2_spc.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Comparar extents livres de view com bytes totais de pacote customizado.

FUNCIONAMENTO DETALHADO
  Agrupa FREE_SPACE e chama DBA_UTILITIES.GET_BYTES para total, usado por diferença e porcentagem livre.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  FREE_SPACE (customizada), DBA_UTILITIES.GET_BYTES (customizado)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Pacote e contrato não fornecidos neste relatório: confirmar total alocado, tipo e ausência de efeitos laterais antes de execução. FREE_SPACE omite arquivos sem extents livres. Não inclui autoextend potencial; FSFI não é medido aqui.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @free2_spc.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  MiB livres/maiores, soma dos máximos sobre livre, total/used MiB e percent free total.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF protege total livre e retorno zero de GET_BYTES; funcionalidades do pacote preservadas como dependência explícita. 
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
rem Name:     free_spc.sql
rem
rem FUNCTION: Provide data on tablespace extent status
rem FUNCTION: this report uses the free_space view
rem
rem Mike Ault Burleson Consulting
rem
SET FEED OFF
SET FLUSH OFF
SET VERIFY OFF
set pages 58 LINES 130
column tablespace      heading Name              format a30
column file_id         heading File#             format 99999
column pieces          heading Frag              format 9999
column free_bytes      heading 'Free Meg'       format 99,999.99
column largest_bytes   heading 'Biggest|Free Meg' format 99,999.99
column ratio           heading 'Percent of|Free Meg'         format 999.999
column total_meg        heading 'Total|Meg'     format 99,999.999
column used_meg		heading 'Total|Used Meg'	format 99,999,999.99
column meg_ratio        heading 'Percent Free|Total Meg'     format 999.99
break on total_meg on used_meg
compute sum of total_meg on report 
compute sum of used_meg on report
ttitle "FREE SPACE REPORT"
define 1 = 'free2_spc.lst'
spool &1
select a.tablespace,count(a.tablespace) files,sum(a.pieces) pieces,
sum(a.free_bytes)/1048576 free_bytes,
sum(a.largest_bytes)/1048576 largest_bytes,
sum(a.largest_bytes)/nullif(sum(a.free_bytes),0)*100 ratio,
DBA_UTILITIES.get_bytes(a.tablespace)/1048576 Total_meg, 
(DBA_UTILITIES.get_bytes(a.tablespace)/1048576)-(sum(a.free_bytes)/1048576) used_meg,
(sum(a.free_bytes)/nullif(DBA_UTILITIES.get_bytes(a.tablespace),0)*100) meg_ratio
from free_space a
group by tablespace
order by tablespace, total_meg, used_meg;
spool off
clear columns
pause Press Enter to Continue
SET FEED ON
SET FLUSH ON
SET VERIFY ON
set pages 22 LINES 80
clear columns
ttitle off
