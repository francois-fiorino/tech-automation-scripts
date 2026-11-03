/*
===============================================================================
SCRIPT: gen_keep.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/gen_keep.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar comandos de pinning de objetos de library cache com uso recorrente.

FUNCIONAMENTO DETALHADO
  Consulta V$DB_OBJECT_CACHE, exclui tipos definidos no código, exige EXECUTIONS>LOADS, EXECUTIONS>1 e KEPT=NO; imprime EXECUTE DBMS_SHARED_POOL.KEEP com flag por tipo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$DB_OBJECT_CACHE; DBMS_SHARED_POOL apenas no texto gerado

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DECODE mapeia PACKAGE/PROCEDURE/FUNCTION=P, SEQUENCE=Q, TRIGGER=R; outros tipos não excluídos geram flag vazia/inválida. Identificadores concatenados sem quoting exigem revisão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @gen_keep.sql
  -- Revise keep_them.sql manualmente; não o execute automaticamente.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Arquivo keep_them.sql com comandos EXECUTE para objetos selecionados; o gerador não aplica KEEP.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Gerador original preservado; falhas de mapeamento e risco do código gerado sinalizados para homologação. 
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
set lines 132 feedback off verify off
set pages 0
spool keep_them.sql
select  'execute dbms_shared_pool.keep('||chr(39)||OWNER||'.'||name||chr(39)||','||
         chr(39)||decode(type,'PACKAGE','P','PROCEDURE','P','FUNCTION','P','SEQUENCE','Q',
                              'TRIGGER','R')||chr(39)||')'
from
 v$db_object_cache
where
 type not in ('NOT LOADED','NON-EXISTENT','VIEW','TABLE','INVALID TYPE','CURSOR','PACKAGE BODY')
 and executions>loads and executions>1 and kept='NO'
order by owner,namespace,type,executions desc
/
spool off
