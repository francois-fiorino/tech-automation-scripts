/*
===============================================================================
SCRIPT: chaining2.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _table_scripts/chaining2.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar heurística histórica de migração e sugerir parâmetros de espaço a partir de estatísticas.

FUNCIONAMENTO DETALHADO
  Consulta SYS.TAB$/OBJ$/USER$/COL$ e X_$KVIS, exclui tipos LONG/linhas máximas maiores que bloco, calcula CHNCNT/ROWCNT e sugestões PCTFREE/PCTUSED/MAXROWS.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.TAB$, SYS.COL$, SYS.OBJ$, SYS.USER$, SYS.X_$KVIS, SQL*Plus STORE SET

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Alvo 7.3+ original, sem homologação de layout interno moderno. Estatísticas antigas tornam resultado inválido; CHNCNT não separa migração de chaining com certeza. Fórmula de overhead 66/71/24 é legada, PCTUSED não governa ASSM e sugestões não são DDL autorizado. Varreduras internas podem custar recursos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @chaining2.sql
  -- Diretório gravável e sem arquivo chaining2_settings.sql valioso.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tabela, contagem estatística CHNCNT, porcentagem e sugestões históricas de espaço.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Helpers save/restore ausentes substituídos por STORE SET e restauração local, preservando settings; arquivo local sobrescrito não deve concorrer entre sessões. Fórmulas e crédito Steve Adams integralmente mantidos. 
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
-- Script: row_migration.sql
-- Purpose: to find the degree of row migration in analyzed tables
-- For: 7.3 and higher
--
--  :    
-- Author: Steve Adams
--
-- Note: ! THIS SCRIPT IS ONLY AS GOOD AS YOUR OPTIMIZER STATISTICS !
--
-- Description: This reports the degree of row migration as a percentage of
-- the number of rows. Tables with LONGs or possible row lengths
-- greater than the block size are ignored, as it is not easy
-- to distinguish row migration from chaining for such tables.
--
-- The new PCTFREE is calculated as the free space left by one
-- less than the number of average rows that can fit in a block.
--
-- The new PCTUSED allows for a little more than one row between
-- PCTFREE and PCTUSED - this may not be enough for tables with
-- very high insert and delete activity.
--
-------------------------------------------------------------------------------
STORE SET chaining2_settings.sql REPLACE

column table_name format a37
column mrows format 9999999 heading "MIGRATED|ROWS"
column migration heading "DEGREE OF|MIGRATION"
column new_free format 99 heading "SUGGEST|PCTFREE"
column new_used format 99 heading "SUGGEST|PCTUSED"
column minimize format 999999 heading "SUGGEST|MAXROWS"

select
u.name ||'.'|| o.name table_name,
t.chncnt mrows,
to_char(100 * t.chncnt / t.rowcnt, '9999.00') || '%' migration,
1 + greatest(t.pctfree$,ceil(( 100 * ( p.value - 66 - t.initrans * 24 -
greatest(floor((p.value - 66 - t.initrans * 24) / greatest(t.avgrln + 2, 11)) - 1,1) * greatest(t.avgrln + 2, 11))/(p.value - 66 - t.initrans * 24)))) new_free,
98 - greatest(
t.pctfree$,
ceil(
( 100 * ( p.value - 66 - t.initrans * 24 -
greatest(
floor(
(p.value - 66 - t.initrans * 24) / greatest(t.avgrln + 2, 11)
) - 2,1) * greatest(t.avgrln + 2, 11))/(p.value - 66 - t.initrans * 24)))) new_used,
floor((p.value - 66 - t.initrans * 24) / greatest(t.avgrln + 2, 11)) minimize
from
sys.tab$ t,
( select
obj#,
sum(length) max_row
from
sys.col$
group by
obj#
having
min(length) > 0 -- don't worry about tables with LONGs
) c,
( select
kvisval value
from
sys.x_$kvis
where
kvistag = 'kcbbkl'
) p,
sys.obj$ o,
sys.user$ u
where
t.tab# is null and
t.chncnt > 0 and
t.rowcnt > 0 and
c.obj# = t.obj# and
c.max_row < p.value - (71 + t.initrans * 24) and
o.obj# = t.obj# and
o.owner# != 0 and
u.user# = o.owner#
order by
2 desc
/

@chaining2_settings.sql
