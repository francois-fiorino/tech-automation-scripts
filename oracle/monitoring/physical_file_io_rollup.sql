/*
===============================================================================
SCRIPT: physical_file_io_rollup.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / _i_o_scripts/physical_file_io_rollup.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar histórico recente de métricas de I/O por datafile.

FUNCIONAMENTO DETALHADO
  Une V_$FILEMETRIC_HISTORY a DBA_DATA_FILES por FILE_ID e apresenta intervalos, médias de tempo, operações e blocos físicos. Não aplica ROLLUP apesar do nome.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$FILEMETRIC_HISTORY, SYS.DBA_DATA_FILES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Oracle 10g+; histórico volátil, retenção limitada. Executar no container apropriado; não é junção global por CON_ID. Sem agregação adicional.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @physical_file_io_rollup.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Início/fim, FILE_ID/nome, tempos médios, operações e blocos do intervalo. Médias em centésimos de segundo por operação conforme Database Reference; confirmar na versão alvo.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  HH substituído por HH24 para evitar ambiguidade AM/PM; ordenação por A.BEGIN_TIME substitui texto DD-MON-YY, garantindo ordem cronológica. 
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


col file_id heading 'File|ID' format 9999
col file_name heading 'File|Name'
col begin_time heading 'Begin Time'
col end_time heading 'End Time'
col physical_block_reads heading 'Physical|Block|Reads'
col physical_block_writes heading 'Physical|Block|Writes'
col average_read_time heading 'Average|Read|Time'
col average_write_time heading 'Average_write_time'
col average_write_time heading 'Average|Write|Time'
col physical_reads heading 'Physical|Reads'
col physical_writes heading 'Physical|Writes'
set lines 200 pages 55
ttitle '10g File IO Statistics'
spool 10g_io
select
        to_char(begin_time,'dd-MON-yy hh24:mi') begin_time,
        to_char(end_time,'dd-MON-yy hh24:mi') end_time,
        a.file_id,
        file_name,
        average_read_time,
        average_write_time,
        physical_reads,
        physical_writes,
        physical_block_reads,
        physical_block_writes
from
        sys.v_$filemetric_history a,
        sys.dba_data_files b
where
        a.file_id = b.file_id
order by
        a.begin_time,a.file_id
/
spool off
ttitle off
set lines 80 pages 22
