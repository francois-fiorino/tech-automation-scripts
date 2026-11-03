/*
===============================================================================
SCRIPT: grd_resource_utilizations.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/grd_resource_utilizations.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir utilização atual e pico dos recursos GCS/GES da instância local.

FUNCIONAMENTO DETALHADO
  Filtra V$RESOURCE_LIMIT por prefixos gcs ou ges e mostra RESOURCE_NAME, CURRENT_UTILIZATION e MAX_UTILIZATION.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$RESOURCE_LIMIT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Consulta V$ local, não todos os nós. Nem todo uso de GRD aparece como recurso contabilizado aqui. Não mostra LIMIT_VALUE e não mede memória em bytes.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @grd_resource_utilizations.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Nome do recurso, uso atual e máximo desde a acumulação dos contadores.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada; CR isolados normalizados. 
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
   resource_name,
   current_utilization,
   max_utilization
from
   v$resource_limit
where
   resource_name like 'gcs%'
   or
   resource_name like 'ges%'
order by
   resource_name;
