/*
===============================================================================
SCRIPT: sql_garbage.sql
CATEGORIA: Oracle / performance/sql
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/sql_garbage.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar heurística de memória SQL com view customizada.

FUNCIONAMENTO DETALHADO
  Autojoin SQL_GARBAGE por USERS com um ramo GARBAGE e outro GOOD; inclui separador e total.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SQL_GARBAGE (customizada), DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Definição proposta de SQL_GARBAGE está no PR administrativo, não é instalada por este relatório. Usuários sem ambos os grupos são omitidos. EXECUTIONS não comprova qualidade/compartilhamento; possível sobreposição de categorias de memória.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @sql_garbage.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Usuário, bytes de dois grupos e percentual GOOD sobre a soma.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Dois divisores protegidos com NULLIF; ramos e colunas preservados. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
column garbage format a14 heading 'Non-Shared SQL'
column good format a14 heading 'Shared SQL'
column good_percent format a14 heading 'Percent Shared'
column users format a14 heading users
column nopr noprint
set feedback off 
ttitle 'Shared Pool Utilization'
spool sql_garbage.lst
select 1 nopr,
a.users users, 
to_char(a.garbage,'9,999,999,999') garbage,
to_char(b.good,'9,999,999,999') good,
to_char((b.good/nullif(b.good+a.garbage,0))*100,'9,999,999.999') good_percent
from sql_garbage a, sql_garbage b
where a.users=b.users
and a.garbage is not null and b.good is not null
union
select 2 nopr,
'-------------' users,'--------------' garbage,'--------------' good,
'--------------' good_percent from dual
union
select 3 nopr,
to_char(count(a.users)) users,
to_char(sum(a.garbage),'9,999,999,999') garbage,
to_char(sum(b.good),'9,999,999,999') good,
to_char(((sum(b.good)/nullif(sum(b.good)+sum(a.garbage),0))*100),'9,999,999.999') good_percent
from sql_garbage a, sql_garbage b
where a.users=b.users
and a.garbage is not null and b.good is not null
order by 1,3 desc
/
spool off
