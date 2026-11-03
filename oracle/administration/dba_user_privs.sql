/*
===============================================================================
SCRIPT: dba_user_privs.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _security_scripts/dba_user_privs.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar view customizada de privilégios diretos e via uma camada de roles.

FUNCIONAMENTO DETALHADO
  Consulta SYS.SYSAUTH$/USER$/SYSTEM_PRIVILEGE_MAP com UNION; mapeia GRANTEE#1 a PUBLIC e trunca nomes.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/alteração/execução e SELECT DIRETO conforme LIMITAÇÕES.
  Grants por role podem não valer para views/procedimentos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.SYSAUTH$, SYS.USER$, SYS.SYSTEM_PRIVILEGE_MAP; view DBA_USER_PRIVS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Acesso a tabelas internas e CREATE VIEW; sensível à versão/container. Não expande roles recursivamente nem contempla todo privilégio efetivo/objeto. IDs hardcoded e truncamentos são históricos. Substitui objeto homônimo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório com grants diretos aprovados: @dba_user_privs.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  USERNAME, ROLENAME e PRIVILEGE; view criada/substituída.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PROPOSTA DE REVISÃO: o código pode modificar objetos, dados, jobs,
  arquivos ou sessão, conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Definição original preservada; não alegar equivalência a auditoria completa de privilégios. 
  Revisão estática somente; implantação depende de testes e aprovação do PR.
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
CREATE OR REPLACE VIEW DBA_USER_PRIVS (USERNAME, ROLENAME, PRIVILEGE) AS
SELECT DECODE(SA1.GRANTEE#, 1, 'PUBLIC', U1.NAME), SUBSTR(U2.NAME,1,20),
SUBSTR(SPM.NAME,1,27)
FROM SYS.SYSAUTH$ SA1, SYS.SYSAUTH$ SA2, SYS.USER$ U1, SYS.USER$ U2, SYS.SYSTEM_PRIVILEGE_MAP SPM
WHERE SA1.GRANTEE# = U1.USER# AND SA1.PRIVILEGE# = U2.USER# AND U2.USER# = SA2.GRANTEE# AND SA2.PRIVILEGE# = SPM.PRIVILEGE
UNION
SELECT U.NAME, NULL, SUBSTR(SPM.NAME,1,27)
FROM SYS.SYSTEM_PRIVILEGE_MAP SPM, SYS.SYSAUTH$ SA, SYS.USER$ U
WHERE SA.GRANTEE#=U.USER# AND SA.PRIVILEGE#=SPM.PRIVILEGE
/
