/*
===============================================================================
SCRIPT: db_policies.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/db_policies.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar configuração de políticas VPD/FGAC de objetos.

FUNCIONAMENTO DETALHADO
  Consulta DBA_POLICIES com owner/nome, função de política, operações, check option e enabled.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_POLICIES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Configuração não prova predicado efetivo de uma sessão nem cobre todos os mecanismos de segurança. Não executa função de política ou modifica proteção.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @db_policies.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Objeto/política, dono/package/função e flags SEL/INS/UPD/DEL/CHK_OPTION/ENABLE.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta integral preservada. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem db_policies.sql
rem FUNCTION: SHow report on database policies
rem MRA
rem
COLUMN OBJECT_OWNER   FORMAT A12   HEADING 'Object|Owner'
COLUMN OBJECT_NAME    FORMAT A17   HEADING 'Object|Name'
COLUMN POLICY_NAME    FORMAT A15   HEADING 'Policy|Name'
COLUMN PF_OWNER       FORMAT A12   HEADING 'Policy|Function|Owner'
COLUMN PACKAGE        FORMAT A15   HEADING 'Functions|Package'
COLUMN FUNCTION       FORMAT A15   HEADING 'Function|Name'
COLUMN SEL            FORMAT A3   HEADING 'Sel|?'
COLUMN INS            FORMAT A3   HEADING 'Ins|?'
COLUMN UPD            FORMAT A3   HEADING 'Upd|?'
COLUMN DEL            FORMAT A3   HEADING 'Del|?'
COLUMN CHK_OPTION     FORMAT A3   HEADING 'Check|Option'
COLUMN ENABLE         FORMAT A3   HEADING 'Enabled?'
SET LINES 132 VERIFY OFF FEEDBACK OFF PAGES 47
ttitle 'DB Policies Report'
BREAK ON object_owner
spool db_policies.lst
SELECT
  OBJECT_OWNER,
  OBJECT_NAME,
  POLICY_NAME,
  PF_OWNER,
  PACKAGE,
  FUNCTION,
  SEL,
  INS,
  UPD,
  DEL,
  CHK_OPTION,
  ENABLE
FROM
 DBA_POLICIES
ORDER BY 
 1,2,3;
SPOOL OFF
SET LINES 80 VERIFY ON FEEDBACK ON PAGES 22
CLEAR BREAKS
CLEAR COLUMNS
TTITLE OFF
