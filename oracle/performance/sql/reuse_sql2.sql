/*
===============================================================================
SCRIPT: reuse_sql2.sql
CATEGORIA: Oracle / performance/sql
ORIGEM: Oracle Script Collection 2015 / misc_scripts/reuse_sql2.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Comparar contagem e hashes distintos de SQLAREA por usuário de parse.

FUNCIONAMENTO DETALHADO
  Une SQLAREA a DBA_USERS, conta hashes e repetições e calcula hashes distintos/total em porcentagem.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SQLAREA, DBA_USERS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Hash pode colidir; razão não é cache hit nem medida suficiente de reutilização. SQLAREA já agrega cursores; não analisa child cursors. Grupo existente tem COUNT(hash)>0 somente se hash não nulo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @reuse_sql2.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Usuário, total de hash values, diferença para distintos e razão em percentual.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF protege contagem zero; relatório histórico mantido. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem: Shows by user who has possible
rem: SQL reuse problems
column total_hash heading 'Total Hash|Values'
column same_hash heading 'SQL With|Same Hash'
column u_hash_ratio format 999.999 heading 'SQL Sharing|Hash'
ttitle 'Shared Hash Value Report'
spool reuse_sql2.lst
break on report
compute sum of total_hash on report 
compute sum of same_hash on report
select 
	a.username,
	count(b.hash_value) total_hash, 
	count(b.hash_value)-count(unique(b.hash_value)) same_hash,
	(count(unique(b.hash_value))/nullif(count(b.hash_value),0))*100 u_hash_ratio
from 
	dba_users a, 
	v$sqlarea b
where 
	a.user_id=b.parsing_user_id
group by 
	a.username
order by
      total_hash desc;
spool off
clear computes
