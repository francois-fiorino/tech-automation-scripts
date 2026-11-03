/*
SCRIPT: staggered_sequence_trigger.sql
CATEGORIA: Oracle / RAC / Geração de chaves
ORIGEM: _rac_grid_scripts/staggered_sequence_trigger.sql; coleção 2015.
STATUS: PROPOSTA DE REVISÃO; NÃO EXECUTADO NEM HOMOLOGADO.

OBJETIVO E FINALIDADE
  Criar trigger INSERT_EMP_PK para atribuir EMP.EMP_ID antes de cada INSERT.

FUNCIONAMENTO DETALHADO
  BEFORE INSERT FOR EACH ROW lê INSTANCE_NUMBER em V$INSTANCE e NEXTVAL de
  EMP_ID_SEQ; calcula (INSTANCE_NUMBER-1)*100000+NEXTVAL e grava :NEW.EMP_ID.
  O script cria o trigger; não insere dados nem cria tabela ou sequência.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus/SQLcl; tabela EMP com EMP_ID e sequência EMP_ID_SEQ no schema
  pretendido. CREATE TRIGGER e grants diretos para objetos referenciados,
  especialmente SELECT em SYS.V_$INSTANCE (não apenas via role no trigger).
  Validar privilégios de tabela/sequence e capacidade numérica de EMP_ID.

OBJETOS, VIEWS E PACOTES
  EMP, EMP.EMP_ID, EMP_ID_SEQ, V$INSTANCE, DUAL e trigger INSERT_EMP_PK.

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Fórmula não garante unicidade global sem análise de faixas, progressão,
  cycling e configuração da sequência. Offset fixo 100000 pode colidir entre
  instâncias conforme valores históricos/novos. Não é solução geral de chave RAC.
  Também sobrescreve EMP_ID explicitamente informado no INSERT.
  CREATE TRIGGER falha se trigger com esse nome já existir; sem OR REPLACE.

EXEMPLOS DE REVISÃO
  Em schema descartável, inspecionar EMP, EMP_ID_SEQ e grants antes de compilar.
  Após criação intencional em laboratório: SHOW ERRORS TRIGGER insert_EMP_PK.
  Não executar em produção; validar unicidade entre instâncias e limites
  da sequência com dados representativos antes de aprovar este PR.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Cliente pode informar Trigger created ou erros de compilação. Conferir
  USER_ERRORS/USER_OBJECTS; compilação não demonstra ausência de colisões.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO: DDL persistente muda semântica de todos os INSERTs em EMP e implica
  commits de DDL. Trigger inválido pode bloquear inserts; chaves podem colidir.
  Uso de NEXTVAL consome valores mesmo se transação sofrer rollback.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  BOM normalizado e terminador inválido END;. corrigido para END; e /.
  Fórmula, nomes e atribuição integralmente preservados para revisão técnica.
  Projetar unicidade e implantação/rollback é pendência obrigatória do PR.

AVISO DE RESPONSABILIDADE
Os scripts são disponibilizados para fins técnicos, educacionais e administrativos.
Antes da utilização, analise integralmente o código, compreenda seu funcionamento
e realize testes em ambiente controlado, preferencialmente desenvolvimento ou
homologação. Conteúdo fornecido no estado em que se encontra (AS IS), sem garantias
de funcionamento, compatibilidade, desempenho ou adequação a ambientes específicos.
A utilização ocorre por conta e risco de quem executa. Os mantenedores não assumem
responsabilidade por danos, perdas de dados, indisponibilidade ou outros impactos
decorrentes do uso, nos limites permitidos pela legislação aplicável.
*/


-- staggered_sequence_trigger.sql

CREATE TRIGGER insert_EMP_PK
BEFORE insert ON EMP
FOR EACH ROW
DECLARE
INST_ID NUMBER;
SEQ_NUM NUMBER;
INST_SEQ_ID NUMBER;
BEGIN
select
    INSTANCE_NUMBER INTO INST_ID
  FROM
    V$INSTANCE;
  select
    EMP_ID_SEQ.NEXTVAL INTO SEQ_NUM
  FROM
    DUAL;
  INST_SEQ_ID:=(INST_ID-1)*100000 + SEQ_NUM;
  :NEW.EMP_ID:=INST_SEQ_ID;
END;
/
