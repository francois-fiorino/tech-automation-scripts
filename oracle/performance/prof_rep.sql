/*
===============================================================================
SCRIPT: prof_rep.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / misc_scripts/prof_rep.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar tempos de linhas instrumentadas pelo DBMS_PROFILER.

FUNCIONAMENTO DETALHADO
  Lê PLSQL_PROFILER_DATA com TOTAL_TIME>0 e divide tempos em nanossegundos por 1e9.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  PLSQL_PROFILER_DATA (tabela criada para DBMS_PROFILER)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Exige tabelas de profiler e coleta prévia; não inicia coleta. Sem filtro RUNID, mistura execuções disponíveis. Resolução do relógio limita linhas muito rápidas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @prof_rep.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  RUNID, UNIT_NUMBER, LINE#, TOTAL_OCCUR, TOTAL/MIN/MAX em segundos.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Divisor 1e9 conferido e preservado: aqui as unidades são nanossegundos, ao contrário de V$SQLAREA. 
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
set lines 132 pages 1000
select runid,unit_number,line#,total_occur,
total_time/1000000000 total ,
min_time/1000000000 min, 
max_time/1000000000 max
from plsql_profiler_data where total_time>0
/
