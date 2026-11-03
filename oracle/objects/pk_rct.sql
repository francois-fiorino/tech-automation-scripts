/*
===============================================================================
SCRIPT: pk_rct.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/pk_rct.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Preservar DDL gerada de remoção/recriação de 150 chaves de aplicação.

FUNCIONAMENTO DETALHADO
  450 comandos: 150 DROP CONSTRAINT, 150 DROP INDEX e 150 ADD PRIMARY KEY/UNIQUE USING INDEX com storage HMINDEX.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas/SO conforme limitações; ler todos
  os nomes e caminhos antes de qualquer teste em ambiente descartável.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  150 tabelas/constraints/índices literais no corpo, tablespace HMINDEX

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Pode quebrar FKs/planos/indisponibilizar dados; DROP INDEX pode falhar após DROP CONSTRAINT que já o removeu. Nomes/storage/quoting/estado são específicos do ambiente histórico e não exportam features atuais. Lista integral foi conferida por padrões de todas as 450 instruções.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente revisão em clone de aplicação; não executar em produção.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Constraints e índices removidos/recriados com confirmações DDL parciais.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cópia/restauração, DDL, estatísticas ou DML massivo
  conforme acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código integral preservado sem executar, resumir ou remover drops; referências/números não reescritos sem catálogo e testes. 
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
alter table ACCOUNT_EXEC
drop constraint ACCTEXEC_PK;
drop index ACCTEXEC_PK;
alter table ACCOUNT_EXEC add constraint ACCTEXEC_PK
Primary Key( ACCOUNT_EXEC_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table ACCOUNT_EXEC
drop constraint ACCTEXEC_UK;
drop index ACCTEXEC_UK;
alter table ACCOUNT_EXEC add constraint ACCTEXEC_UK
Unique( BUSINESS_SEGMENT_ID, ACCOUNT_EXEC_CODE )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table ASSET_LEVEL
drop constraint ASSET_LVL_UK;
drop index ASSET_LVL_UK;
alter table ASSET_LEVEL add constraint ASSET_LVL_UK
Unique( BUSINESS_SEGMENT_ID, ASSET_LEVEL_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table ASSET_LEVEL
drop constraint ASSETLVL_PK;
drop index ASSETLVL_PK;
alter table ASSET_LEVEL add constraint ASSETLVL_PK
Primary Key( ASSET_LEVEL_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table BRAND
drop constraint BRAND_UK;
drop index BRAND_UK;
alter table BRAND add constraint BRAND_UK
Unique( BUSINESS_SEGMENT_ID, BRAND_DESCRIPTION )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table BRAND
drop constraint BRAND_PK;
drop index BRAND_PK;
alter table BRAND add constraint BRAND_PK
Primary Key( BRAND_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table BUSINESS_CATEGORY
drop constraint BCAT_UK;
drop index BCAT_UK;
alter table BUSINESS_CATEGORY add constraint BCAT_UK
Unique( BUSINESS_SEGMENT_ID, BUSINESS_CATEGORY_DESCRIPTION )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table BUSINESS_CATEGORY
drop constraint BCAT_PK;
drop index BCAT_PK;
alter table BUSINESS_CATEGORY add constraint BCAT_PK
Primary Key( BUSINESS_CATEGORY_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table BUSINESS_LEVEL
drop constraint BUSLVL_PK;
drop index BUSLVL_PK;
alter table BUSINESS_LEVEL add constraint BUSLVL_PK
Primary Key( BUSINESS_LEVEL_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table BUSINESS_LEVEL
drop constraint BUSLVL_UK;
drop index BUSLVL_UK;
alter table BUSINESS_LEVEL add constraint BUSLVL_UK
Unique( BUSINESS_SEGMENT_ID, BUSINESS_LEVEL_DESCRIPTION )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table BUSINESS_SEGMENT
drop constraint BS_PK;
drop index BS_PK;
alter table BUSINESS_SEGMENT add constraint BS_PK
Primary Key( BUSINESS_SEGMENT_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table BUSINESS_SEGMENT
drop constraint BS_UK;
drop index BS_UK;
alter table BUSINESS_SEGMENT add constraint BS_UK
Unique( BUSINESS_SEGMENT_DESCRIPTION )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table BUYING_GROUP
drop constraint BYGRP_PK;
drop index BYGRP_PK;
alter table BUYING_GROUP add constraint BYGRP_PK
Primary Key( BUYING_GROUP_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table BUYING_GROUP
drop constraint BYGRP_UK;
drop index BYGRP_UK;
alter table BUYING_GROUP add constraint BYGRP_UK
Unique( BUSINESS_SEGMENT_ID, BUYING_GROUP_DESCRIPTION )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table BUYING_GROUP_MEMBER
drop constraint BUYING_GRPMEM_UK;
drop index BUYING_GRPMEM_UK;
alter table BUYING_GROUP_MEMBER add constraint BUYING_GRPMEM_UK
Unique( BG_MEMBER_DESCRIPTION, BUSINESS_SEGMENT_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table BUYING_GROUP_MEMBER
drop constraint BYGRPMEM_PK;
drop index BYGRPMEM_PK;
alter table BUYING_GROUP_MEMBER add constraint BYGRPMEM_PK
Primary Key( BG_MEMBER_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table BUYING_GROUP_SDEV
drop constraint BGSDEV_UK;
drop index BGSDEV_UK;
alter table BUYING_GROUP_SDEV add constraint BGSDEV_UK
Unique( BUSINESS_SEGMENT_ID, BG_SDEV_MGR_DESCRIPTION )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table BUYING_GROUP_SDEV
drop constraint BGSDEV_PK;
drop index BGSDEV_PK;
alter table BUYING_GROUP_SDEV add constraint BGSDEV_PK
Primary Key( BG_SDEV_MGR_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CANADA_CATEGORY
drop constraint CANCAT_UK;
drop index CANCAT_UK;
alter table CANADA_CATEGORY add constraint CANCAT_UK
Unique( BUSINESS_SEGMENT_ID, CANADA_CATEGORY_DESCRIPTION )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CANADA_CATEGORY
drop constraint CANCAT_PK;
drop index CANCAT_PK;
alter table CANADA_CATEGORY add constraint CANCAT_PK
Primary Key( CANADA_CATEGORY_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CANADA_DISTRIBUTION_CHANNEL
drop constraint CANDISTCNL_PK;
drop index CANDISTCNL_PK;
alter table CANADA_DISTRIBUTION_CHANNEL add constraint CANDISTCNL_PK
Primary Key( CAN_DIST_CHANNEL_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 81920
next 40960
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CANADA_DISTRIBUTION_CHANNEL
drop constraint CANDISTCNL_UK;
drop index CANDISTCNL_UK;
alter table CANADA_DISTRIBUTION_CHANNEL add constraint CANDISTCNL_UK
Unique( CAN_DIST_CHANNEL_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 40960
next 40960
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CANADA_DIVISION
drop constraint CANDIV_UK;
drop index CANDIV_UK;
alter table CANADA_DIVISION add constraint CANDIV_UK
Unique( BUSINESS_SEGMENT_ID, CANADA_DIVISION_DESCRIPTION )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CANADA_DIVISION
drop constraint CANDIV_PK;
drop index CANDIV_PK;
alter table CANADA_DIVISION add constraint CANDIV_PK
Primary Key( CANADA_DIVISION_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CANADA_FAMILY
drop constraint CANFAM_UK;
drop index CANFAM_UK;
alter table CANADA_FAMILY add constraint CANFAM_UK
Unique( BUSINESS_SEGMENT_ID, CANADA_FAMILY_DESCRIPTION )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CANADA_FAMILY
drop constraint CANFAM_PK;
drop index CANFAM_PK;
alter table CANADA_FAMILY add constraint CANFAM_PK
Primary Key( CANADA_FAMILY_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CANADA_GROUP
drop constraint CANGRP_UK;
drop index CANGRP_UK;
alter table CANADA_GROUP add constraint CANGRP_UK
Unique( BUSINESS_SEGMENT_ID, CANADA_GROUP_DESCRIPTION )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CANADA_GROUP
drop constraint CANGRP_PK;
drop index CANGRP_PK;
alter table CANADA_GROUP add constraint CANGRP_PK
Primary Key( CANADA_GROUP_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CASEPACK
drop constraint CSPACK_UK;
drop index CSPACK_UK;
alter table CASEPACK add constraint CSPACK_UK
Unique( BUSINESS_SEGMENT_ID, CASEPACK_CODE )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 81920
next 40960
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CASEPACK
drop constraint CSPACK_PK;
drop index CSPACK_PK;
alter table CASEPACK add constraint CSPACK_PK
Primary Key( CASEPACK_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CASEPACK_XREF
drop constraint CPXREF_PK;
drop index CPXREF_PK;
alter table CASEPACK_XREF add constraint CPXREF_PK
Primary Key( CASEPACK_FROM_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CATEGORY
drop constraint CAT_UK;
drop index CAT_UK;
alter table CATEGORY add constraint CAT_UK
Unique( BUSINESS_SEGMENT_ID, CATEGORY_DESCRIPTION )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CATEGORY
drop constraint CAT_PK;
drop index CAT_PK;
alter table CATEGORY add constraint CAT_PK
Primary Key( CATEGORY_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CM_BRAND
drop constraint CM_BRAND_UK;
drop index CM_BRAND_UK;
alter table CM_BRAND add constraint CM_BRAND_UK
Unique( CM_BRAND_DESCRIPTION, BUSINESS_SEGMENT_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CM_BRAND
drop constraint CMBRAND_PK;
drop index CMBRAND_PK;
alter table CM_BRAND add constraint CMBRAND_PK
Primary Key( CM_BRAND_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table STG_COSMOS_CUST
drop constraint OCO_91743;
drop index OCO_91743;
alter table STG_COSMOS_CUST add constraint OCO_91743
Primary Key( SOLD_TO_CODE, SHIP_TO_CODE )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 2252800
next 204800
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table STG_COSMOS_CUST_REALIGN
drop constraint OCO_91994;
drop index OCO_91994;
alter table STG_COSMOS_CUST_REALIGN add constraint OCO_91994
Primary Key( SOLD_TO_CODE, SHIP_TO_CODE )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CM_BUYING_GROUP
drop constraint CM_BUYING_GRP_UK;
drop index CM_BUYING_GRP_UK;
alter table CM_BUYING_GROUP add constraint CM_BUYING_GRP_UK
Unique( CM_BUYING_GROUP_DESCRIPTION, BUSINESS_SEGMENT_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CM_BUYING_GROUP
drop constraint CMBYGRP_PK;
drop index CMBYGRP_PK;
alter table CM_BUYING_GROUP add constraint CMBYGRP_PK
Primary Key( CM_BUYING_GROUP_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CM_BUYING_GROUP_SDEV
drop constraint CMBGSDEV_PK;
drop index CMBGSDEV_PK;
alter table CM_BUYING_GROUP_SDEV add constraint CMBGSDEV_PK
Primary Key( CM_BG_SDEV_MGR_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CM_BUYING_GROUP_SDEV
drop constraint CM_BUYING_GRP_SDEV_UK;
drop index CM_BUYING_GRP_SDEV_UK;
alter table CM_BUYING_GROUP_SDEV add constraint CM_BUYING_GRP_SDEV_UK
Unique( CM_BG_SDEV_MGR_DESCRIPTION, BUSINESS_SEGMENT_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CM_HDQ_SDEV_MGR
drop constraint CM_HDQ_SDEV_MGR_UK;
drop index CM_HDQ_SDEV_MGR_UK;
alter table CM_HDQ_SDEV_MGR add constraint CM_HDQ_SDEV_MGR_UK
Unique( CM_HDQ_SDEV_MGR_DESCRIPTION, BUSINESS_SEGMENT_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CM_HDQ_SDEV_MGR
drop constraint CMHDQSDEV_PK;
drop index CMHDQSDEV_PK;
alter table CM_HDQ_SDEV_MGR add constraint CMHDQSDEV_PK
Primary Key( CM_HDQ_SDEV_MGR_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CM_HEADQUARTERS
drop constraint CM_HDQTR_UK;
drop index CM_HDQTR_UK;
alter table CM_HEADQUARTERS add constraint CM_HDQTR_UK
Unique( CM_HDQ_DESCRIPTION, BUSINESS_SEGMENT_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CM_HEADQUARTERS
drop constraint COMMHDQ_PK;
drop index COMMHDQ_PK;
alter table CM_HEADQUARTERS add constraint COMMHDQ_PK
Primary Key( CM_HDQ_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CM_SUBBRAND
drop constraint CM_SUBBRAND_UK;
drop index CM_SUBBRAND_UK;
alter table CM_SUBBRAND add constraint CM_SUBBRAND_UK
Unique( CM_SUBBRAND_DESCRIPTION, BUSINESS_SEGMENT_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CM_SUBBRAND
drop constraint CMSBRD_PK;
drop index CMSBRD_PK;
alter table CM_SUBBRAND add constraint CMSBRD_PK
Primary Key( CM_SUBBRAND_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CUSTOMER_BRANDS_MARKET
drop constraint CBMKT_UK;
drop index CBMKT_UK;
alter table CUSTOMER_BRANDS_MARKET add constraint CBMKT_UK
Unique( BUSINESS_SEGMENT_ID, CUST_BRANDS_MKT_DESCRIPTION )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CUSTOMER_BRANDS_MARKET
drop constraint CBMKT_PK;
drop index CBMKT_PK;
alter table CUSTOMER_BRANDS_MARKET add constraint CBMKT_PK
Primary Key( CUST_BRANDS_MKT_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CUSTOMER_BRANDS_REGION
drop constraint CBREG_PK;
drop index CBREG_PK;
alter table CUSTOMER_BRANDS_REGION add constraint CBREG_PK
Primary Key( CUST_BRANDS_REGION_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CUSTOMER_BRANDS_REGION
drop constraint CBREG_UK;
drop index CBREG_UK;
alter table CUSTOMER_BRANDS_REGION add constraint CBREG_UK
Unique( BUSINESS_SEGMENT_ID, CUST_BRANDS_REGION_DESCRIPTION )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CUSTOMER_BRANDS_TERRITORY
drop constraint CBTERR_UK;
drop index CBTERR_UK;
alter table CUSTOMER_BRANDS_TERRITORY add constraint CBTERR_UK
Unique( BUSINESS_SEGMENT_ID, CUST_BRANDS_TERR_DESCRIPTION )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table CUSTOMER_BRANDS_TERRITORY
drop constraint CBTERR_PK;
drop index CBTERR_PK;
alter table CUSTOMER_BRANDS_TERRITORY add constraint CBTERR_PK
Primary Key( CUST_BRANDS_TERR_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table DECISION_CENTER
drop constraint DCENTR_UK;
drop index DCENTR_UK;
alter table DECISION_CENTER add constraint DCENTR_UK
Unique( BUSINESS_SEGMENT_ID, DECISION_CENTER_DESCRIPTION )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table DECISION_CENTER
drop constraint DCENTR_PK;
drop index DCENTR_PK;
alter table DECISION_CENTER add constraint DCENTR_PK
Primary Key( DECISION_CENTER_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table DISTRIBUTION_CHANNEL
drop constraint DC_UK;
drop index DC_UK;
alter table DISTRIBUTION_CHANNEL add constraint DC_UK
Unique( DIST_CHANNEL_DESCRIPTION, BUSINESS_SEGMENT_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table DISTRIBUTION_CHANNEL
drop constraint DC_PK;
drop index DC_PK;
alter table DISTRIBUTION_CHANNEL add constraint DC_PK
Primary Key( DIST_CHANNEL_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table DISTRICT_GROUP
drop constraint DISTRGRP_UK;
drop index DISTRGRP_UK;
alter table DISTRICT_GROUP add constraint DISTRGRP_UK
Unique( DISTRICT_GROUP_DESCRIPTION, BUSINESS_SEGMENT_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table DISTRICT_GROUP
drop constraint DISTGRP_PK;
drop index DISTGRP_PK;
alter table DISTRICT_GROUP add constraint DISTGRP_PK
Primary Key( DISTRICT_GROUP_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table DIVISION
drop constraint DIV_PK;
drop index DIV_PK;
alter table DIVISION add constraint DIV_PK
Primary Key( DIVISION_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table DIVISION
drop constraint DIV_UK;
drop index DIV_UK;
alter table DIVISION add constraint DIV_UK
Unique( BUSINESS_SEGMENT_ID, DIVISION_DESCRIPTION )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table DIVISION_GROUP
drop constraint DIVGRP_UK;
drop index DIVGRP_UK;
alter table DIVISION_GROUP add constraint DIVGRP_UK
Unique( BUSINESS_SEGMENT_ID, DIVISION_GROUP_DESCRIPTION )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table DIVISION_GROUP
drop constraint DIVGRP_PK;
drop index DIVGRP_PK;
alter table DIVISION_GROUP add constraint DIVGRP_PK
Primary Key( DIVISION_GROUP_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table END_USER_SEGMENT
drop constraint EUSER_SEG_UK;
drop index EUSER_SEG_UK;
alter table END_USER_SEGMENT add constraint EUSER_SEG_UK
Unique( ENDUSER_SEGMENT_DESCRIPTION, BUSINESS_SEGMENT_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table END_USER_SEGMENT
drop constraint EUSEG_PK;
drop index EUSEG_PK;
alter table END_USER_SEGMENT add constraint EUSEG_PK
Primary Key( ENDUSER_SEGMENT_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table FINANCE_CASEPACK
drop constraint FINCP_PK;
drop index FINCP_PK;
alter table FINANCE_CASEPACK add constraint FINCP_PK
Primary Key( FINANCE_CASEPACK_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table FINANCE_CASEPACK
drop constraint FINCP_UK;
drop index FINCP_UK;
alter table FINANCE_CASEPACK add constraint FINCP_UK
Unique( BUSINESS_SEGMENT_ID, FINANCE_CASEPACK_DESCRIPTION )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 40960
next 40960
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table FINANCE_DIXIE_PLANNING
drop constraint FINDP_PK;
drop index FINDP_PK;
alter table FINANCE_DIXIE_PLANNING add constraint FINDP_PK
Primary Key( FINANCE_DIXIE_PLAN_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table FINANCE_DIXIE_PLANNING
drop constraint FINDP_UK;
drop index FINDP_UK;
alter table FINANCE_DIXIE_PLANNING add constraint FINDP_UK
Unique( BUSINESS_SEGMENT_ID, FINANCE_DIXIE_PLAN_DESCRIPTION )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 40960
next 40960
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table GEOMARKET
drop constraint GEOMKT_PK;
drop index GEOMKT_PK;
alter table GEOMARKET add constraint GEOMKT_PK
Primary Key( GEOMARKET_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table GEOMARKET
drop constraint GEOMKT_UK;
drop index GEOMKT_UK;
alter table GEOMARKET add constraint GEOMKT_UK
Unique( BUSINESS_SEGMENT_ID, GEOMARKET_DESCRIPTION )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table HDQ_REGION
drop constraint HDQREG_PK;
drop index HDQREG_PK;
alter table HDQ_REGION add constraint HDQREG_PK
Primary Key( HDQ_REGION_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table HDQ_REGION
drop constraint HDQREG_UK;
drop index HDQREG_UK;
alter table HDQ_REGION add constraint HDQREG_UK
Unique( HDQ_REGION_DESCRIPTION, BUSINESS_SEGMENT_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table HDQ_SDEV_MGR
drop constraint HDQSDM_PK;
drop index HDQSDM_PK;
alter table HDQ_SDEV_MGR add constraint HDQSDM_PK
Primary Key( HDQ_SDEV_MGR_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table HDQ_SDEV_MGR
drop constraint HDQSDM_UK;
drop index HDQSDM_UK;
alter table HDQ_SDEV_MGR add constraint HDQSDM_UK
Unique( BUSINESS_SEGMENT_ID, HDQ_SDEV_MGR_DESCRIPTION )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table HEADQUARTERS
drop constraint HDQ_UK;
drop index HDQ_UK;
alter table HEADQUARTERS add constraint HDQ_UK
Unique( BUSINESS_SEGMENT_ID, HDQ_DESCRIPTION )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table HEADQUARTERS
drop constraint HDQ_PK;
drop index HDQ_PK;
alter table HEADQUARTERS add constraint HDQ_PK
Primary Key( HDQ_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table HIERARCHY
drop constraint HRARCY_PK;
drop index HRARCY_PK;
alter table HIERARCHY add constraint HRARCY_PK
Primary Key( HIERARCHY_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 81920
next 40960
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table HIERARCHY
drop constraint HRARCY_UK;
drop index HRARCY_UK;
alter table HIERARCHY add constraint HRARCY_UK
Unique( HIERARCHY_DESCRIPTION, BUSINESS_SEGMENT_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 122880
next 65536
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table HIST_CASEPACK
drop constraint HIST_CASEPACK_PK;
drop index HIST_CASEPACK_PK;
alter table HIST_CASEPACK add constraint HIST_CASEPACK_PK
Primary Key( HIST_CASEPACK_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1064960
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table HIST_CASEPACK
drop constraint HIST_CASEPACK_UK;
drop index HIST_CASEPACK_UK;
alter table HIST_CASEPACK add constraint HIST_CASEPACK_UK
Unique( HIST_CASEPACK_CODE, BUSINESS_SEGMENT_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1064960
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table HIST_RPTLOC
drop constraint HIST_RPTLOC_PK;
drop index HIST_RPTLOC_PK;
alter table HIST_RPTLOC add constraint HIST_RPTLOC_PK
Primary Key( HIST_RPTLOC_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1064960
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table HIST_RPTLOC
drop constraint HIST_RPTLOC_UK;
drop index HIST_RPTLOC_UK;
alter table HIST_RPTLOC add constraint HIST_RPTLOC_UK
Unique( HIST_RPTLOC_CODE, BUSINESS_SEGMENT_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1064960
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table INT_BRAND
drop constraint INT_BRAND_PK;
drop index INT_BRAND_PK;
alter table INT_BRAND add constraint INT_BRAND_PK
Unique( BRAND_DESCRIPTION, BUSINESS_SEGMENT_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1064960
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table INT_HIST_CASEPACK
drop constraint INT_TR_CSPACK_PK;
drop index INT_TR_CSPACK_PK;
alter table INT_HIST_CASEPACK add constraint INT_TR_CSPACK_PK
Primary Key( HIST_CASEPACK_CODE, BUSINESS_SEGMENT_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1064960
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table INT_HIST_RPTLOC
drop constraint INT_TR_REPLOC_PK;
drop index INT_TR_REPLOC_PK;
alter table INT_HIST_RPTLOC add constraint INT_TR_REPLOC_PK
Primary Key( HIST_RPTLOC_CODE, BUSINESS_SEGMENT_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1064960
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table INT_PRODUCT_STRATEGY
drop constraint INT_PRDSTRAT_PK;
drop index INT_PRDSTRAT_PK;
alter table INT_PRODUCT_STRATEGY add constraint INT_PRDSTRAT_PK
Unique( PRODUCT_STRATEGY_DESCRIPTION, BUSINESS_SEGMENT_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1064960
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table INT_REPORTING_LOCATION
drop constraint INT_REPLOC_PK;
drop index INT_REPLOC_PK;
alter table INT_REPORTING_LOCATION add constraint INT_REPLOC_PK
Unique( REPORTING_LOCATION_CODE, BUSINESS_SEGMENT_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 2129920
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table INT_TERRITORY
drop constraint INT_TERR_PK;
drop index INT_TERR_PK;
alter table INT_TERRITORY add constraint INT_TERR_PK
Unique( TERRITORY_CODE, BUSINESS_SEGMENT_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1064960
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table KEY_GROUP
drop constraint KEYGRP_PK;
drop index KEYGRP_PK;
alter table KEY_GROUP add constraint KEYGRP_PK
Primary Key( KEY_GROUP_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1064960
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table LEGACY_HIERARCHY
drop constraint LEGHIERCY_UK;
drop index LEGHIERCY_UK;
alter table LEGACY_HIERARCHY add constraint LEGHIERCY_UK
Unique( CHANNEL )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 204800
next 98304
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table LEGACY_HIERARCHY
drop constraint LEGHIERCY_PK;
drop index LEGHIERCY_PK;
alter table LEGACY_HIERARCHY add constraint LEGHIERCY_PK
Primary Key( LEGACY_HIERARCHY_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 204800
next 40960
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table MARKET
drop constraint MKT_PK;
drop index MKT_PK;
alter table MARKET add constraint MKT_PK
Primary Key( MARKET_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table MARKET
drop constraint MKT_UK;
drop index MKT_UK;
alter table MARKET add constraint MKT_UK
Unique( BUSINESS_SEGMENT_ID, MARKET_CODE )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table INT_MARKET
drop constraint INT_MARKET_PK;
drop index INT_MARKET_PK;
alter table INT_MARKET add constraint INT_MARKET_PK
Primary Key( MARKET_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table INT_PRODUCT_CLASS
drop constraint INT_PRODCLS_PK;
drop index INT_PRODCLS_PK;
alter table INT_PRODUCT_CLASS add constraint INT_PRODCLS_PK
Primary Key( PRODUCT_CLASS_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table KEY_GROUP
drop constraint KEY_GROUP_UK;
drop index KEY_GROUP_UK;
alter table KEY_GROUP add constraint KEY_GROUP_UK
Unique( KEY_GROUP_CODE, BUSINESS_SEGMENT_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 90112
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table HM_AUDIT
drop constraint HM_AUDIT_PK;
drop index HM_AUDIT_PK;
alter table HM_AUDIT add constraint HM_AUDIT_PK
Primary Key( HM_AUDIT_ID )
using index tablespace HMINDEX
pctfree 2
initrans 2
maxtrans 255
storage (
initial 67108864
next 67108864
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table LOCATION
drop constraint LOC_PK;
drop index LOC_PK;
alter table LOCATION add constraint LOC_PK
Primary Key( LOCATION_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table MODEL
drop constraint MODEL_PK;
drop index MODEL_PK;
alter table MODEL add constraint MODEL_PK
Primary Key( MODEL_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table MODEL_GROUP
drop constraint MODEL_GROUP_UK;
drop index MODEL_GROUP_UK;
alter table MODEL_GROUP add constraint MODEL_GROUP_UK
Unique( MODEL_GROUP_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table MODEL_GROUP
drop constraint MODGRP_PK;
drop index MODGRP_PK;
alter table MODEL_GROUP add constraint MODGRP_PK
Primary Key( MODEL_GROUP_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table HM_EXTRACT_MSA
drop constraint HM_EXTRACT_MSA_UK;
drop index HM_EXTRACT_MSA_UK;
alter table HM_EXTRACT_MSA add constraint HM_EXTRACT_MSA_UK
Unique( MODEL_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table MPO_PRODUCT_TYPE
drop constraint MPO_PRODTYPE_PK;
drop index MPO_PRODTYPE_PK;
alter table MPO_PRODUCT_TYPE add constraint MPO_PRODTYPE_PK
Primary Key( MPO_PRODUCT_TYPE_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table MPO_PRODUCT_TYPE
drop constraint MPO_PRODTYPE_UK;
drop index MPO_PRODTYPE_UK;
alter table MPO_PRODUCT_TYPE add constraint MPO_PRODTYPE_UK
Unique( MPO_PRODUCT_TYPE_CODE, MPO_PRODUCT_TYPE_DESCRIPTION )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table MODEL
drop constraint MODEL_CD_UK;
drop index MODEL_CD_UK;
alter table MODEL add constraint MODEL_CD_UK
Unique( MODEL_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 24576
next 24576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table INT_HIST_STOCK_NUMBER
drop constraint HIST_STOCK_NUM_PK;
drop index HIST_STOCK_NUM_PK;
alter table INT_HIST_STOCK_NUMBER add constraint HIST_STOCK_NUM_PK
Primary Key( HIST_STOCK_NUMBER, BUSINESS_SEGMENT_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table DIM_DAILY_CALENDAR
drop constraint DIM_DLY_CAL_PK;
drop index DIM_DLY_CAL_PK;
alter table DIM_DAILY_CALENDAR add constraint DIM_DLY_CAL_PK
Primary Key( DAY_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 81920
next 122880
minextents 1
maxextents 2147483645
pctincrease 50
 freelist groups 1)
;
alter table DIM_PERIOD_CALENDAR
drop constraint DIM_PRD_CAL_PK;
drop index DIM_PRD_CAL_PK;
alter table DIM_PERIOD_CALENDAR add constraint DIM_PRD_CAL_PK
Primary Key( PERIOD_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 81920
next 81920
minextents 1
maxextents 2147483645
pctincrease 50
 freelist groups 1)
;
alter table DIM_WEEK_CALENDAR
drop constraint DIM_WK_CAL_PK;
drop index DIM_WK_CAL_PK;
alter table DIM_WEEK_CALENDAR add constraint DIM_WK_CAL_PK
Primary Key( WEEK_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 81920
next 81920
minextents 1
maxextents 2147483645
pctincrease 50
 freelist groups 1)
;
alter table MODULE
drop constraint MODULE_PK;
drop index MODULE_PK;
alter table MODULE add constraint MODULE_PK
Primary Key( MODULE_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table MODULE_SECURITY
drop constraint MODULE_SECURITY_PK;
drop index MODULE_SECURITY_PK;
alter table MODULE_SECURITY add constraint MODULE_SECURITY_PK
Primary Key( MODULE_ID, USER_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table TMS_CDM_BROKER
drop constraint BROKER_PK;
drop index BROKER_PK;
alter table TMS_CDM_BROKER add constraint BROKER_PK
Primary Key( CDM_BROKER_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table TMS_CDM_BROKER
drop constraint CDM_BROKER_UK;
drop index CDM_BROKER_UK;
alter table TMS_CDM_BROKER add constraint CDM_BROKER_UK
Unique( USER_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table DIM_FUND_CATEGORY
drop constraint FUND_CATEGORY_PK;
drop index FUND_CATEGORY_PK;
alter table DIM_FUND_CATEGORY add constraint FUND_CATEGORY_PK
Primary Key( MISC_FUND_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table DIM_HIST_CASEPACK
drop constraint DIM_HIST_CP_PK;
drop index DIM_HIST_CP_PK;
alter table DIM_HIST_CASEPACK add constraint DIM_HIST_CP_PK
Primary Key( HIST_CASEPACK_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table DIM_HIST_RPTLOC
drop constraint DIM_HIST_RPTLOC_PK;
drop index DIM_HIST_RPTLOC_PK;
alter table DIM_HIST_RPTLOC add constraint DIM_HIST_RPTLOC_PK
Primary Key( HIST_RPTLOC_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table DIM_HIST_STOCK_NUMBER
drop constraint DIM_HIST_STOCK_NUM_PK;
drop index DIM_HIST_STOCK_NUM_PK;
alter table DIM_HIST_STOCK_NUMBER add constraint DIM_HIST_STOCK_NUM_PK
Primary Key( HIST_STOCK_NUMBER )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table DIM_PRODUCT
drop constraint DIM_PRODUCT_PK;
drop index DIM_PRODUCT_PK;
alter table DIM_PRODUCT add constraint DIM_PRODUCT_PK
Primary Key( SKU )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 81920
next 2506752
minextents 1
maxextents 2147483645
pctincrease 50
 freelist groups 1)
;
alter table TMS_KEY_CONTACT
drop constraint KEYCNTCT_PK;
drop index KEYCNTCT_PK;
alter table TMS_KEY_CONTACT add constraint KEYCNTCT_PK
Primary Key( KEY_CONTACT_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table DIM_CUSTOMER
drop constraint DIM_CUSTLOC_PK;
drop index DIM_CUSTLOC_PK;
alter table DIM_CUSTOMER add constraint DIM_CUSTLOC_PK
Primary Key( SHIP_TO_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 81920
next 7692288
minextents 1
maxextents 2147483645
pctincrease 50
 freelist groups 1)
;
alter table TMS_EVENT
drop constraint EVENT_PK;
drop index EVENT_PK;
alter table TMS_EVENT add constraint EVENT_PK
Primary Key( COMMITMENT_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1130496
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table TMS_FORECASTED_PRODUCT
drop constraint FORECSTPRD_PK;
drop index FORECSTPRD_PK;
alter table TMS_FORECASTED_PRODUCT add constraint FORECSTPRD_PK
Primary Key( HIST_RPTLOC_CODE, PRODUCT_CODE, DAY_CODE, PRODUCT_CODE_TYPE )
using index tablespace HMDATA
pctfree 15
initrans 2
maxtrans 255
storage (
initial 235929600
next 26214400
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table STG_TRS_EVENT_DLY_3K
drop constraint EVNT_DLY_3K_PK;
drop index EVNT_DLY_3K_PK;
alter table STG_TRS_EVENT_DLY_3K add constraint EVNT_DLY_3K_PK
Primary Key( COMMITMENT_SEQUENCE, COMMITMENT_ID, PROGRAM_CODE )
using index tablespace HMINDEX
pctfree 15
initrans 2
maxtrans 255
storage (
initial 1048576
next 1064960
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table TMP_COMMITMENTS_TO_DELETE
drop constraint COMMITMENTS_TO_DEL_PK;
drop index COMMITMENTS_TO_DEL_PK;
alter table TMP_COMMITMENTS_TO_DELETE add constraint COMMITMENTS_TO_DEL_PK
Primary Key( COMMITMENT_ID, HIST_RPTLOC_CODE, PRODUCT_CODE, PRODUCT_CODE_TYPE )
using index tablespace HMINDEX
pctfree 15
initrans 2
maxtrans 255
storage (
initial 1048576
next 1064960
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table TMS_FORECASTED_PRODUCT2
drop constraint FORECSTPRD2_PK;
drop index FORECSTPRD2_PK;
alter table TMS_FORECASTED_PRODUCT2 add constraint FORECSTPRD2_PK
Primary Key( HIST_RPTLOC_CODE, PRODUCT_CODE, DAY_CODE, PRODUCT_CODE_TYPE )
using index tablespace HMDATA
pctfree 15
initrans 2
maxtrans 255
storage (
initial 209715200
next 4194304
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table INT_SAP_CUST
drop constraint INT_SAP_CUST_PK;
drop index INT_SAP_CUST_PK;
alter table INT_SAP_CUST add constraint INT_SAP_CUST_PK
Primary Key( SHIP_TO_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1064960
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table DEPT
drop constraint DEPT_PRIMARY_KEY;
drop index DEPT_PRIMARY_KEY;
alter table DEPT add constraint DEPT_PRIMARY_KEY
Primary Key( DEPTNO )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table EMP
drop constraint EMP_PRIMARY_KEY;
drop index EMP_PRIMARY_KEY;
alter table EMP add constraint EMP_PRIMARY_KEY
Primary Key( EMPNO )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table EMP
drop constraint EMP_UK;
drop index EMP_UK;
alter table EMP add constraint EMP_UK
Unique( ENAME, JOB )
using index tablespace HMDATA
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table INT_SAP_PROD
drop constraint INT_SAP_PROD_PK;
drop index INT_SAP_PROD_PK;
alter table INT_SAP_PROD add constraint INT_SAP_PROD_PK
Primary Key( SKU, REPORT_AS_SKU )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table OH_CAT_MASTER
drop constraint OH_CAT_MASTER_PK;
drop index OH_CAT_MASTER_PK;
alter table OH_CAT_MASTER add constraint OH_CAT_MASTER_PK
Primary Key( OH_CAT_MASTER_DESC )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table OH_CAT_SUM
drop constraint OH_CAT_SUM_PK;
drop index OH_CAT_SUM_PK;
alter table OH_CAT_SUM add constraint OH_CAT_SUM_PK
Primary Key( OH_CAT_SUM_DESC )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table OH_CATEGORY
drop constraint OH_CATEGORY_PK;
drop index OH_CATEGORY_PK;
alter table OH_CATEGORY add constraint OH_CATEGORY_PK
Primary Key( OH_CATEGORY_DESC )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table OH_HIGHLIGHT
drop constraint OH_HIGHLIGHT_PK;
drop index OH_HIGHLIGHT_PK;
alter table OH_HIGHLIGHT add constraint OH_HIGHLIGHT_PK
Primary Key( OH_HIGHLIGHT_DESC )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table OH_PLANNER_NAME
drop constraint OH_PLANNER_NAME_PK;
drop index OH_PLANNER_NAME_PK;
alter table OH_PLANNER_NAME add constraint OH_PLANNER_NAME_PK
Primary Key( OH_PLANNER_NAME_DESC )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table OH_PLANNER
drop constraint OH_PLANNER_PK;
drop index OH_PLANNER_PK;
alter table OH_PLANNER add constraint OH_PLANNER_PK
Primary Key( OH_PLANNER_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table OH_SIZE
drop constraint OH_SIZE_PK;
drop index OH_SIZE_PK;
alter table OH_SIZE add constraint OH_SIZE_PK
Primary Key( OH_SIZE_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table OH_SIZE
drop constraint OH_SIZE_SIZEDESC_UK;
drop index OH_SIZE_SIZEDESC_UK;
alter table OH_SIZE add constraint OH_SIZE_SIZEDESC_UK
Unique( OH_SIZE_DESC )
using index tablespace HMDATA
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 1
 freelist groups 1)
;
alter table OH_FCU
drop constraint OH_FCU_PK;
drop index OH_FCU_PK;
alter table OH_FCU add constraint OH_FCU_PK
Primary Key( OH_FCU_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table INT_OH_PRODUCT
drop constraint INT_OH_PRODUCT_PK;
drop index INT_OH_PRODUCT_PK;
alter table INT_OH_PRODUCT add constraint INT_OH_PRODUCT_PK
Primary Key( SKU )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1048576
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table LKP_SAP_ALT_UOM
drop constraint LKP_SAP_ALT_UOM_PK;
drop index LKP_SAP_ALT_UOM_PK;
alter table LKP_SAP_ALT_UOM add constraint LKP_SAP_ALT_UOM_PK
Primary Key( SKU, ALT_UOM )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1024000
next 1024000
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table LKP_PROC_VARS
drop constraint LKP_PROC_VARS_PK;
drop index LKP_PROC_VARS_PK;
alter table LKP_PROC_VARS add constraint LKP_PROC_VARS_PK
Primary Key( VAR_NAME, VAR_TYPE, VAR_CNT )
using index tablespace HMINDEX
pctfree 15
initrans 2
maxtrans 255
storage (
initial 516096
next 516096
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table DWH_NEWS
drop constraint DWH_NEWS_PK;
drop index DWH_NEWS_PK;
alter table DWH_NEWS add constraint DWH_NEWS_PK
Primary Key( NEWS_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 81920
next 81920
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table DWH_USER_NEWS
drop constraint DWH_USER_NEWS_PK;
drop index DWH_USER_NEWS_PK;
alter table DWH_USER_NEWS add constraint DWH_USER_NEWS_PK
Primary Key( USER_ID )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 81920
next 81920
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table DW_SUPPORT_ID
drop constraint DW_SUPPORT_ID_PK;
drop index DW_SUPPORT_ID_PK;
alter table DW_SUPPORT_ID add constraint DW_SUPPORT_ID_PK
Primary Key( SUPPORT_ID )
using index tablespace HMINDEX
pctfree 15
initrans 2
maxtrans 255
storage (
initial 81920
next 81920
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table LKP_SAP_DESC
drop constraint LKP_SAP_DESC_PK;
drop index LKP_SAP_DESC_PK;
alter table LKP_SAP_DESC add constraint LKP_SAP_DESC_PK
Primary Key( SAP_DATA_NAME, SAP_DATA_CODE )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 1048576
next 1064960
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table LKP_SAP_PRODUCT
drop constraint LKP_SAP_PRODUCT_PK;
drop index LKP_SAP_PRODUCT_PK;
alter table LKP_SAP_PRODUCT add constraint LKP_SAP_PRODUCT_PK
Primary Key( SKU, SALES_ORG, DIST_CHANNEL )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 516096
next 516096
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table DIM_SAP_BROKER
drop constraint DIM_SAP_BROKER_PK;
drop index DIM_SAP_BROKER_PK;
alter table DIM_SAP_BROKER add constraint DIM_SAP_BROKER_PK
Primary Key( BROKER_NR )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 81920
next 81920
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
alter table LKP_SAP_BROKER
drop constraint LKP_SAP_BROKER_PK;
drop index LKP_SAP_BROKER_PK;
alter table LKP_SAP_BROKER add constraint LKP_SAP_BROKER_PK
Primary Key( SALE_ORG_CD, DSTRB_CHNL_CD, DIV_CD, CUST_GRP_CD, SALE_DSTRC_CD, MAT
L_PRICE_GRP_CD, VALID_FROM_DT )
using index tablespace HMINDEX
pctfree 10
initrans 2
maxtrans 255
storage (
initial 106496
next 122880
minextents 1
maxextents 2147483645
pctincrease 0
 freelist groups 1)
;
