/*
===============================================================================
SCRIPT: recomp_views.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _table_scripts/recomp_views.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Recompilar lista fixa de views da aplicação SNAPSHOT_DBA.

FUNCIONAMENTO DETALHADO
  Cinquenta e três ALTER VIEW nomeados com COMPILE, sem loop ou tratamento global de erro.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS de criação/execução/consulta e permissões administrativas
  conforme limitações; não instalar variantes sobre objetos de trabalho.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  Views SNAPSHOT_DBA.BBS_* listadas no corpo

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Dono/ALTER ANY TABLE conforme versão e grants de dependências. Compilação pode bloquear/invalidar e confirma DDL; não resolve objetos ausentes. Nomes são exclusivos da aplicação histórica.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Revisar lista em clone da aplicação; não executar em produção.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Views recompiladas ou erros por dependência/privilégio/objeto.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: DDL/DML, staging, autenticação ou efeitos da saída
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Lista completa e ordem preservadas; não executada. 
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
alter view SNAPSHOT_DBA.BBS_ACCOUNT_TEAM_LK compile;
alter view SNAPSHOT_DBA.BBS_ADDR_USERS_VW compile;
alter view SNAPSHOT_DBA.BBS_BD_REASON_CODE_LK compile;
alter view SNAPSHOT_DBA.BBS_BD_STATUS_LK compile;
alter view SNAPSHOT_DBA.BBS_BILL_MEDIUM_LK compile;
alter view SNAPSHOT_DBA.BBS_CALLACTIVITY_LK compile;
alter view SNAPSHOT_DBA.BBS_CALLTYPE_LK compile;
alter view SNAPSHOT_DBA.BBS_CELLULAR_LK compile;
alter view SNAPSHOT_DBA.BBS_CID_OR_PHONE_LK compile;
alter view SNAPSHOT_DBA.BBS_CN_PROF_ACTIVITY_LK compile;
alter view SNAPSHOT_DBA.BBS_COMPETITION_LK compile;
alter view SNAPSHOT_DBA.BBS_CONTACTS_VW compile;
alter view SNAPSHOT_DBA.BBS_CO_LK compile;
alter view SNAPSHOT_DBA.BBS_CUSTOMER_NAME_SITEKEY_VW compile;
alter view SNAPSHOT_DBA.BBS_CUSTOMER_NAME_VW compile;
alter view SNAPSHOT_DBA.BBS_CUSTOMER_STATUS_LK compile;
alter view SNAPSHOT_DBA.BBS_DESIGN_LK compile;
alter view SNAPSHOT_DBA.BBS_DISPATCH_STATUS_LK compile;
alter view SNAPSHOT_DBA.BBS_DUNS_LEGAL_STATUS_LK compile;
alter view SNAPSHOT_DBA.BBS_DUNS_SALES_VOL_LK compile;
alter view SNAPSHOT_DBA.BBS_DUNS_SHORT_LK compile;
alter view SNAPSHOT_DBA.BBS_DUNS_TERRITORY_LK compile;
alter view SNAPSHOT_DBA.BBS_DUNS_TYPE_LK compile;
alter view SNAPSHOT_DBA.BBS_EMPLOYEE_VW compile;
alter view SNAPSHOT_DBA.BBS_EQUIPMENT_BRAND_LK compile;
alter view SNAPSHOT_DBA.BBS_EQUIPMENT_LK compile;
alter view SNAPSHOT_DBA.BBS_FIND_REPLACE_LK compile;
alter view SNAPSHOT_DBA.BBS_FUNCTION_LK compile;
alter view SNAPSHOT_DBA.BBS_INDUSTRY_LK compile;
alter view SNAPSHOT_DBA.BBS_INTERACTIONACTIVITY_VW compile;
alter view SNAPSHOT_DBA.BBS_LD_LK compile;
alter view SNAPSHOT_DBA.BBS_LD_SERVICES_LK compile;
alter view SNAPSHOT_DBA.BBS_MAINTENANCE_LK compile;
alter view SNAPSHOT_DBA.BBS_NETWORK_LK compile;
alter view SNAPSHOT_DBA.BBS_ORDERDETAIL_SEARCH_LK compile;
alter view SNAPSHOT_DBA.BBS_ORDER_DETAIL_LK compile;
alter view SNAPSHOT_DBA.BBS_ORDER_INQUIRY_LK compile;
alter view SNAPSHOT_DBA.BBS_PENDING_ORDERS_LK compile;
alter view SNAPSHOT_DBA.BBS_PERCEPTION_LK compile;
alter view SNAPSHOT_DBA.BBS_PROFILE_FREQUENCY_LK compile;
alter view SNAPSHOT_DBA.BBS_REFERRAL_RESULTS_LK compile;
alter view SNAPSHOT_DBA.BBS_REFERRAL_TYPE_LK compile;
alter view SNAPSHOT_DBA.BBS_RELATIONSHIP_LK compile;
alter view SNAPSHOT_DBA.BBS_RESTRICT_TO_HIERARCHY_LK compile;
alter view SNAPSHOT_DBA.BBS_SALUTATION_LK compile;
alter view SNAPSHOT_DBA.BBS_SITE_CODE_LK compile;
alter view SNAPSHOT_DBA.BBS_SITE_CODE_Y_LK compile;
alter view SNAPSHOT_DBA.BBS_SITE_CONTACTS_VW compile;
alter view SNAPSHOT_DBA.BBS_SOCSXRFN_VW compile;
alter view SNAPSHOT_DBA.BBS_SOURCE_LK compile;
alter view SNAPSHOT_DBA.BBS_TIME_SPENT_LK compile;
alter view SNAPSHOT_DBA.BBS_TITLE_LK compile;
alter view SNAPSHOT_DBA.BBS_TRADESTYLE_SITEKEY_VW compile;
