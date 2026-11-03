/*
===============================================================================
SCRIPT: buff_adv.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/buff_adv.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar estimativas de leituras físicas para tamanhos alternativos do buffer cache.

FUNCIONAMENTO DETALHADO
  Lista ID, NAME, BLOCK_SIZE, ADVICE_STATUS, SIZE_FOR_ESTIMATE, SIZE_FACTOR e ESTD_PHYSICAL_READS em V$DB_CACHE_ADVICE.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$DB_CACHE_ADVICE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Exige advice coletado/ativo para dados relevantes. ESTD_PHYSICAL_READS não é número de leituras economizadas; comparar cenários para estimar diferença.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @buff_adv.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tamanhos estimados em MB conforme view, fator e quantidade estimada de leituras físicas.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Heading Physical Reads Saved corrigido para Estimated Phys Reads; cálculo original preservado. 
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
col id format 999 heading 'ID'
col name format a10 heading 'Name'
col block_size format 9,999,999 heading 'Blk.Size'
col advice_status heading 'Adv'
col size_for_estimate heading 'Size in|Meg' format 9,999,999
col estd_physical_reads heading 'Estimated Phys|Reads' format 999,999,999,999
set lines 80 pages 47
ttitle 'Buffer Pool Advisor'
spool buffer_adv
select id,name,block_size,advice_status,size_for_estimate, size_factor "Factor",estd_physical_reads from v$db_cache_advice
/
spool off
clear columns
ttitle off
