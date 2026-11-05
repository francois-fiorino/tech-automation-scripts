/*
===============================================================================
SCRIPT: index_size.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _index_scripts/index_size.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar e executar estimativa de bytes por entrada de índice existente.

FUNCIONAMENTO DETALHADO
  Seleciona colunas de IND_COLUMNS, compõe VSIZE por TAB_COLUMNS e executa SELECT gerado por START.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TAB_COLUMNS, DBA_IND_COLUMNS, DUAL, tabela alvo

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Contagem inclui linhas com todas as chaves NULL, que podem não existir em B-tree; overheads e compressão não são cobertos. Ordenar por COLUMN_ID não reproduz ordem das chaves. Entradas SQL*Plus e arquivo gerado são superfícies de execução; sem expressão/LOB/function-based seguro. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @index_size.sql; nomes simples e arquivo local controlado.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Contagem de linhas e estimativa de bytes por entrada.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 038 (2026-11-04): Modelo VSIZE e cálculo por COUNT(*) preservados como estimativa legada, sem alegação de medir o índice. Casos de homologação: Todas as chaves NULL; chaves compostas/parcialmenteNULL; tabelas vazias; function-based; compressão; nomes mixed; definir domínio e fórmula antes de uma reimplementação física. Comentários/créditos históricos preservados. Não aprovado para implantação.

AVISO DE RESPONSABILIDADE
AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de
qualquer utilização em produção. Sua execução é de responsabilidade do
profissional responsável pelo ambiente. Os mantenedores deste repositório não
se responsabilizam por indisponibilidade, perda de dados, alterações indevidas
ou outros impactos decorrentes de sua utilização.

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
rem  *******************************************************
rem
rem    
rem  comment:  Compute the space used by an entry for an existing index.
rem
rem  NOTES:  Currently requires DBA.
rem
rem  INPUTS:
rem         tname  = Name of table.
rem         towner = Name of owner of table.
rem         iname  = Name of index.
rem         iowner = Name of owner of index.
rem         cfile  = Name of output file SQL Script.
rem  *******************************************************
COLUMN dum1       NOPRINT
COLUMN isize      FORMAT 999,999,999.99
COLUMN rcount     FORMAT 999,999,999 NEWLINE
ACCEPT tname  PROMPT 'Enter table name: '
ACCEPT towner PROMPT 'Enter table owner name: '
ACCEPT iname  PROMPT 'Enter index name: '
ACCEPT iowner PROMPT 'Enter index owner name: '
ACCEPT cfile  PROMPT 'Enter name for output SQL file: '
SET PAGESIZE 0 HEADING OFF VERIFY OFF TERMOUT OFF 
SET FEEDBACK OFF TRIMSPOOL ON SQLBL OFF
SET SQLCASE UPPER NEWPAGE 3
SPOOL &cfile..sql
SELECT -1 dum1,
       'SELECT ''Index '||'&iowner..&iname'||' on table '
  FROM dual
UNION
SELECT 0,
       '&towner..&tname'||' has '',
       nvl(COUNT(*),0) rcount,'' entries of '', (' 
  FROM dual
UNION
SELECT column_id,
      'SUM(NVL(vsize('||column_name||'),0)) + 1 +' 
  FROM dba_tab_columns 
 WHERE table_name = upper('&tname')
   AND owner = upper('&towner') AND column_name IN
                   (SELECT column_name FROM dba_ind_columns 
                     WHERE table_name = upper('&tname')
                       AND table_owner = upper('&towner')
                       AND index_name = upper('&iname')
                       AND index_owner = upper('&iowner'))
                       AND column_id <> (select max(column_id)
                                        FROM dba_tab_columns
                                        WHERE table_name = upper('&tname')
                                        AND owner = upper('&towner')
                                        AND column_name IN
                      (SELECT column_name FROM dba_ind_columns 
                        WHERE table_name = upper('&tname')
                          AND table_owner = upper('&towner')
                          AND index_name = upper('&iname')
                          AND index_owner = upper('&iowner')))
UNION
SELECT column_id,
      'SUM(NVL(vsize('||column_name||'),0)) + 1)'
  FROM dba_tab_columns 
  WHERE table_name = upper('&tname') AND owner = upper('&towner')
   AND column_name IN
                   (SELECT column_name FROM dba_ind_columns 
                     WHERE table_name = upper('&tname')
                       AND table_owner = upper('&towner')
                       AND index_name = upper('&iname')
                       AND index_owner = upper('&iowner'))
                       AND column_id = (SELECT MAX(column_id)
                     FROM dba_tab_columns
                     WHERE table_name = upper('&tname') 
                      AND owner = upper('&towner')
                      AND column_name IN
                      (SELECT column_name FROM dba_ind_columns 
                        WHERE table_name = upper('&tname')
                          AND table_owner = upper('&towner')  
                          AND index_name = upper('&iname')
                          AND index_owner = upper('&iowner')))
UNION 
SELECT 997,
       '/ NULLIF(COUNT(*),0) + 11 isize, '' bytes each.'''  from dual
UNION 
SELECT 999,  'FROM &towner..&tname.;'  FROM dual order by 1;
SPOOL OFF
SET TERMOUT ON FEEDBACK 15 PAGESIZE 20 SQLCASE MIXED 
SET NEWPAGE 1
START &cfile
CLEAR columns
UNDEF tname
UNDEF towner
UNDEF iname
UNDEF iowner
UNDEF cfile
