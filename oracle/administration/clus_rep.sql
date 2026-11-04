/*
===============================================================================
SCRIPT: clus_rep.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/CLUS_REP.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar clusters de tabelas, membros e colunas e encerrar cliente.

FUNCIONAMENTO DETALHADO
  Une DBA_CLUSTERS/CLU_COLUMNS por owner/nome, faz spool/PAUSE e EXIT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme LIMITAÇÕES; roles não
  bastam para compilar dependências de rotinas armazenadas.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_CLUSTERS, DBA_CLU_COLUMNS, SQL*Plus EXIT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  EXIT pode confirmar transação do chamador. Não se refere a RAC. SELECT exige catálogo; nomes longos podem ser truncados.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente sessão descartável sem transação pendente: revisar @clus_rep.sql.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner/cluster/tablespace/tabela e mapeamento das colunas; sessão finalizada.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados ou sessão descritos
  acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Owner incluído na junção para não cruzar clusters homônimos de schemas distintos; EXIT e crédito RevealNet preservados. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 041 — 04/11/2026
  Correções e melhorias: Corpo preservado; junção por owner continua correta.
  Limitações e pendências: EXIT pode confirmar transação do chamador; não é RAC. Formatos de nomes curtos podem truncar exibição e ordenação não fixa posição das colunas do cluster.
  Homologação necessária: Dois owners com cluster homônimo, cluster multi-coluna, spool e EXIT em sessão descartável.
  Parâmetros e execução: contratos acima e no corpo; só ambiente controlado.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e comparação estática; sem compilação/execução
  Oracle, Windows, alteração de privilégio ou gravação de arquivo no servidor.

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
rem
rem Name: clus_rep.sql
rem
rem FUNCTION: Generate a report on database clusters
rem         : showing cluster, tablespace, tables, and column data
rem MRA RevealNet 10/23/95
rem
column owner             format a10
column cluster_name      format a15 heading "Cluster"
column tablespace_name   format a20 heading "Tablespace"
column table_name        format a20 heading "Table"
column tab_column_name   format a20 heading "Table Column"
column clu_column_name   format a20 heading "Cluster Column"
set pages 56 lines 130 feedback off
ttitle "Cluster Report"
break on owner on tablespace_name on cluster_name on table_name
spool clus_rep.lst
select a.owner,tablespace_name,a.cluster_name,
table_name,tab_column_name,clu_column_name
from dba_clusters a,dba_clu_columns b
where
a.cluster_name=b.cluster_name and a.owner=b.owner
order by 1,2,3,4
/
spool off
pause Press enter to continue
ttitle off
clear columns
clear breaks
exit

