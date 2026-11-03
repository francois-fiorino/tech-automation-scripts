/*
===============================================================================
SCRIPT: pga_advice.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/pga_advice.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar estimativas de desempenho para alvos alternativos de PGA.

FUNCIONAMENTO DETALHADO
  Lê V$PGA_TARGET_ADVICE, converte PGA_TARGET_FOR_ESTIMATE de bytes a MiB arredondados e exibe hit estimado e overallocations.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$PGA_TARGET_ADVICE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Advice depende da carga observada e configuração de PGA/advisor. Não altera PGA_AGGREGATE_TARGET; estimativas não garantem efeito de mudança.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @pga_advice.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  TARGET_MB, CACHE_HIT_PERC e ESTD_OVERALLOC_COUNT para cenários do modelo.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
ttitle 'PGA Target Advice Report'
spool pga_advice.lst
SELECT round(PGA_TARGET_FOR_ESTIMATE/1024/1024) target_mb,        ESTD_PGA_CACHE_HIT_PERCENTAGE cache_hit_perc,        ESTD_OVERALLOC_COUNT FROM   v$pga_target_advice
/
spool off
