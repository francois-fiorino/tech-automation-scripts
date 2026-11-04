/*
===============================================================================
SCRIPT: big_plan.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/big_plan.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Preservar EXPLAIN PLAN de consulta extensa de inventário/produtos/localização.

FUNCIONAMENTO DETALHADO
  Agrega INV_QTY_STAT por segmento/case pack/data após três inline views e filtros OR de CM/RT, localizações e janela de 2002.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas conforme limitações individuais.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DIMENSION.DIM_PRODUCT, DIMENSION.DIM_LOCATION, TRN_INVENTORY_DLY_3K, DIM_SUB_LOCATION, PLAN_TABLE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Exige privilégios dos objetos e PLAN_TABLE; não representa SQL genérico de tuning. Strings de data 20020715/16 dependem de tipo/NLS e limite final pode ser meia-noite. Projeções extensas/OR intencionais não foram podadas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente esquema de laboratório equivalente; revisar todos os filtros e tipos antes de EXPLAIN.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Plano estimado gravado em PLAN_TABLE; SELECT de inventário não é executado pelo EXPLAIN.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos de criação, staging, autenticação, sessão
  ou código gerado descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta integral preservada com finalidade e janela fixa explícitas; nenhuma reescrita especulativa de lógica de negócio. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 039 — 04/11/2026
  Correções e melhorias: Consulta de negócio integral preservada.
  Limitações e pendências: Tipos e objetos DIMENSION/TRN_INVENTORY_DLY_3K/DIM_SUB_LOCATION ausentes; BETWEEN textual depende do tipo/NLS e inclui só limites descritos. Não inventar conversão DATE ou mudar precedência AND/OR.
  Homologação necessária: Fornecer DDL/dados fictícios; validar joins/cardinalidade, datas e equivalência das duas alternativas do filtro.
  Parâmetros/execução: manter contrato descrito acima e no corpo histórico.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação realizada: leitura integral e comparação estática; sem compilação
  ou execução Oracle, sem execução de comandos administrativos.

AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de qualquer utilização em produção. Sua execução é de responsabilidade do profissional responsável pelo ambiente. Os mantenedores deste repositório não se responsabilizam por indisponibilidade, perda de dados, alterações indevidas ou outros impactos decorrentes de sua utilização.

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
explain plan for
SELECT i100823 as E100823 , i100824 as E100824 , i100829 as E100829 , i104594 as E104594 , SUM(i104599) as E104599_SUM
 FROM ( SELECT SUB_CATEGORY_DESCRIPTION AS i100809, SALES_CATEGORY_DESCRIPTION AS i100810, 
        MPO_PLANNING_GROUP_DESCRIPTION AS i100811, MPO_PLANNING_GROUP_CODE AS i100812, MPO_PRODUCT_TYPE_CODE AS i100813, 
        MPO_PRODUCT_TYPE_DESCRIPTION AS i100814, REBATE_CLASSIFICATION AS i100815, CANADA_PRODUCT_TYPE AS i100816, 
        INVENTORY_ACTIVITY_CODE AS i100817, SKU AS i100818, SKU_DESCRIPTION AS i100819, SKU_DESCRIPTION_LONG AS i100820, 
        TOTAL_BUSINESS_DESCRIPTION AS i100821, BUSINESS_MODEL_DESCRIPTION AS i100822, BUSINESS_SEGMENT_CODE AS i100823, 
        BUSINESS_SEGMENT_DESCRIPTION AS i100824, DIVISION_DESCRIPTION AS i100825, BUSINESS_CATEGORY_DESCRIPTION AS i100826, 
        BRAND_DESCRIPTION AS i100827, CASE_PACK_CODE AS i100828, CASE_PACK_DESCRIPTION AS i100829, 
        DECISION_CENTER_DESCRIPTION AS i100830, CATEGORY_DESCRIPTION AS i100831, PRODUCT_MANAGER_CODE AS i100832, 
        PRODUCT_MANAGER_DESCRIPTION AS i100833, PRODUCT_STRATEGY_DESCRIPTION AS i100834, PRODUCT_CLASS_DESCRIPTION AS i100835, 
        HIERARCHY_DESCRIPTION AS i100836, ASSET_BASE AS i100839, STOCK_NUMBER AS i100840, MFG_VS_PURCHASED AS i100841, 
        BUSINESS_LEVEL_DESCRIPTION AS i100842, ACCOUNT_EXEC_CODE AS i100843, ACCOUNT_EXEC_DESCRIPTION AS i100844, 
        PRIVATE_LABEL_CODE AS i100845, PRIVATE_LABEL_DESCRIPTION AS i100846, SUB_BUSINESS_DESCRIPTION AS i100847, 
        RETAIL_CATEGORY_DESCRIPTION AS i100848, RETAIL_PRODUCT_DESCRIPTION AS i100849, PRODUCT_DIVISION_DESCRIPTION AS i100850, 
        CANADA_DIVISION_DESCRIPTION AS i100851, CANADA_FAMILY_DESCRIPTION AS i100852, CANADA_GROUP_DESCRIPTION AS i100853, 
        CANADA_CATEGORY_DESCRIPTION AS i100854, UOM_PRIMARY AS i100855, UOM_SECONDARY AS i100856, 
        PRODUCT_CLASSIFICATION_6 AS i100857, PRODUCT_STATUS_FLAG AS i100858, MAJOR_PRODUCT_CODE AS i100859, 
        PRODUCT_LINE_CODE AS i100860, PRODUCT_TYPE_CODE AS i100861, PACKAGE_FINAL_UNITS AS i100862, 
        UNIT_SHIPPING_WEIGHT AS i100863, UNIT_NET_WEIGHT AS i100864, SKU_GROUP AS i100865, FINANCIAL_CATEGORY_CODE AS i100866, 
        STAT_FACTOR AS i100867, CUBE_FACTOR AS i100868, TONNAGE_FACTOR AS i100869, NATIONAL_AVG_FIX_MFG_RATE AS i100871, 
        NATIONAL_AVG_VAR_MFG_RATE AS i100872, UNIVERSAL_PRODUCT_CODE AS i100873, UNIVERSAL_PRODUCT_CODE_LONG AS i100874, 
        PRODUCT_INVOICE_DESCRIPTION_1 AS i100875, PRODUCT_INVOICE_DESCRIPTION_2 AS i100876, 
        PRODUCT_INVOICE_DESCRIPTION_3 AS i100877, CASE_MEGAPALLET_QTY AS i100878, PRODUCT_CUSTOMER_NUMBER AS i100879, 
        CASE_LAYER_QTY AS i100880, WAREHSE_UNIT_LAYER_QTY AS i100881, DISPENSER_TOLERANCE_QTY AS i100882, 
        TRUCKLOAD_CASE_ADDITIONAL_QTY AS i100883, TRUCKLOAD_PALLET_QTY AS i100884, TRUCKLOAD_SLIPSHEET_QTY AS i100885, 
        PRODUCT_LINE AS i100886, TONNAGE_CODE_COMMERCIAL AS i100887, TONNAGE_CODE_CONSUMER AS i100888, 
        CLUB_PRODUCT_DESCRIPTION AS i100889, CLUB_PRODUCT_CATEGORY_GROUP AS i100890, CLUB_PRODUCT_CATEGORY_SUMMARY AS i100891, 
        CLUB_PRODUCT_DIVISION_DESC AS i100892, CLUB_BUSINESS_LEVEL_DESC AS i100893, CLUB_BRAND_DESCRIPTION AS i100894, 
        CLUB_PRODUCT_GROUP_DESCRIPTION AS i100895, CLUB_PRODUCT_CATEGORY_DESC AS i100896, DOMESTIC AS i100897, 
        CANADA AS i100899, OWNER AS i100900, CAN_DIST_CHANNEL_CODE AS i100901, CAN_DIST_CHANNEL_DESCRIPTION AS i100902, 
        FINANCE_DIXIE_PLAN_DESCRIPTION AS i100903, FINANCE_CASEPACK_DESCRIPTION AS i100904, HIERARCHY_CODE AS i100905, 
        CATEGORY_CODE AS i100906, PRODUCT_STRATEGY_CODE AS i100907, PRODUCT_CLASS_CODE AS i100908, ASSET_LEVEL_CODE AS i100909, 
        ASSET_LEVEL_DESCRIPTION AS i100910, PRODUCT_GROUP_DESCRIPTION AS i100911, CM_BRAND_DESCRIPTION AS i100912, 
        CM_SUBBRAND_DESCRIPTION AS i100913, PRODUCT_MGR_BRAND_DESCRIPTION AS i100914, PROD_MGR_SUBBRAND_DESCRIPTION AS i100915, 
        ENDUSER_SEGMENT_DESCRIPTION AS i100916, PROD_MGR_ENDUSER_DESCRIPTION AS i100917, QUALITY_LEVEL_DESCRIPTION AS i100918, 
        PROD_MGR_QUALITY_DESCRIPTION AS i100919, STOCK_NUMBER_DESCRIPTION AS i100922, CUSTOMER_BRAND_IND AS i100923, 
        BRANDED_INDICATOR AS i118387, SUBSTRATE AS i118388, VOLUME_OR_SIZE AS i118389 FROM DIMENSION.DIM_PRODUCT ) o100804,
      ( SELECT LOCATION_DESCRIPTION AS i102098, LOCATION_CODE AS i102099, SALES_LOCATION_CODE AS i102100, 
        LOCATION_ADDRESS_1 AS i102101, LOCATION_ADDRESS_2 AS i102102, LOCATION_CITY AS i102103, LOCATION_STATE AS i102104, 
        LOCATION_ZIP AS i102105, PRODUCTION_LOCATION_FLAG AS i102106, SHIPPING_LOCATION_FLAG AS i102107, 
        TOTAL_LOCATION AS i102108 FROM DIMENSION.DIM_LOCATION ) o102089,
      ( SELECT ACTIVITY_DATE AS i104594, SKU AS i104595, LOCATION_CODE AS i104596, INV_QTY_TONS AS i104597, 
        INV_QTY_PHYS AS i104598, INV_QTY_STAT AS i104599 FROM (select
                                                                a.activity_date,
                                                                a.sku,
                                                                b.location_code,
                                                                sum(inv_qty_tons) inv_qty_tons,
                                                                sum(inv_qty_phys) inv_qty_phys,
                                                                sum(inv_qty_stat) inv_qty_stat
                                                               from trn_inventory_dly_3k a,
                                                               dim_sub_location b
                                                               where a.sub_location_code = b.sub_location_code
                                                               group by a.activity_date,a.sku,
                                                               b.location_code) CUO104592 ) o104592
                                                               WHERE ( (i100818 = i104595)
                                                               and (i102099 = i104596))
                                                               AND ( o100804.i100829 IN ('NBT 36-ROLL','NBT 24-ROLL',
                                                                                         'NBT 12-ROLL','NBT 12-ROLL DBL',
                                                                                         'NBT 24 ROLL DBL'))
                                                               AND (  ( o100804.i100823 = 'CM' 
                                                               AND o100804.i100830 IN ('DIFFERENTIATED PRODUCTS',
                                                                                       'UNIVERSAL PRODUCTS') 
                                                               AND o102089.i102099 NOT IN ('0000','0005','0006','0007','0008',
                                                                                           '0009','0011','0195','0196','0214',
                                                                                           '0221','0234','0239','0263','0264',
                                                                                           '026H','0272','0273','0276','0278',
                                                                                           '0280','0281','0291','0345','0346',
                                                                                           '0376','0377','0382','0509','051C',
                                                                                           '0564','056D','0722','0737','0765',
                                                                                           '0260') 
                                                               AND o100804.i100906 IN ('DC_CAT','UNIV_CAT','WP_CAT') 
                                                               AND o100804.i100909 IN ('NPKN','OTHERC','SPCNAP','TISS','TOWL',
                                                                                       'WIPER') 
                                                               OR o102089.i102099 NOT IN ('0000','0005','0006','0007','0008',
                                                                                          '0009','0011','0195','0196','0214',
                                                                                          '0221','0234','0239','0243','0263',
                                                                                          '0264','026H','0272','0273','0276',
                                                                                          '0278','0280','0281','0291','0345',
                                                                                          '0376','0377','0509','051C','0564',
                                                                                          '056D','0722','0750','0752','0765') 
                                                               AND o100804.i100823 = 'RT' 
                                                               AND o100804.i100842 = 'TISSUE TOWEL NAPKIN' ) )
   AND ( o104592.i104594 BETWEEN '20020715' AND '20020716')
   GROUP BY i100823, i100824, i100829, i104594
/
