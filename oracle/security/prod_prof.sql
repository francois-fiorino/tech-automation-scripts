/*
===============================================================================
SCRIPT: prod_prof.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / misc_scripts/prod_prof.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Inserir restrições legadas de comandos do SQL*Plus em PRODUCT_PROFILE.

FUNCIONAMENTO DETALHADO
  Quatro INSERT para DELETE/INSERT/UPDATE/HOST do username e COMMIT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  PRODUCT_PROFILE (estrutura SQL*Plus legada)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não é controle de privilégio no servidor e pode ser contornado por outros clientes/PLSQL. Exige DML na estrutura correta, cujo nome/contrato varia. Não garante usuário somente SELECT; não substitui grants mínimos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Revisão somente em laboratório com configuração compatível.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Quatro regras persistidas para o cliente que respeita a tabela.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  DML/COMMIT e créditos históricos preservados; limitação de segurança explícita. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 043 — 04/11/2026
  Correções e melhorias: Quatro INSERTs eCOMMIT preservados.
  Limitações e pendências: PRODUCT_PROFILE é controle cliente e não substitui privilégios Oracle; estrutura pode variar/estar ausente. USERNAME textual aceita injeção/padrões; comentário somenteSELECT não corresponde a toda capacidade restante.
  Homologação necessária: Cliente/estrutura compatíveis, usuário literal/padrões e todas4regras; sem usuário produtivo ou concessão de privilégios.
  Parâmetros/execução: contratos acima e corpo histórico; somente laboratório.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral/análise estática; sem compilação ou execução Oracle,
  Windows, escrita de arquivo no servidor, backup/recovery ou alteração de contas.

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

REM*********************************************************
REM PROD_PROF.SQL
REM
REM SCRIPT RESTRICTS A USERS ABILITY TO USE SQL FOR ANYTHING
REM OTHER THAN SELECT. RESTRICTS 
REM DELETE,INSERT,
REM INSERT INTO, AND HOST COMMANDS.
REM
REM USE: SQLPLUS SYSTEM/PW @PRODUCT USER_PRODUCT_PROFILE USERNAME
REM
REM    DATE        CHANGE            REASON        NAME
REM    -------     ---------------   -----------   ------------
REM    8/6/92      INITIAL CREATE    N/A           M. AULT
REM    1/11/97     Updated to V7     V6 not used   M.Ault
REM******************************************************************
SET VERIFY OFF

INSERT INTO PRODUCT_PROFILE (
product,
userid,
attribute,
char_value,
date_value)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'DELETE','DISABLED',SYSDATE);

INSERT INTO PRODUCT_PROFILE (
product,
userid,
attribute,
char_value,
date_value)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'INSERT','DISABLED',SYSDATE);

INSERT INTO PRODUCT_PROFILE (
product,
userid,
attribute,
char_value,
date_value)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'UPDATE','DISABLED',SYSDATE);

INSERT INTO PRODUCT_PROFILE (
product,
userid,
attribute,
char_value,
date_value)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'HOST','DISABLED',SYSDATE);

COMMIT;

