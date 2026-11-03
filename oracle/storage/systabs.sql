/*
===============================================================================
SCRIPT: systabs.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / misc_scripts/SYSTABS.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar tabelas com owner diferente de SYS no tablespace SYSTEM.

FUNCIONAMENTO DETALHADO
  Filtra DBA_TABLES por TABLESPACE_NAME=SYSTEM e OWNER<>SYS.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Pode incluir objetos legítimos de componentes Oracle; não mover automaticamente. Partições e LOBs exigem views próprias. Não é inventário de todo espaço SYSTEM.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @systabs.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, tabela e tablespace.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta e crédito M. Ault preservados. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem systabs.sql
rem report on non-sys owned tables in SYSTEM tablespace
rem M. Ault 6/5/96 TRECOM
rem
column owner format a15
column table_name format a30
column tablespace_name format a10
set pages 48 lines 80 feedback off verify off
ttitle 'Non-SYS Owned Tables in SYSTEM'
spool systabs.lst
select owner,table_name,tablespace_name
from dba_tables 
where tablespace_name='SYSTEM' and owner !='SYS'
/
spool off
set pages 22 lines 80 feedback on verify on
clear columns
ttitle off
