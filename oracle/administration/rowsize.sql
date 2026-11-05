/*
===============================================================================
SCRIPT: rowsize.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _table_scripts/ROWSIZE.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar e executar consulta de tamanho médio de linhas de tabela.

FUNCIONAMENTO DETALHADO
  Spool SELECT dinâmico com VSIZE para cada coluna, soma overhead fixo e divide por COUNT; START executa arquivo gerado.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme LIMITAÇÕES; roles não
  bastam para compilar dependências de rotinas armazenadas.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TAB_COLUMNS, DUAL, tabela informada; SQL*Plus START

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Varre toda tabela e pode ser caro. VSIZE não suporta todos os tipos, não representa storage externo de LOB; overhead fixo é heurístico. Nomes não escapados podem injetar código. TERMOUT/SQLCASE modificados e saída executada automaticamente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente tabela pequena de teste e nomes controlados: @rowsize.sql.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Arquivo SQL local e relatório de count/tamanho médio em bytes.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados ou sessão descritos
  acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  ORDER BY 1 no UNION garante ordem dos fragmentos; divisor COUNT protegido por NULLIF. Spool local &cfile..sql consistente com START. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 039 — 04/11/2026
  Correções e melhorias: Gerador preservado, incluindo NULLIF e ordenação.
  Limitações e pendências: Sem colunas visíveis produz SQL incompleto; tipos LONG/LOB/objetos e nomes não escapados exigem revisão. VSIZE mais overhead fixo não é tamanho físico. START automático e caminho de saída confiável.
  Homologação necessária: Tabela vazia, uma coluna, NULL, LOB, nomes quoted e custo de full scan em laboratório.
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
rem  **************************************************************************
rem  NAME: rowsize.sql     
rem  NOTES:        Currently requires DBA.
rem  INPUTS:
rem         tname  = Name of table.
rem         towner = Name of owner of table.
rem	    cfile  = Name of output SQL Script file
rem  **************************************************************************
column dum1  	noprint
column rsize 	format 99,999.99
column rcount 	format 999,999,999 newline 
accept tname  	prompt 'Enter table name: '
accept towner 	prompt 'Enter owner name: '
accept cfile  	prompt 'Enter name for output SQL script file: '
set pagesize 999  heading off  verify off  termout off
set feedback off  sqlcase upper  newpage 3
spool &cfile..sql
select 0 dum1,
       'select ''Table '||'&towner..&tname'||
      ' has '',count(*) rcount,'' rows of '', ('   from dual
union
select column_id,
      'sum(nvl(vsize('||column_name||'),0)) + 1 +'  from dba_tab_columns 
 where table_name = '&tname' and owner = '&towner'
   and column_id <> (select max(column_id)
                     from dba_tab_columns
		    where table_name = '&tname'
		      and owner = '&towner')
union
select column_id,
      'sum(nvl(vsize('||column_name||'),0)) + 1)'
  from dba_tab_columns 
 where table_name = '&tname' and owner = '&towner'
   and column_id = (select max(column_id)
                     from dba_tab_columns
		    where table_name = '&tname'
		      and owner = '&towner')
union 
select 997,  '/ nullif(count(*),0) + 5 rsize, '' bytes each.'''  from dual
union 
select 999,  'from &towner..&tname.;'  from dual order by 1;
spool off
set termout on  feedback on   pagesize 20   sqlcase mixed   newpage 1
start &cfile
clear columns
undef cfile
undef tname
undef towner
set verify on heading on
