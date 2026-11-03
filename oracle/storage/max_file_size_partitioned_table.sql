/*
===============================================================================
SCRIPT: max_file_size_partitioned_table.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/max_file_size_partitioned_table.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Encontrar maior datafile dos tablespaces usados por partições de tabelas e índices.

FUNCIONAMENTO DETALHADO
  Une partições a DBA_DATA_FILES pelo nome do tablespace e calcula MAX(BYTES) em MiB por nome de tabela ou índice, combinando resultados por UNION.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_DATA_FILES, DBA_TAB_PARTITIONS, DBA_IND_PARTITIONS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não mede tamanho ocupado pela tabela, partição ou índice. Agrupa só por nome e pode juntar schemas; UNION pode colapsar nomes iguais de tabela/índice. Não inclui subpartições de forma completa.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @max_file_size_partitioned_table.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Nome da tabela/índice e tamanho do maior datafile dentre os tablespaces associados.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Acrescentado GROUP BY P2.INDEX_NAME ausente no segundo SELECT para corrigir erro de agregação; demais critérios históricos preservados. 
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

select 
   p1.table_name, 
   max(d1.bytes)/1024/1024
from 
   dba_data_files     d1,
   dba_tab_partitions p1
where 
   p1.tablespace_name = d1.tablespace_name group by 
   p1.table_name
union
select 
   p2.index_name, 
   max(d1.bytes)/1024/1024
from 
   dba_data_files     d1,
   dba_ind_partitions p2
where 
   p2.tablespace_name = d1.tablespace_name
group by p2.index_name;