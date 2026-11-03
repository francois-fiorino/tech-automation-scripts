/*
===============================================================================
SCRIPT: io_timing.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / _i_o_scripts/io_timing.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir médias acumuladas de tempo por leitura e escrita de datafiles.

FUNCIONAMENTO DETALHADO
  Une V$FILESTAT e V$DATAFILE por FILE#; divide READTIM por PHYRDS e WRITETIM por PHYWRTS, ordenando pela primeira razão.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$FILESTAT, V$DATAFILE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  TIMED_STATISTICS precisa fornecer tempos válidos. Estatísticas acumuladas e ausência de operações produzem NULL; NULL no sort DESC pode aparecer primeiro.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @io_timing.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  FILE#, nome, contadores de leituras/escritas e tempos médios em centésimos de segundo por operação.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF aplicado às duas razões e à expressão de ordenação. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col name format a58
set lines 132 pages 45
ttitle 'IO Timing Analysis'
spool io_timing.lst
select  f.FILE# ,d.name,PHYRDS,PHYWRTS,READTIM/nullif(PHYRDS,0),WRITETIM/nullif(PHYWRTS,0)
from v$filestat f, v$datafile d
where f.file#=d.file#
order by readtim/nullif(PHYRDS,0) desc
/

spool off

