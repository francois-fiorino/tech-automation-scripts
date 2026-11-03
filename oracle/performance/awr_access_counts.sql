/*
===============================================================================
SCRIPT: awr_access_counts.sql
CATEGORIA: Oracle / Performance / SQL Plan
ORIGEM: Coleção histórica Oracle (2015)

OBJETIVO
  Identificar planos de SQL em cache que contenham operações de JOIN CARTESIAN.

FUNCIONAMENTO
  Consulta SYS.V_$SQL_PLAN e filtra linhas com OPTIONS = 'CARTESIAN'
  e OPERATION contendo 'JOIN'. Calcula:
  - CARTEISAN_STATEMENTS: quantidade de HASH_VALUE distintos encontrados.
  - TOTAL_CARTESIAN_JOINS: quantidade de linhas de plano que atendem ao filtro.

PRÉ-REQUISITOS
  Permissão SELECT sobre SYS.V_$SQL_PLAN (direta ou por privilégio
  apropriado), além de uma sessão SQL*Plus ou SQLcl.

EXECUÇÃO
  SQL> @awr_access_counts.sql

INTERPRETAÇÃO E LIMITAÇÕES
  Os resultados são contagens de linhas de plano em cache; NÃO representam
  execuções reais nem garantem unicidade por SQL_ID/child cursor.
  O nome original contém 'awr', mas a consulta NÃO acessa DBA_HIST_*.
  O alias CARTEISAN_STATEMENTS foi mantido conforme o código original.

RISCO OPERACIONAL
  Consulta somente leitura; ainda assim, avaliar custo no ambiente-alvo.
  Não foi validado em banco Oracle nem homologado para versões específicas.

AVISO DE RESPONSABILIDADE
  Leia o código integralmente e teste em ambiente controlado antes de usar.
  Fornecido AS IS, sem garantias. Uso por conta e risco do executor; os
  mantenedores não se responsabilizam por danos decorrentes do uso, nos
  limites permitidos pela legislação aplicável.

PRESERVAÇÃO
  O SQL original abaixo foi preservado sem modificações funcionais.
===============================================================================
*/

/*  */
select 
   count(distinct hash_value) carteisan_statements, 
   count(*)                   total_cartesian_joins 
from  
   sys.v_$sql_plan 
where 
   options = 'CARTESIAN' 
and   
   operation like '%JOIN%' 
