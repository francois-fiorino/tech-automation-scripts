/*
===============================================================================
SCRIPT: forced_reads_writes.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_grid_scripts/forced_reads_writes.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Resumir forced reads/writes por objeto, tipo e instância em view legada.

FUNCIONAMENTO DETALHADO
  Consulta GV$CACHE_TRANSFER, exclui OWNER#=0 e agrupa por INST_ID, NAME e KIND; soma FORCED_READS/FORCED_WRITES.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$CACHE_TRANSFER

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  View e métricas de Oracle Parallel Server/RAC legado podem estar ausentes nas versões atuais. OWNER não está na chave de agrupamento: homônimos de schemas diferentes podem ser somados.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @forced_reads_writes.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Instance, NAME, KIND, Forced Reads e Forced Writes.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada; não substituída por métricas gc com semântica distinta. 
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

-- forced_reads_writes.sql

col instance format 99999999
col name format a20
col kind format a10
set lines 80 pages 55
Select
INST_ID "Instance",
NAME,
KIND,
sum(FORCED_READS) "Forced Reads",
sum(FORCED_WRITES) "Forced Writes"
FROM GV$CACHE_TRANSFER
WHERE owner#!=0
GROUP BY INST_ID,NAME,KIND
ORDER BY 1,4 desc,2
/