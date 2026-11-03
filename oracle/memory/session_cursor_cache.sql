/*
===============================================================================
SCRIPT: session_cursor_cache.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/session_cursor_cache.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar heurística histórica de restrição do cache de cursores preservando settings do cliente.

FUNCIONAMENTO DETALHADO
  Dois ramos calculam máximos de estatísticas de sessão e comparam com parâmetros; STORE SET salva configurações antes da consulta e @ restaura ao final.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$STATNAME, SYS.V_$SESSTAT, SYS.V_$PARAMETER, SQL*Plus STORE SET

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Heurística soma contadores potencialmente sobrepostos; recomendações históricas do comentário exigem análise atual. STORE SET grava session_cursor_cache_settings.sql local: exige diretório gravável, sobrescreve arquivo e não deve concorrer no mesmo diretório.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @session_cursor_cache.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Duas linhas de parâmetro/valor/usage, com limites iguais aos de session_cached_cursors.sql.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Helpers save/restore ausentes na coleção substituídos por STORE SET e restauração nativa; NULLIF no segundo divisor. Créditos Steve Adams mantidos. 
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
-------------------------------------------------------------------------------
--
-- Script:      session_cursor_cache.sql
-- Purpose:     to check if the session cursor cache is constrained 
--
--  :      
-- Author:      Steve Adams
--
-- Description: If 'session cursor cache count' = session_cached_cursors, then
--              session_cached_cursors should be increased.
--              If 'opened cursors current' + 'session cursor cache count' =
--              open_cursors, then open_cursors should be increased.
--
-------------------------------------------------------------------------------
STORE SET session_cursor_cache_settings.sql REPLACE

select
  'session_cached_cursors'  parameter,
  lpad(value, 5)  value,
  decode(value, 0, '  n/a', to_char(100 * used / nullif(value,0), '990') || '%')  usage
from
  ( select
      max(s.value)  used
    from
      sys.v_$statname  n,
      sys.v_$sesstat  s
    where
      n.name = 'session cursor cache count' and
      s.statistic# = n.statistic#
  ),
  ( select
      value
    from
      sys.v_$parameter
    where
      name = 'session_cached_cursors'
  )
union all
select
  'open_cursors',
  lpad(value, 5),
  to_char(100 * used / nullif(value,0),  '990') || '%'
from
  ( select
      max(sum(s.value))  used
    from
      sys.v_$statname  n,
      sys.v_$sesstat  s
    where
      n.name in ('opened cursors current', 'session cursor cache count') and
      s.statistic# = n.statistic#
    group by
      s.sid
  ),
  ( select
      value
    from
      sys.v_$parameter
    where
      name = 'open_cursors'
  )
/

@session_cursor_cache_settings.sql
