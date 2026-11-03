/*
===============================================================================
SCRIPT: inmemory_segments.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/inmemory_segments.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar segmentos populados no In-Memory Column Store por instância.

FUNCIONAMENTO DETALHADO
  Consulta GV$IM_SEGMENTS com proprietário, segmento, partição, BYTES, estado de população e modo de distribuição.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$IM_SEGMENTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Oracle 12.1.0.2+ com capacidade In-Memory aplicável. BYTES é volume de dados em disco representáveis, não INMEMORY_SIZE. Segmentos habilitados mas não populados podem não aparecer. Confirmar licenciamento/limites da edição e versão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @inmemory_segments.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  INST_ID, OWNER, SEGMENT_NAME, PARTITION_NAME, BYTES, POPULATE_STATUS e INMEMORY_DISTRIBUTE.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada. 
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

select
   inst_id,
   owner,
   segment_name,
   partition_name,
   bytes,
   populate_status,
   inmemory_distribute
from
   gv$im_segments;