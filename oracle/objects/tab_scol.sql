/*
===============================================================================
SCRIPT: tab_scol.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/TAB_SCOL.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar view de estatísticas/atributos de tabelas com contagem de colunas.

FUNCIONAMENTO DETALHADO
  Une DBA_TABLES a TAB_COLUMNS por owner/nome e agrupa todos os atributos projetados, contando colunas visíveis.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme LIMITAÇÕES; roles não
  bastam para compilar dependências de rotinas armazenadas.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES, DBA_TAB_COLUMNS; view TAB_STAT_COL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE VIEW e SELECT direto. Conta colunas expostas por TAB_COLUMNS, não todas internas. Campos de storage legados podem não ser relevantes em ASSM; estatísticas podem ser NULL. CREATE simples falha se view existe.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @tab_scol.sql.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  View TAB_STAT_COL com atributos e NO_OF_COLS.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados ou sessão descritos
  acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Definição integral preservada; sem trocar silenciosamente por OR REPLACE. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 039 — 04/11/2026
  Correções e melhorias: Colunas projetadas/agrupadas qualificadas com alias A para evitar ambiguidades com DBA_TAB_COLUMNS.
  Limitações e pendências: INNER JOIN omite tabelas sem colunas visíveis; estatísticas podem ser NULL/desatualizadas. CREATE simples preservado; grant direto obrigatório.
  Homologação necessária: Compilar view em laboratório; comparar duas tabelas homônimas em owners distintos, estatísticas NULL e contagem de colunas.
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
create view tab_stat_col as
select
a.OWNER,a.TABLE_NAME,a.TABLESPACE_NAME,
a.CLUSTER_NAME,a.PCT_FREE,a.PCT_USED,a.INI_TRANS,a.MAX_TRANS,      
a.INITIAL_EXTENT,a.NEXT_EXTENT,    
a.MIN_EXTENTS,a.MAX_EXTENTS,a.PCT_INCREASE,a.FREELISTS,      
a.FREELIST_GROUPS,a.BACKED_UP,a.NUM_ROWS,a.BLOCKS,         
a.EMPTY_BLOCKS,a.AVG_SPACE,a.CHAIN_CNT,      
a.AVG_ROW_LEN,a.DEGREE,a.INSTANCES,a.CACHE,a.TABLE_LOCK,     
 count(b.table_name) no_of_cols
from
 dba_tables a, dba_tab_columns b
where
 a. owner = b.owner and
 a.table_name=b.table_name
group by
a.OWNER,a.TABLE_NAME,a.TABLESPACE_NAME,
a.CLUSTER_NAME,a.PCT_FREE,a.PCT_USED,a.INI_TRANS,a.MAX_TRANS,      
a.INITIAL_EXTENT,a.NEXT_EXTENT,    
a.MIN_EXTENTS,a.MAX_EXTENTS,a.PCT_INCREASE,a.FREELISTS,      
a.FREELIST_GROUPS,a.BACKED_UP,a.NUM_ROWS,a.BLOCKS,         
a.EMPTY_BLOCKS,a.AVG_SPACE,a.CHAIN_CNT,      
a.AVG_ROW_LEN,a.DEGREE,a.INSTANCES,a.CACHE,a.TABLE_LOCK  
/
