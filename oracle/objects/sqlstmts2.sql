/*
===============================================================================
SCRIPT: sqlstmts2.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/sqlstmts2.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exportar linhas de texto de um identificador em tabela customizada STATETAB.

FUNCIONAMENTO DETALHADO
  Recebe argumento posicional &1, gera nome sql_ com cinco primeiros caracteres, abre spool e consulta STATEID/text de STATETAB para o ID indicado.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  STATETAB (objeto customizado), DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não é view padrão; requer colunas STATEID/TEXT. Usar ID controlado sem aspas, espaços ou separadores de caminho; substituição também compõe filename. IDs com os mesmos cinco caracteres colidem e spool pode sobrescrever saída. LONG/linhas podem truncar conteúdo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @sqlstmts2.sql ESTADO1
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  STATEID, literal ^ e TEXT; saída de relatório, não CSV ou arquivo SQL garantidamente executável.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Acrescentado SPOOL OFF ausente para não capturar comandos/saída posteriores da sessão. 
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
set pagesize 0
set linesize 2000
SET LONG 5000
set echo off
set feedback off
COL SPOOL_FILE NEW_VALUE SPOOLIT NOPRINT
SET VERIFY OFF
SELECT 'sql_'||SUBSTR('&1',1,5) SPOOL_FILE FROM DUAL;

SPOOL &SPOOLIT

select STATEID,'^',text from STATETAB where STATEID='&1';

REM exit;
spool off
