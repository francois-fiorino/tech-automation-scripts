/*
===============================================================================
SCRIPT: file_archive_status.sql
CATEGORIA: Oracle / backup-recovery
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/file_archive_status.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar modo de backup de datafiles, SCN e hora de início.

FUNCIONAMENTO DETALHADO
  Une V_$DATAFILE e V_$BACKUP por FILE#; mostra estado do arquivo, interpretação de STATUS do backup, ENABLED, BYTES, CHANGE# e TIME.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$DATAFILE, SYS.V_$BACKUP

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Apesar de archive no nome, não verifica archivelogs, sucesso de RMAN nem validade de backup. ACTIVE indica modo de backup no controlfile; outros estados não devem ser ocultados.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @file_archive_status.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Nome, status, ARC (Backup/Normal ou status original), ENABLED, bytes, SCN e hora de início.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  DECODE corrigido de Active para ACTIVE; NOT ACTIVE vira Normal e estados diferentes são exibidos sem rotulá-los falsamente como normais. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Wrapper externo de título substituído por TTITLE local.
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
rem name: backup.sql
-- comment: Show database datafile Archive status
rem
column name format a43
column arc heading 'Backup Status'
set lines 132 pages 59 feedback off
ttitle "Database File Backup Status"
spool file_archive_status.lst
select name, a.status,decode(b.status,'ACTIVE','Backup','NOT ACTIVE','Normal',nvl(b.status,'Unknown')) arc, enabled, bytes, change#,time Archive from
sys.v_$datafile a, sys.v_$backup b where
a.file#=b.file#;
spool off
clear columns
ttitle off
pause press enter to continue


