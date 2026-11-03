/*
===============================================================================
SCRIPT: link.sql
CATEGORIA: Oracle / Segurança / Database links
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/link.sql
REVISÃO: 2026-11-03; análise estática integral; sem execução Oracle.

OBJETIVO
  Documentar a remoção de um database link público e a criação de outro link
  público com autenticação remota fixa, preservando as duas operações da fonte.

FUNCIONAMENTO
  DROP PUBLIC DATABASE LINK seguido de CREATE PUBLIC DATABASE LINK com
  CONNECT TO ... IDENTIFIED BY ... USING. O original remove e cria nomes
  DIFERENTES. Não foi presumido que se trata de recriação do mesmo link.
  Esta proposta usa somente marcadores fictícios e está bloqueada por padrão.

PRÉ-REQUISITOS E DEPENDÊNCIAS
  SQL*Plus/SQLcl em laboratório descartável, conectado ao container correto;
  Oracle Net configurado em ambos os bancos e serviço remoto resolvível.
  Confirmar GLOBAL_NAMES, domínio do banco e os dois nomes antes de adaptação.
  Capturar previamente a definição e dependências do link a remover, por um
  procedimento autorizado que proteja os dados de autenticação.

PRIVILÉGIOS NECESSÁRIOS
  DROP PUBLIC DATABASE LINK e CREATE PUBLIC DATABASE LINK no banco local;
  CREATE SESSION e privilégios mínimos de negócio para a conta remota.
  O link público permite a outros usuários locais acessar o remoto com a
  identidade fixa configurada: aprovação de segurança é obrigatória.

PARÂMETROS DE ENTRADA
  Não aceita parâmetros de linha de comando nem substituição SQL*Plus.
  Marcadores de edição local: LINK_PUBLICO_A_REMOVER, LINK_PUBLICO_A_CRIAR,
  USUARIO_REMOTO, <SENHA_REMOTA> e SERVICO_REMOTO.
  Não colocar senha real no repositório. A cópia operacional deve seguir o
  processo de gestão de segredos e de auditoria do ambiente. Não há mecanismo
  de fornecimento seguro de senha implementado ou homologado nesta proposta.

INSTRUÇÕES E EXEMPLO DE EXECUÇÃO
  Somente após revisão e adaptação de uma cópia privada para laboratório:
    SQL> @link.sql
  A versão publicada SEMPRE encerra o cliente antes dos DDLs. A remoção do
  bloqueio na cópia privada exige decisão explícita do revisor e os testes
  abaixo; não basta substituir os marcadores. Usar sessão cliente dedicada.

RISCOS E IMPACTOS OPERACIONAIS
  CRÍTICO: DROP perde a definição do link e pode interromper dependências.
  DDL não é revertido por ROLLBACK; a falha do CREATE não desfaz o DROP.
  DROP e CREATE não formam operação atômica. O comportamento para link ausente
  passa a interromper o cliente com WHENEVER SQLERROR, em vez de continuar.
  ECHO/VERIFY e SPOOL são desligados como precaução local; isso não elimina
  histórico, logs de outros clientes, trace ou auditoria no servidor.
  EXIT encerra o cliente; usar conexão nova sem transação de aplicação.

COMPATIBILIDADE CONHECIDA
  Sintaxe base de CREATE/DROP PUBLIC DATABASE LINK documentada no SQL Language
  Reference Oracle 19c. Isso não constitui teste nem homologação em 19c ou
  qualquer outra versão. Não utiliza IF EXISTS/IF NOT EXISTS.

CORREÇÕES E MELHORIAS REALIZADAS
  Credencial literal e identificadores de ambiente substituídos por marcadores
  fictícios. Nenhum valor sensível original foi incluído em código, histórico
  Git ou documentação. Acrescentado bloqueio incondicional antes de todo DDL.
  SET DEFINE OFF evita interpolação acidental de & na cópia SQL*Plus.
  Preservado o comentário histórico vazio e a sequência DROP/CREATE abaixo.

LIMITAÇÕES E PENDÊNCIAS DE HOMOLOGAÇÃO
  Confirmar intenção dos dois nomes distintos e necessidade de escopo PUBLIC;
  definir entrada segura de segredo; testar grants, Oracle Net, GLOBAL_NAMES,
  falha do CREATE após DROP, dependências e recuperação em laboratório.
  Original continua retido; somente esta proposta sanitizada é publicável na
  branch de revisão. Não está aprovada para a main ou implantação.

REFERÊNCIAS TÉCNICAS
  https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/CREATE-DATABASE-LINK.html
  https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/DROP-DATABASE-LINK.html

AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de
qualquer utilização em produção. Sua execução é de responsabilidade do
profissional responsável pelo ambiente. Os mantenedores deste repositório não
se responsabilizam por indisponibilidade, perda de dados, alterações indevidas
ou outros impactos decorrentes de sua utilização.
===============================================================================
*/

set echo off
set verify off
set define off
spool off
whenever oserror exit failure rollback
whenever sqlerror exit failure rollback

begin
  raise_application_error(-20001,
    'Proposta bloqueada: revisar nomes, segredo, impactos e homologacao.');
end;
/
-- Segunda barreira: encerra mesmo se o bloco acima não for enviado ao banco.
exit failure rollback

/*  */
drop public database link LINK_PUBLICO_A_REMOVER;
create public database link LINK_PUBLICO_A_CRIAR
connect to USUARIO_REMOTO identified by "<SENHA_REMOTA>"
using 'SERVICO_REMOTO';
