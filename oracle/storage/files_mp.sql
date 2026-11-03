/*
===============================================================================
SCRIPT: files_mp.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/files_mp.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Contar arquivos e tamanho alocado por prefixo de caminho.

FUNCIONAMENTO DETALHADO
  Agrega DBA_DATA_FILES e DBA_TEMP_FILES por prefixo NUM_CHAR, combina com UNION ALL e soma arquivos/MiB por prefixo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_DATA_FILES, DBA_TEMP_FILES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não descobre mounts reais nem espaço livre do filesystem; prefixo pode juntar discos/ASM distintos. NUM_CHAR deve ser inteiro positivo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE num_char = 4
  @files_mp.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  MOUNT_POINT como prefixo textual, NUM_FILES e MEG em MiB atualmente alocados.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  UNION substituído por UNION ALL: subtotais idênticos de datafiles e tempfiles não devem ser eliminados antes da soma externa. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
Rem gives a files per mountpoint count
rem must supply cutoff for length of mountpoint string
rem example - /u03/oracle if /u03 is mountpoint, enter 4
rem MRA 
rem
col mount_point heading 'Mount|Point'
col num_files heading 'Number|of Files'
col meg heading 'Megabytes'
ttitle 'Files by Mount Point'
spool files_mp.lst
select mount_point,sum(num_files) num_files, sum(meg) meg from 
(
select substr(file_name,1,&&num_char) mount_point, count(*) num_files, sum(bytes/(1024*1024)) meg from dba_data_files
group by substr(file_name,1,&&num_char)
union all
select substr(file_name,1,&&num_char) mount_point, count(*) num_files, sum(bytes/(1024*1024)) meg from dba_temp_files
group by substr(file_name,1,&&num_char)
)
group by mount_point
order by mount_point
/
spool off
