/*
===============================================================================
SCRIPT: sqlmem.sql
CATEGORIA: Oracle / performance/sql
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/SQLMEM.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar memória e atividade de SQL por usuário de parse.

FUNCIONAMENTO DETALHADO
  Une SQLAREA a DBA_USERS, filtra fragmento de username e ordena por EXECUTIONS decrescente.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$SQLAREA, DBA_USERS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não mede memória única de sessão; categorias de memória não devem ser somadas sem validar semântica. Texto pode conter dados sensíveis.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE user_name = HR
  @sqlmem.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Usuário, prefixo SQL, execuções/loads/usuários executando e bytes shared/persistent.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  COMPUTE de RUNTIME_MEM sem coluna correspondente removido; nenhuma coluna SQL retirada. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Título convertido em TTITLE local.
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
rem
rem FUNCTION: Generate a report of SQL Area Memory Usage
rem           showing SQL Text and memory catagories
rem
rem sqlmem.sql 
rem
column sql_text      format a60   heading Text word_wrapped
column sharable_mem               heading Shared|Bytes
column persistent_mem             heading Persistent|Bytes
column loads                      heading Loads
column users         format a15   heading "User"
column executions		  heading "Executions"
column users_executing		  heading "Used By"
ttitle "Users SQL Area Memory Use"
spool sqlmem.lst
set long 2000 pages 59 lines 132
break on users
compute sum of sharable_mem on users
compute sum of persistent_mem on users
-- RUNTIME_MEM não integra a projeção deste relatório.
select username users, sql_text, Executions, loads, users_executing, 
sharable_mem, persistent_mem 
from sys.v_$sqlarea a, dba_users b
where a.parsing_user_id = b.user_id
and b.username like upper('%&user_name%')
order by 3 desc,1;
spool off
pause Press enter to continue
clear columns
clear computes
clear breaks
set pages 22 lines 80
ttitle off
