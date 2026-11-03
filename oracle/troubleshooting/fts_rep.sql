/*
===============================================================================
SCRIPT: fts_rep.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/fts_rep.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Associar sessões cujo último/atual evento é db file scattered read a extents de segmentos.

FUNCIONAMENTO DETALHADO
  Relaciona P1 a FILE#, P2 à faixa de blocos do extent e retorna SID, OWNER e SEGMENT_NAME distintos.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$SESSION_WAIT, SYS.V_$DATAFILE, SYS.DBA_EXTENTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não filtra STATE=WAITING e evento não comprova full table scan; leituras diretas podem usar eventos diferentes. Join por ranges pode ser custoso em muitos extents; validar CON_ID no container apropriado.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @fts_rep.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Sessão e segmento que contém o bloco inicial referenciado no evento.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Limite superior corrigido de BLOCK_ID+BLOCKS para BLOCK_ID+BLOCKS-1 para não atribuir bloco do extent seguinte. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem fts_rep.sql
-- comment: SQL Full table scan report
rem MRA
rem
ttitle 'Full Table Scans'
spool fts_rep.lst
SELECT DISTINCT A.SID,
C.OWNER,
C.SEGMENT_NAME
FROM SYS.V_$SESSION_WAIT A,
SYS.V_$DATAFILE B,
SYS.DBA_EXTENTS C
WHERE A.P1 = B.FILE# AND
B.FILE# = C.FILE_ID AND
A.P2 BETWEEN C.BLOCK_ID AND 
(C.BLOCK_ID + C.BLOCKS - 1) AND
A.EVENT = 'db file scattered read';
spool off
ttitle off
