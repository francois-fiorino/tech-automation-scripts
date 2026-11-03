/*
===============================================================================
SCRIPT: rbk_views.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/rbk_views.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar views requeridas por relatórios RBK1/RBK2 de undo manual.

FUNCIONAMENTO DETALHADO
  Define ROLLBACK1 com estatísticas de shrink e ROLLBACK2 com uso/esperas via outer joins por USN.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme LIMITAÇÕES; roles não
  bastam para compilar dependências de rotinas armazenadas.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$ROLLNAME, V$ROLLSTAT, DBA_ROLLBACK_SEGS; ROLLBACK1/ROLLBACK2

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE VIEW/SELECT direto. Views antigas de undo/rollback; valores podem ser NULL para offline. CREATE OR REPLACE invalida dependentes e confirma DDL.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @rbk_views.sql; revisar grants diretos antes.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Duas views criadas/substituídas, incluindo segmentos sem estatística atual.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados ou sessão descritos
  acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  SQL preservado; comentário funcional de RBKVW incorporado para consolidar cópia equivalente sem perder aviso histórico. 
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

REM FUNCTION: create views required for rbk1 and rbk2 reports (também em RBKVW.SQL).
/*  */
REM
REM ------------------------------------------------------------------------ 
REM DISCLAIMER: 
REM    This script is provided for educational purposes only.
REM    The script has been tested and appears to work as intended. 
REM    You should always run new scripts on a test instance initially.
REM ------------------------------------------------------------------------- 
REM Script begins after this line
CREATE OR REPLACE VIEW ROLLBACK1 AS
SELECT 
	d.segment_NAME,EXTENTS,
	OPTSIZE,SHRINKS,
	AVESHRINK,AVEACTIVE,
	d.STATUS
FROM 
V$ROLLNAME N, 
V$ROLLSTAT S,
dba_rollback_segs d
WHERE   
d.segment_id=n.usn(+) 
and d.segment_id=S.USN(+)
;

CREATE OR REPLACE VIEW ROLLBACK2 AS SELECT
d.segment_NAME,   EXTENTS,        XACTS,
HWMSIZE,        RSSIZE, WAITS,
WRAPS,  EXTENDS
FROM    
V$ROLLNAME N,
V$ROLLSTAT S,
dba_rollback_segs d
WHERE
d.segment_id=n.usn(+) 
and d.segment_id=S.USN(+);
