/*
===============================================================================
SCRIPT: long_ops.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/long_ops.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar operações longas com estimativa de duração restante superior a um segundo.

FUNCIONAMENTO DETALHADO
  Consulta V$SESSION_LONGOPS, filtra TIME_REMAINING>1 e ordena esse valor crescente. Formata início com hora de 24 horas.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION_LONGOPS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Nem toda operação é instrumentada; estimativa pode oscilar. Não mede progresso de todas as sessões, nem fornece SID ou SERIAL#.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @long_ops.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OPNAME, TARGET, START_TIME, TIME_REMAINING em segundos e USERNAME.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Adicionado terminador SQL ausente para execução por @arquivo. 
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
col username format a10
col opname format a10
col target format a20
select opname,target,
to_char(start_time,'dd-mon-yy hh24:mi') start_time,
time_remaining,username
from v$session_longops where time_remaining>1 order by time_remaining;
