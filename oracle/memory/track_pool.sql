/*
===============================================================================
SCRIPT: track_pool.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/track_pool.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar medidas customizadas de uso/disponibilidade do shared pool após uma data.

FUNCIONAMENTO DETALHADO
  Lê POOL_TRACK com MEAS_DATE maior que REP_DATE e retorna SP_USED, SP_AVAIL e FULL_PCT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  POOL_TRACK (objeto customizado)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  POOL_TRACK não é view padrão; exige estrutura e coletor compatíveis. Resultado não comprova memória livre atual; coluna formatada não estabelece ordem cronológica.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE rep_date = 2026-11-01
  @track_pool.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  MEAS_DATE, SP_USED, SP_AVAIL e FULL_PCT; unidades dependem do coletor customizado.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  REP_DATE convertido explicitamente com máscara YYYY-MM-DD em vez de conversão implícita dependente de NLS_DATE_FORMAT. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col meas_date format a15
ttitle 'Pool Track'
spool track_pool.lst
select
to_char(meas_date,'dd-mon-yy hh24:mi') meas_date,
sp_used,
sp_avail,
full_pct
from pool_track
where meas_date > to_date('&rep_date','YYYY-MM-DD')
/
spool off
