/*
===============================================================================
SCRIPT: explain1.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / _index_scripts/explain1.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Explicar SQL em buffer e calcular heurística de custo por operação.

FUNCIONAMENTO DETALHADO
  SAVE/GET AFIEDT.BUF, TRUNCATE PLAN_TABLE, insere EXPLAIN PLAN FOR, RUN; dois loops atualizam MYCOST/MYSUBCOST e COMMIT; árvore e restauração do buffer.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas conforme limitações individuais.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  PLAN_TABLE com MYCOST/MYSUBCOST, SQL*Plus buffer/SAVE/GET/RUN

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  TRUNCATE/COMMIT e arquivo AFIEDT.BUF REPLACE afetam estado compartilhado e sessão. Custo CBO não é necessariamente aditivo e percentuais são heurísticos. Precisa das colunas customizadas e PLAN_TABLE exclusiva. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Somente sessão descartável, SQL controlado e PLAN_TABLE exclusiva de teste.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Plano estimado com custos/subcustos e porcentagens; arquivo AFIEDT.BUF sobrescrito.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos de criação, staging, autenticação, sessão
  ou código gerado descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 038 (2026-11-04): Algoritmo e créditos Christian Adams preservados; não promovida subtração de custos a métrica de tempo. Casos de homologação: Plano com múltiplos filhos/custoNULL/zero; custo não aditivo; arquivo buffer existente; sessão paralela; SQL de entrada não confiável proibido; grants e colunas customizadas. Comentários/créditos históricos preservados. Não aprovado para implantação.

AVISO DE RESPONSABILIDADE
AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de
qualquer utilização em produção. Sua execução é de responsabilidade do
profissional responsável pelo ambiente. Os mantenedores deste repositório não
se responsabilizam por indisponibilidade, perda de dados, alterações indevidas
ou outros impactos decorrentes de sua utilização.

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
SET ECHO OFF
SET FEEDBACK OFF
SET TIMING ON
-- *****************************************************************************
-- Script for analyzing the access path of a SQL-statement
-- Assuming the statement to be analyzed is contained
-- in the SQL-buffer of SQL*Plus and this SQL is executed using
-- the @ command in SQL*Plus. (i.e.. >SQL @<filename>
--------------------------------------------------------------------------------
-- FYI:  You must run UTLXPLAN.SQL or some variation of it
-- before using this SQL.  This SQL is designed
-- to be used with the original UTLXPLAN.SQL.  If a modified
-- version of UTLXPLAN.SQL is used, this file may need to be
-- modified as well.  You should also read about EXPLAIN
-- PLAN in the Oracle Documentation so that you can use this
-- information for your benefit.  Using EXPLAIN PLAN does not
-- execute the SQL statement being explained.  It only evaluates
-- the execution plan of the SQL statement.
--------------------------------------------------------------------------------
-- WARNING: If several users run this script simultaneously,
-- they might destroy each other's contents of PLAN_TABLE.
-- Therefore: Either create a separate copy of PLAN_TABLE,
-- or modify the script to include STATEMENT_ID
-- *****************************************************************************
-- Ehancements by Christian Adams 5/31 :
-- For each operation in the plan, the value of COST in PLAN_TABLE is the sum 
-- of 
--      1. the cost of the operation in question
--      2. the total cost of the child operations associated with it
-- 
-- This script will separate the cost for the operation from the total cost of 
-- its children.  The cost of the operations is displayed as "Cost", and the 
-- total cost of the children is displayed as "Subcost".  Furthermore, the 
-- cost/subcost is followed by its percentage of the total cost of the query in 
-- parentheses.
--------------------------------------------------------------------------------
-- MODIFICATIONS TO PLAN_TABLE:
-- For this script to work, you must add the following columns to your 
-- PLAN_TABLE: 
--
--      ALTER TABLE plan_table ADD mycost NUMBER NULL;
--      ALTER TABLE plan_table ADD mysubcost NUMBER NULL;
-- *****************************************************************************
-- First save the statement to be analyzed
SAVE "AFIEDT.BUF" REPLACE
-- Then clear PLAN_TABLE. Be aware that TRUNCATE implies COMMIT
TRUNCATE TABLE PLAN_TABLE;
-- Retrieve the statement to be analyzed
GET "AFIEDT.BUF" NOLIST
-- Put "EXPLAIN PLAN FOR" in front of statement
0 EXPLAIN PLAN FOR
-- Run the EXPLAIN
RUN

-- Get the total cost of the query from PLAN_TABLE.
COLUMN totcost NEW_VALUE totalcost NOPRINT
SELECT DECODE(cost,0,1,NULL,1,cost) totcost
FROM plan_table
WHERE id = 0
/

-- Separate the cost of each operation from the total cost of its children.
DECLARE
  v_subcost NUMBER;
  CURSOR cur_plan
  IS
  SELECT id, cost
  FROM plan_table FOR UPDATE
  ORDER BY id DESC;
BEGIN
  FOR c0 in cur_plan
  LOOP
    SELECT SUM(cost) INTO v_subcost
    FROM plan_table
    WHERE parent_id = c0.id;
    IF v_subcost IS NOT NULL THEN
      UPDATE plan_table
      SET mysubcost = v_subcost
      WHERE id=c0.id;
      IF c0.cost IS NULL THEN
        UPDATE plan_table
        SET cost = v_subcost
        WHERE CURRENT OF cur_plan;
      END IF;
    END IF;
  END LOOP;
  FOR c1 in cur_plan
  LOOP
    SELECT SUM(cost) INTO v_subcost
    FROM plan_table
    WHERE parent_id = c1.id;
    IF v_subcost IS NOT NULL THEN
      UPDATE plan_table
      SET mycost = cost - v_subcost
      WHERE id=c1.id;
    END IF;
  END LOOP;
  UPDATE plan_table
  SET mycost = cost
  WHERE mycost IS NULL;
  UPDATE plan_table
  SET mysubcost = cost
  WHERE mysubcost IS NULL;
  COMMIT;
END;
/

-- Display the execution plan.
BREAK ON access_path SKIP 1
SELECT LPAD(' ',4*(LEVEL-1))||OPERATION||' '||OPTIONS||' '
       ||OBJECT_NAME||' '||OBJECT_TYPE||' '||OPTIMIZER
       ||DECODE(ID,0,'  TotalCost='||&totalcost)
--       ||DECODE(COST,NULL,'','  OCost='||COST||' ('||ROUND(cost*100/&totalcost,2)||'%)')
       ||DECODE(mycost,NULL,'','  Cost='||mycost||' ('||ROUND(mycost*100/&totalcost,2)||'%)')
       ||DECODE(mysubcost,NULL,'','  Subcost='||mysubcost||' ('||ROUND(mysubcost*100/&totalcost,2)||'%)')
       ||DECODE(BYTES,NULL,'','  Bytes='||BYTES)
       ||DECODE(CARDINALITY,NULL,'','  Card='||CARDINALITY)
                 ACCESS_PATH
FROM   PLAN_TABLE
START WITH ID = 0 CONNECT BY PRIOR ID = PARENT_ID;
-- Restore original statement
GET "AFIEDT.BUF" NOLIST
SET FEEDBACK 1
SET ECHO ON
SET TIMING OFF
