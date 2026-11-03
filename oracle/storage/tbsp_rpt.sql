/*
===============================================================================
SCRIPT: tbsp_rpt.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _tablespace_scripts/tbsp_rpt.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar atributos históricos de armazenamento padrão dos tablespaces.

FUNCIONAMENTO DETALHADO
  Seleciona INITIAL_EXTENT, NEXT_EXTENT, MIN_EXTENTS, MAX_EXTENTS e PCT_INCREASE em DBA_TABLESPACES.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLESPACES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Parâmetros são históricos e podem ser nulos ou não controlar efetivamente alocação em tablespaces gerenciados localmente. Não representam uso atual ou capacidade de disco.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @tbsp_rpt.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  TABLESPACE e atributos INIT/NEXT/MIN/MAX/PCT_INC; tamanhos de extent em bytes quando disponíveis.

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
COL TABLESPACE FORMAT A20
ttitle 'Tablespace Parameters'
set lines 132
spool tbsp_rpt.lst
select 
tablespace_NAME TABLESPACE, 
	INITIAL_EXTENT INIT, 
	NEXT_EXTENT NEXT,
	MIN_EXTENTS MIN, 
	MAX_EXTENTS MAX, 
	PCT_INCREASE PCT_INC 
FROM DBA_TABLESPACES
/
spool off
