/*
===============================================================================
SCRIPT: datafile.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/DATAFILE.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Inventariar localização e tamanho atual dos datafiles por tablespace.

FUNCIONAMENTO DETALHADO
  Consulta DBA_DATA_FILES, converte BYTES para MiB e configura quebras e subtotais por tablespace e total geral no cliente.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_DATA_FILES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não inclui tempfiles; tamanho atual não indica espaço livre ou capacidade de crescimento. Nomes longos podem ser truncados na apresentação histórica.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @datafile.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  TABLESPACE_NAME, FILE_NAME e MEG; totais de espaço atualmente alocado, não utilizado nem limite de autoextend.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada; wrappers e spool ajustados para execução independente. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
REM
REM     Name:      datafile.sql
REM     FUNCTION:  Document  file sizes and locations
REM     Use:       From SQLPLUS 
REM
clear computes
COLUMN FILE_NAME                FORMAT A46 Heading File
COLUMN TABLESPACE_NAME          FORMAT A16 HEADING Name
COLUMN MEG                      FORMAT 99,999,999.90
set pages 43 
ttitle 'DATABASE DATAFILES'
spool datafile.lst
BREAK ON TABLESPACE_NAME SKIP 1 ON REPORT
COMPUTE SUM OF MEG ON TABLESPACE_NAME
compute sum of meg on REPORT
set lines 90
SELECT
TABLESPACE_NAME, FILE_NAME, BYTES/1048576 MEG
FROM
DBA_DATA_FILES
ORDER BY
TABLESPACE_NAME
/

SPOOL OFF
clear columns
clear computes
pause Press enter to continue
