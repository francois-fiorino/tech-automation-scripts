/*
===============================================================================
SCRIPT: cre_user.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/cre_user.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar usuário com tablespaces, quota ilimitada e roles do exemplo.

FUNCIONAMENTO DETALHADO
  CREATE USER parametrizado seguido de GRANT CONNECT e SCOPUS_ROLE; senha é capturada com ACCEPT HIDE.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/execução e SELECT DIRETO conforme LIMITAÇÕES; roles
  podem não atender compilação de objetos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  CREATE USER, CONNECT, SCOPUS_ROLE, tablespaces de entrada

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Privilégios administrativos de usuário/grant e role customizada SCOPUS_ROLE. Quota unlimited pode consumir tablespace. Não usar aspas/metacaracteres em entradas; não inserir senha em script/histórico. DDL confirma transações.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: definir USER/DEFAULT/TEMP e executar @cre_user.sql; senha será solicitada sem eco.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Usuário criado e grants aplicados, ou erros de objetos/permissões.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cria/modifica objetos, dados, credenciais ou sessão
  conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  VERIFY/ECHO desabilitados e ACCEPT HIDE evita exposição; senha citada entre aspas e variável removida no final. Roles/quota originais preservadas para revisão. 
  Revisão estática somente; implantação depende de laboratório e aprovação do PR.
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
set verify off echo off
accept password char prompt 'Senha do usuário de teste: ' hide
create user &&user identified by "&password"
default tablespace &&default
temporary tablespace &temp
quota unlimited on &&default;
grant connect to &&user;
grant scopus_role to &&user;
undef user
undef default
undef password
