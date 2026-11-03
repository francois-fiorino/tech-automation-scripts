/*
===============================================================================
SCRIPT: rbs_set.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/rbs_set.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Encontrar referências legadas a nomes de rollback segments no código PL/SQL válido.

FUNCIONAMENTO DETALHADO
  Une DBA_SOURCE a DBA_OBJECTS por OWNER, NAME e TYPE; procura texto RBS_1GB ou RBS1, ignora linhas iniciadas por -- e retorna somente objetos VALID.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_SOURCE, DBA_OBJECTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Busca case-sensitive por nomes fixos; pode retornar strings/comentários de bloco e não cobre nomes dinâmicos. Não prova execução de SET TRANSACTION USE ROLLBACK SEGMENT.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @rbs_set.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OWNER, NAME, TYPE e linha TEXT com correspondência textual.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  UNDEF COLUMNS substituído por CLEAR COLUMNS: restaura formatos em vez de remover variável de substituição inexistente. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col owner format a20
col name format a30
col type format a10
col text format a45
set lines 132 pages 47 sqlbl on
ttitle 'Objects Using SET RBS Commands'
spool rbs_set.lst
select a.owner,a.name,a.type,trim(a.text) text 
from dba_source a, dba_objects b
where (a.text like '%RBS_1GB%' or text like '%RBS1%') 
      and trim(a.text) not like '--%'
      and a.name=b.object_name
      and a.owner=b.owner
      and a.type=b.object_type
      and b.status='VALID'
/
spool off
set lines 80 pages 22
clear columns
