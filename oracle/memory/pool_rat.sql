/*
===============================================================================
SCRIPT: pool_rat.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/Pool_rat.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Calcular proporção de hashes e endereços distintos entre entradas de V$SQLAREA.

FUNCIONAMENTO DETALHADO
  Divide COUNT(DISTINCT HASH_VALUE) por COUNT(HASH_VALUE) e COUNT(DISTINCT ADDRESS) por COUNT(ADDRESS), multiplicando por 100.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SQLAREA

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Unicidade de hash/endereço não mede diretamente reutilização, hard parses ou eficiência do shared pool. Hashes podem colidir; V$SQLAREA resume cursores.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @pool_rat.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  U_HASH_RATIO e U_ADDRESS_RATIO em porcentagem.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  COUNT dos denominadores protegido por NULLIF para cache vazio. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Wrapper de título ausente substituído por TTITLE local.
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
rem Report on the ratios of unique hash values and
rem unique address values to all values for SQL areas
rem
column u_hash_ratio format 999.999 heading "Unique Hash Ratio"
column u_address_ratio format 999.999 heading "Unique Address Ratio"
ttitle "Unique Hash an Address Ratios"
spool pool_rat.lst
select (count(distinct(hash_value))/nullif(count(hash_value),0))*100 u_hash_ratio,
	(count(distinct(address))/nullif(count(address),0))*100 u_address_ratio from v$sqlarea
/
spool off

