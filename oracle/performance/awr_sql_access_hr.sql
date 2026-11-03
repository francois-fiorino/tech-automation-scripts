/*
===============================================================================
SCRIPT: awr_sql_access_hr.sql
CATEGORIA: Oracle / Performance
ORIGEM: Coleção Oracle 2015

OBJETIVO E FUNCIONAMENTO
  Lista cursores em V_$SQL cujo HASH_VALUE aparece em planos em cache com JOIN CARTESIAN. Apesar do nome, não apresenta agregação por hora nem consulta AWR.

PRÉ-REQUISITOS
  Acesso de leitura a SYS.V_$SQL, SYS.V_$SQL_PLAN.

EXECUÇÃO
  SQL> @awr_sql_access_hr.sql
  Executar somente após revisão integral e teste em ambiente controlado.

SAÍDA ESPERADA
  Todas as colunas de V_$SQL, ordenadas por HASH_VALUE.

RISCOS E LIMITAÇÕES
  Consulta somente leitura; HASH_VALUE não identifica unicamente child cursors e pode gerar falsos vínculos.
  Compatibilidade não homologada; análise estática, sem execução em banco.

AVISO DE RESPONSABILIDADE
  Fornecido AS IS, sem garantias. Uso por conta e risco do executor.
  Os mantenedores não assumem responsabilidade por danos ou perdas
  decorrentes do uso, nos limites permitidos pela legislação aplicável.

PRESERVAÇÃO
  SQL original reproduzido abaixo sem alterações funcionais.
===============================================================================
*/

/*  */
select * 
from 
   sys.v_$sql 
where 
   hash_value in 
      (select hash_value 
       from 
          sys.v_$sql_plan 
       where 
          options = 'CARTESIAN' 
          and
          operation LIKE '%JOIN%' ) 
order by hash_value; 
