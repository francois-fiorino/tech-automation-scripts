/*
===============================================================================
SCRIPT: unexpired_size_undo_logs.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / misc_scripts/unexpired_size_undo_logs.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Estimar tamanho de blocos undo expired/unexpired nos intervalos históricos selecionados.

FUNCIONAMENTO DETALHADO
  Consulta DBA_HIST_UNDOSTAT no período literal de 01/09/2010 e multiplica blocos pelo DB_BLOCK_SIZE atual do mesmo DBID.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_UNDOSTAT, V$PARAMETER, V$DATABASE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não soma espaço total do undo nem mostra todas as categorias. Período fixo antigo normalmente não retorna dados. Validar contexto AWR/PDB; unidades históricas pressupõem bloco do banco correspondente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @unexpired_size_undo_logs.sql
  -- Editar os limites de data de 2010 antes de uso atual.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  TIME, Unexpired Size (MB) e Expired Size (MB), em MiB.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  8192 trocado por DB_BLOCK_SIZE; filtro DBID atual impede usar tamanho local em AWR de outro banco. Ordenação usa BEGIN_TIME real. 
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

set linesize 500
col time for a16 alias "Time"
select 
   to_char(begin_time,'DD/MM/YYYY HH24:MI') time,
   round(unexpiredblks*to_number(p.value)/1024/1024,2) "Unexpired Size (MB)",
   round(expiredblks*to_number(p.value)/1024/1024,2)   "Expired Size (MB)"
from 
   dba_hist_undostat h cross join v$parameter p
where 
   p.name='db_block_size'
and h.dbid=(select dbid from v$database)
and begin_time >= to_date('01/09/2010 22:25','DD/MM/YYYY HH24:MI')
and 
   end_time <= to_date('01/09/2010 23:45','DD/MM/YYYY HH24:MI')
order by h.begin_time;