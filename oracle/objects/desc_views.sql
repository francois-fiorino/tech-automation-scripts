/*
===============================================================================
SCRIPT: desc_views.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/desc_views.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Descrever conjunto histórico de views de aplicação.

FUNCIONAMENTO DETALHADO
  Sequência de 32 DESC em DIMENSION, DIS_DWRPT_ADMIN_V4 e TRS com spool.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  Views literais dos schemas DIMENSION, DIS_DWRPT_ADMIN_V4, TRS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Objetos são específicos da aplicação histórica; não fornecidos pelo Oracle padrão. DESCRIBE não consulta registros nem valida lógica/segurança das views.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @desc_views.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Colunas/tipos dos objetos acessíveis ou erros individuais de ausência/privilégio.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Lista completa de objetos e comandos preservada. 
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
set echo on
spool desc_views.lst
desc DIMENSION.V_CAN_CLUB_CUSTOMER
desc DIMENSION.V_CAN_CUSTOMER
desc DIMENSION.V_CAN_FOODSERVICE_PRODUCT
desc DIMENSION.V_CAN_PRODUCT
desc DIMENSION.V_CAN_RETAIL_PRODUCT
desc DIMENSION.V_COMMERCIAL_PRODUCT_DIM
desc DIMENSION.V_DIM_CIT_NATNL_CUST_X_INTRACO
desc DIMENSION.V_DIM_CIT_NTNL_INTL_M_T_CUST
desc DIMENSION.V_DIM_CIT_REGIONAL_TEAMS_CUST
desc DIMENSION.V_DIM_CIT_REG_CUST_X_INTRACO
desc DIMENSION.V_DIM_CLUB_CUSTOMER
desc DIMENSION.V_DIM_CLUB_CUST_X_INTRACO
desc DIMENSION.V_DIM_CM_CUST_X_INTRACO
desc DIMENSION.V_DIM_COMMERCIAL_CUSTOMER
desc DIMENSION.V_DIM_COMMERCIAL_MARKET
desc DIMENSION.V_DIM_COMMERCIAL_PRODUCT
desc DIMENSION.V_DIM_CST_BRND_RGN_TRS_SEC
desc DIMENSION.V_DIM_CUSTOMER
desc DIMENSION.V_DIM_CUSTOMER_SECURED
desc DIMENSION.V_DIM_CUSTOMER_X_INTRACO
desc DIMENSION.V_DIM_FOODSERVICE_PRODUCT
desc DIMENSION.V_DIM_FS_STOCK_NUMBER
desc DIMENSION.V_DIM_PRODUCT
desc DIMENSION.V_DIM_PRODUCT_CONSOLIDATED
desc DIMENSION.V_DIM_REGION_FOR_TRS_SECURE
desc DIMENSION.V_DIM_RETAIL_PRODUCT
desc DIMENSION.V_RETAIL_DIM_PROD_CASEPACK
desc DIMENSION.V_RETAIL_STOCK_NUMBER
desc DIMENSION.V_TMS_OI_EVENTS_INDIRECT_CUST
desc DIS_DWRPT_ADMIN_V4.V_DIS_BUS_TRCK_PTD_3K
desc DIS_DWRPT_ADMIN_V4.V_DIS_BUS_TRCK_PTD_4K
desc TRS.V_TMS_DAILY_EVENT_TRANSACTIONS
spool off
set echo off
