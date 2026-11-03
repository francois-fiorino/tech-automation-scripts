/*
===============================================================================
SCRIPT: resource_limit.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/resource_limit.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir utilização atual, máxima e limites dos recursos da instância.

FUNCIONAMENTO DETALHADO
  Consulta todas as colunas de V$RESOURCE_LIMIT; configura apresentação e grava relatório local.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$RESOURCE_LIMIT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  MAX_UTILIZATION é pico acumulado, não consumo atual; LIMIT_VALUE pode ser UNLIMITED. View local e saída SELECT * dependem da versão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @resource_limit.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  RESOURCE_NAME, CURRENT_UTILIZATION, MAX_UTILIZATION, INITIAL_ALLOCATION e LIMIT_VALUE, mais colunas da versão.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Corrigido nome de coluna SQL*Plus MAX_UTILITIZATION para MAX_UTILIZATION. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col resource_name format a27 
col current_utilization format 9999 heading curr
col max_utilization format 9999 heading max
ttitle 'Resource Limits'
spool resource_limit.lst
select * from v$resource_limit
/
spool off
