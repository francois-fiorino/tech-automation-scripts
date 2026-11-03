/*
===============================================================================
SCRIPT: cr_role.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/cr_role.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar role de leitura para objetos específicos de aplicação e concedê-la a usuário.

FUNCIONAMENTO DETALHADO
  CREATE ROLE SLR_DISC_EDIT, dezesseis GRANT SELECT e GRANT da role a GMPRATIC.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme LIMITAÇÕES; roles não
  bastam para compilar dependências de rotinas armazenadas.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  Role SLR_DISC_EDIT, schemas DIMENSION/KMSLR, usuário GMPRATIC

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Objetos de aplicação e GMPRATIC são exemplos históricos, sem autorização atual implícita. DDL pode confirmar e aplicar parcialmente. Requer decisão de matriz de acesso e privilégios mínimos antes de execução. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Somente revisão: conferir cada objeto e destinatário antes de qualquer execução.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Role criada e grants aplicados parcialmente ou integralmente.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados ou sessão descritos
  acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 037 (2026-11-03): Lista integral de CREATE ROLE/GRANT preservada; não alterado destinatário nem objetos por suposição. Casos de homologação: Objetos/conta inexistentes; role já criada; falha no meio dos grants; autoridade WITH GRANT OPTION; escopo PDB/common. Comentários/créditos históricos preservados. Não aprovado para implantação.

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
create role SLR_DISC_EDIT;
grant select on
DIMENSION.DIM_CUSTOMER to SLR_DISC_EDIT;
grant select on DIMENSION.DIM_DAILY_CALENDAR to SLR_DISC_EDIT;
grant select on DIMENSION.DIM_LOCATION to SLR_DISC_EDIT;
grant select on DIMENSION.DIM_SAP_CARRIER to SLR_DISC_EDIT;
grant select on DIMENSION.DIM_PRODUCT to SLR_DISC_EDIT;
grant select on DIMENSION.DIM_ROUTE_CODE to SLR_DISC_EDIT;
grant select on DIMENSION.MTV_DIM_CUST_LOCATION to SLR_DISC_EDIT;
grant select on DIMENSION.LKP_ROUTE_DETERMINATION to SLR_DISC_EDIT;
grant select on DIMENSION.DIM_SHIPPING_POINT to SLR_DISC_EDIT;
grant select on DIMENSION.LKP_SAP_DESC to SLR_DISC_EDIT;
grant select on KMSLR.ODS_SAP_DELIVERY_HDR to SLR_DISC_EDIT;
grant select on KMSLR.ODS_SAP_DELIVERY_ITEM to SLR_DISC_EDIT;
grant select on KMSLR.ODS_SAP_DELIVERY_SHIPMENT_XREF to SLR_DISC_EDIT;
grant select on KMSLR.ODS_SAP_SHIPMENT_HDR to SLR_DISC_EDIT;
grant select on KMSLR.ODS_SAP_SHIPMENT_STAGE to SLR_DISC_EDIT;
grant select on KMSLR.ODS_SAP_SHIP_STG_STATS_HIST
to SLR_DISC_EDIT;
grant SLR_DISC_EDIT to GMPRATIC;
