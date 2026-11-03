/*
===============================================================================
SCRIPT: packages_wo_bodies.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/packages_wo_bodies.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Identificar packages cujo corpo não aparece no dicionário do mesmo proprietário.

FUNCIONAMENTO DETALHADO
  Calcula MINUS entre pares OWNER/OBJECT_NAME de PACKAGE e PACKAGE BODY.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_OBJECTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Um package pode conter apenas declarações que dispensam body. Ausência não implica erro; confirmar design e edição corrente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @packages_wo_bodies.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OWNER e OBJECT_NAME dos packages sem body no mesmo schema.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  OWNER incluído nos dois lados do MINUS e na saída para impedir que body homônimo de outro schema oculte package. 
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
col object_name format a25 heading "Packages w/o Body"
select owner, object_name from dba_objects
 where object_type = 'PACKAGE'
MINUS
select owner, object_name from dba_objects
 where object_type = 'PACKAGE BODY'
/
