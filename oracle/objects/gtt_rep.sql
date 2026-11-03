/*
===============================================================================
SCRIPT: gtt_rep.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/gtt_rep.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar tabelas marcadas como temporárias no dicionário.

FUNCIONAMENTO DETALHADO
  Consulta DBA_TABLES com TEMPORARY=Y; mostra OWNER, TABLE_NAME e TEMPORARY, sem ler dados das tabelas.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não mostra conteúdo por sessão nem comprova uso de TEMP. Não pressupor cobertura de private temporary tables; verificar versão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @gtt_rep.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Schema, nome e indicador Y para tabelas temporárias visíveis em DBA_TABLES.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  SQL original preservado. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col owner format a15 heading 'Temp Table|Owner'
col table_name heading 'Temp Table Name'
col temporary format a5 heading 'Temp?'
ttitle 'Global Temporary Tables'
spool gtt_rep.lst
select owner,table_name,temporary from dba_tables where temporary='Y'
/
spool off
clear col
ttitle off
