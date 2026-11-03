/*
===============================================================================
SCRIPT: policy_rep.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / misc_scripts/policy_rep.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar configuração VPD com flags compactos por operação.

FUNCIONAMENTO DETALHADO
  Consulta DBA_POLICIES e traduz YES/NO para Y/N em SEL/INS/UPD/DEL.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_POLICIES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não executa função de política nem audita predicados aplicados a sessões. Variante difere de DB_POLICIES pela tradução visual e ausência de ordenação.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @policy_rep.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Objeto/política/função e flags, CHK_OPTION e ENABLE.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
COL object_owner format a15 heading 'Owner'
COL object_name format a15 heading 'Object'
COL policy_name format a15 heading 'Policy'
COL pf_owner format a15 heading 'Policy Proc Owner'
COL PACKAGE format a15 heading 'Policy Package'
col FUNCTION format a15 heading 'Policy Function'
col sel format a1 heading 'S'
col ins format a1 heading 'I'
col upd format a1 heading 'U'
col del format a1 heading 'D'
set lines 132 pages 50
ttitle 'Fine Grained Security Policies'
spool policy_rep.lst
SELECT
OBJECT_OWNER,
OBJECT_NAME,    
POLICY_NAME,    
PF_OWNER,       
PACKAGE,        
FUNCTION,       
DECODE(SEL,'YES','Y','NO','N',SEL) SEL,            
DECODE(INS,'YES','Y','NO','N',INS) INS,            
DECODE(UPD,'YES','Y','NO','N',UPD) UPD,            
DECODE(DEL,'YES','Y','NO','N',DEL) DEL,            
CHK_OPTION,     
ENABLE
FROM DBA_POLICIES;
SPOOL OFF
set lines 80 pages 22
ttitle off
