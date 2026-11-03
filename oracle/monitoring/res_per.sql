/*
===============================================================================
SCRIPT: res_per.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / misc_scripts/res_per.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Calcular utilização atual/pico relativa a limites finitos de recursos.

FUNCIONAMENTO DETALHADO
  Consulta V$RESOURCE_LIMIT com contadores positivos e converte limite numérico dentro de CASE protegido.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$RESOURCE_LIMIT, REGEXP_LIKE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Oracle 10g+ pela expressão regular. Limite é configuração, não capacidade física de CPU/storage. Filtros excluem recursos com uso atual ou pico zero e UNLIMITED.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @res_per.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  RESOURCE_NAME, MAX_LIMIT e CUR_LIMIT em porcentagem; NULL para limites não numéricos/zero.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  CASE valida dígitos antes de TO_NUMBER e NULLIF evita zero; filtro textual sozinho não garantia ordem de avaliação da conversão. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Wrapper externo substituído por TTITLE local.
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
column max_limit format 999.99 heading "Max Percent|of Limit"
column cur_limit format 999.99 heading "Current Percent|of Limit"
column resource_name heading "Resource"
ttitle "Resource Utilization"
spool res_per.lst
select 
   resource_name , 
   100*max_utilization/case when regexp_like(trim(limit_value),'^[0-9]+$') then nullif(to_number(trim(limit_value)),0) end max_limit, 
   100*current_utilization/case when regexp_like(trim(limit_value),'^[0-9]+$') then nullif(to_number(trim(limit_value)),0) end cur_limit
 from v$resource_limit
where limit_value not in ('UNLIMITED','0') and max_utilization > 0 and current_utilization>0;
spool off
ttitle off

