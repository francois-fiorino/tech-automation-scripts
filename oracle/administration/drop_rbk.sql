/*
===============================================================================
SCRIPT: drop_rbk.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/drop_rbk.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exemplificar remoção de dez rollback segments nomeados.

FUNCIONAMENTO DETALHADO
  Executa DROP ROLLBACK SEGMENT para RB6..RB9 e RB16..RB21.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme LIMITAÇÕES; roles não
  bastam para compilar dependências de rotinas armazenadas.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  Rollback segments literais RB6/RB7/RB8/RB9/RB16/RB17/RB18/RB19/RB20/RB21

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DROP ROLLBACK SEGMENT administrativo confirma DDL; segmentos em uso não devem ser removidos. Conceito de undo manual legado, não recomendação para AUM. Operações podem ter sucesso parcial.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Revisão somente; não executar em ambiente com dados/transações reais.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Objetos removidos ou erros conforme estado/privilégios.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados ou sessão descritos
  acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Todos os comandos e aviso educacional histórico preservados. 
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
REM PURPOSE:
REM    Syntax for dropping rollback segments. Insert correct name for each segment.
REM ------------------------------------------------------------------------ 
REM DISCLAIMER: 
REM    This script is provided for educational purposes only.
REM    The script has been tested and appears to work as intended. 
REM    You should always run new scripts on a test instance initially.
REM ------------------------------------------------------------------------- 
REM Script begins after this line
drop rollback segment RB6;
drop rollback segment RB7;
drop rollback segment RB8;
drop rollback segment RB9;
drop rollback segment RB16;
drop rollback segment RB17;
drop rollback segment RB18;
drop rollback segment RB19;
drop rollback segment RB20;
drop rollback segment RB21;
