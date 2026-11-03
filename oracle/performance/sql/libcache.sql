/*
===============================================================================
SCRIPT: libcache.sql
CATEGORIA: Oracle / performance/sql
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/LIBCACHE.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar atividade acumulada de cada namespace do library cache.

FUNCIONAMENTO DETALHADO
  Consulta LIBRARYCACHE e apresenta GET/PIN hit ratios multiplicados por 100, reloads e invalidations.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$LIBRARYCACHE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Contadores acumulados não representam intervalo nem latência; hit ratio alto não exclui parse excessivo ou contenção. Máscaras numéricas podem estourar.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @libcache.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Namespace, gets/pins, porcentagens e contadores.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta preservada; OUTPUT agora arquivo local. Título convertido em TTITLE local.
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
rem
rem Title: libcache.sql
rem
rem FUNCTION: Generate a library cache report 
rem Mike Ault Burleson Consulting
rem
column namespace                        heading "Library Object"
column gets             format 99,999,999 heading "Gets"
column gethitratio      format 999.99   heading "Get Hit%"
column pins             format 999,999,999  heading "Pins"
column pinhitratio      format 999.99   heading "Pin Hit%"
column reloads          format 999,999   heading "Reloads"
column invalidations    format 999,999   heading  "Invalid"
column db format a10
ttitle "Library Caches Report"
set pages 58 lines 85 
define output = libcache.lst
spool &output
select 
	namespace,
	gets,
	gethitratio*100 gethitratio,
	pins,
	pinhitratio*100 pinhitratio,
	RELOADS,
	INVALIDATIONS 
from 
	v$librarycache
/
spool off
pause Press enter to continue
set pages 22 lines 80
ttitle off
undef output
