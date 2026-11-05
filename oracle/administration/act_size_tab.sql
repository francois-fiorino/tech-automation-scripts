/*
===============================================================================
SCRIPT: act_size_tab.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _table_scripts/act_size_tab.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Coletar contagem de blocos com linhas e compará-la com segmentos.

FUNCIONAMENTO DETALHADO
  DELETE em TEMP_SIZE_TABLE, gera/START FILL_SZ com INSERT COUNT por tabela, HOST DEL intermediário, reporta e apaga staging novamente.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme LIMITAÇÕES; roles não
  bastam para compilar dependências de rotinas armazenadas.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  TEMP_SIZE_TABLE, DBA_SEGMENTS, V$PARAMETER, DBMS_ROWID, SQL*Plus HOST

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Modifica dados e executa arquivo/remoção SO; sem COMMIT explícito, DDL posterior/EXIT pode confirmar. Varredura de todas as tabelas é cara. Identificação por ROWID restrito/prefixo pode colidir; relatório não filtra owner e staging não tem owner. Não usar resultado como ocupação exata sem correção homologada.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório Windows com staging exclusivo: revisar @act_size_tab.sql.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Arquivo gerado, contagens e relatório de blocos; staging fica limpo na transação.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados ou sessão descritos
  acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Fluxo e cálculos preservados para revisão; problemas de identidade/owner assinalados sem reescrever algoritmo sem testes. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 040 — 04/11/2026
  Correções e melhorias: Corpo preservado; problemas de identidade e escopo bloqueiam homologação.
  Limitações e pendências: Owner do relatório não é filtrado, staging sem owner mistura homônimos e prefixo ROWID não identifica unicamente arquivo/objeto/bloco. COMMENT: não é comentário SQL*Plus válido; arquivos FILL_SZ sobrescritos/START/HOST DEL.
  Homologação necessária: Fixture com mesmo nome em dois owners e mesmo bloco em arquivos diferentes; tabela vazia; validar formato cliente antes de gerar/rodar saída.
  Parâmetros e execução: contrato detalhado acima e no corpo; somente laboratório.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  sem Windows, exportação, job ou comando administrativo executado.

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

comment:  Will show actual block used vs allocated for all tables for a user. 

rem  INPUTS:  owner = Table owner name.
rem  requires temp_size_table (table_name varchar2(64), blocks number)be created.
rem  **************************************************************************

accept owner prompt 'Enter table owner name: '
set heading off feedback off verify off echo off recsep off pages 0
column db_block_size new_value blocksize noprint
ttitle off
define cr='chr(10)'
define qt='chr(39)'
delete temp_size_table;
select value db_block_size from v$parameter where name='db_block_size';
SPOOL fill_sz.sql
SELECT 'INSERT INTO temp_size_table'||&&cr||
	 'SELECT '||&&qt||segment_name||&&qt||&&cr||
	 ',COUNT( DISTINCT( SUBSTR( dbms_rowid.rowid_to_restricted(ROWID,1),1,8))) blocks'||&&cr||
        'FROM &&owner..'||segment_name, ';'
  FROM dba_segments
 WHERE segment_type ='TABLE' AND owner = upper('&owner');
SPOOL OFF
START fill_sz
HOST del  fill_sz.sql
define bs = '&&blocksize K'
COLUMN t_date NOPRINT new_value t_date
COLUMN user_id NOPRINT new_value user_id
COLUMN segment_name FORMAT A25 HEADING "SEGMENT|NAME"
COLUMN segment_type FORMAT A7 HEADING "SEGMENT|TYPE"
COLUMN extents FORMAT 999 HEADING "EXTENTS"
COLUMN kbytes FORMAT 999,999,999 HEADING "KILOBYTES"
COLUMN blocks FORMAT 9,999,999 HEADING "ALLOC.|&&bs|BLOCKS"
COLUMN act_blocks FORMAT 9,999,990 HEADING "USED|&&bs|BLOCKS"
COLUMN pct_block FORMAT 999.99 HEADING "PCT|BLOCKS|USED"
ttitle "Actual Size Report for &owner"
set pages 55
break on report on segment_type skip 1
compute sum of kbytes on segment_type report 
spool act_size_tab.lst
SELECT segment_name, segment_type,sum(extents) extents, sum(bytes)/1024 kbytes, 
       sum(a.blocks) blocks,nvl(max(b.blocks),0) act_blocks, 
       (max(b.blocks)/sum(a.blocks))*100 pct_block
  FROM sys.dba_segments a, temp_size_table b
 WHERE segment_name = UPPER( b.table_name )
 GROUP BY segment_name, segment_type
 ORDER BY segment_type,segment_name;
SPOOL OFF
delete temp_size_table;
set termout on feedback 15 verify on pagesize 20 linesize 80 space 1
undef qt
undef cr
ttitle off
clear columns 
clear computes
pause press enter to continue

