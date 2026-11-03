/*
===============================================================================
SCRIPT: io_timing2.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / _i_o_scripts/io_timing2.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Comparar médias acumuladas de I/O de datafiles e tempfiles.

FUNCIONAMENTO DETALHADO
  Executa dois SELECTs de estatísticas e nomes de arquivos, combinados por UNION; divide tempos por GREATEST(contador,1) e ordena quinta coluna.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$FILESTAT, V$DATAFILE, V$TEMPSTAT, V$TEMPFILE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  GREATEST(contador,1) evita zero mas pode produzir razão sem operações; comportamento preservado. UNION remove linhas idênticas; não há coluna indicando tipo do arquivo. TIMED_STATISTICS influencia os tempos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @io_timing2.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Número/nome, contadores, READ_RAT e WRITE_RAT em centésimos de segundo por operação.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Cálculos, UNION e formatação histórica preservados. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col name format a58 heading 'Name'
col phywrts heading 'Phys. Writes'
col phyreads heading 'Phys. Reads'
col read_rat heading 'Avg. Read|Time'
col write_rat heading 'Avg. Write|Time'
set lines 132 pages 45
ttitle 'IO Timing Analysis'
spool io_timing2.lst
select  f.FILE# ,d.name,PHYRDS,PHYWRTS,READTIM/greatest(PHYRDS,1) read_rat,WRITETIM/greatest(PHYWRTS,1) write_rat
from v$filestat f, v$datafile d
where f.file#=d.file#
union
select  f.FILE# ,d.name,PHYRDS,PHYWRTS,READTIM/greatest(PHYRDS,1) read_rat,WRITETIM/greatest(PHYWRTS,1) write_rat
from v$tempstat f, v$tempfile d
where f.file#=d.file#
order by 5 desc
/
spool off
ttitle off
clear columns
set lines 80 pages 22
