/*
===============================================================================
SCRIPT: get_views.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/get_views.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Encontrar views com coluna DESCRIPTION e dependência nas dimensões configuradas.

FUNCIONAMENTO DETALHADO
  Relaciona DBA_TAB_COLUMNS a DBA_DEPENDENCIES, filtra V_% e %DESCRIPTION e tabelas DIMENSION.DIM_CUSTOMER/DIM_PRODUCT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TAB_COLUMNS, DBA_DEPENDENCIES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Filtros são específicos do exemplo. Underscore em V_% é wildcard; ORDER BY prefixo literal desc não significa ordenação descendente. Dependência indireta/dinâmica pode não aparecer.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @get_views.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner e nome distintos das views selecionadas.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta completa preservada e filtros explicitados. 
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
select distinct a.owner,a.table_name from dba_tab_columns a, dba_dependencies b where 
a.table_name like 'V_%'
and a.column_name like '%DESCRIPTION' and a.owner not in ('SYS','SYSTEM')
and a.owner=b.owner and a.table_name=b.name
and b.referenced_type='TABLE'
and b.type='VIEW'
and b.referenced_owner='DIMENSION' and b.referenced_name in ('DIM_CUSTOMER','DIM_PRODUCT')
order by 'desc '||a.owner||'.'||a.table_name
/
