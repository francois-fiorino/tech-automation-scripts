/*
===============================================================================
SCRIPT: count_blocks.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/count_blocks.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar e executar INSERTs de contagem de blocos estimada para tabelas de schemas selecionados.

FUNCIONAMENTO DETALHADO
  Spool COUNT_B_TEMP.SQL contém INSERT INTO TEMP_SIZE_TABLE SELECT nome e COUNT DISTINCT prefixo de ROWID; START executa arquivo gerado.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/alteração/execução e SELECT DIRETO conforme LIMITAÇÕES.
  Grants por role podem não valer para views/procedimentos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_SEGMENTS, DBMS_ROWID, tabelas selecionadas, TEMP_SIZE_TABLE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Scans completos potencialmente muito caros. Prefixo de ROWID restrito pode omitir identificação do arquivo e subcontar blocos. Nomes não escapados, modelo de TEMP_SIZE_TABLE desconhecido e DML real automático.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Não executar em produção; laboratório com cópia dos dados e staging validado.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Linhas inseridas na tabela customizada; arquivo SQL gerado no cliente.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PROPOSTA DE REVISÃO: o código pode modificar objetos, dados, jobs,
  arquivos ou sessão, conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Algoritmo integral mantido em revisão; não removida execução automática para fingir equivalência funcional. 
  Revisão estática somente; implantação depende de testes e aprovação do PR.
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
spool count_b_temp.sql
define qt=chr(39);
define cr=chr(10);
set heading off lines 200 pages 0
select 'INSERT INTO temp_size_table'||&&cr||
       'SELECT '||&&qt||segment_name||&&qt||&&cr||
       ',COUNT( DISTINCT( SUBSTR( dbms_rowid.rowid_to_restricted(ROWID,1),1,8))) blocks'||&&cr||
       'FROM '||owner||'.'||segment_name||';'
  FROM dba_segments
 WHERE segment_type ='TABLE' AND owner not in ('SYS','SYSTEM','MDSYS','CTXSYS','OUTLN','Burleson Consulting')
/
spool off
start count_b_temp
