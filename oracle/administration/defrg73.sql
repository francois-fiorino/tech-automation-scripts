/*
===============================================================================
SCRIPT: defrg73.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/DEFRG73.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Executar coalescência manual legada para tablespaces com múltiplas peças livres.

FUNCIONAMENTO DETALHADO
  Chama FREE_SPC, gera DEF.SQL com ALTER TABLESPACE COALESCE/COMMIT, executa @ e apaga arquivo com HOST DEL; repete relatório.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e privilégios administrativos conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  FREE_SPACE (customizada), FREE_SPC.SQL, SQL*Plus HOST/START

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  ALTER TABLESPACE/COMMIT são administrativos e podem confirmar transação. Coalesce de DMT não é defrag de filesystem e não é recomendação de LMT/ASSM. Nomes não filtram SYSTEM/TEMP; arquivo DEF.SQL pode colidir.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório Windows com DMT e helpers revisados.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  DDL executada, relatórios antes/depois e arquivo intermediário removido.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: pode gerar ou executar DDL/DML, expor hashes/segredos
  do banco consultado ou alterar sessão conforme descrito acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Fluxo completo preservado; sem executar coalescência ou traduzir parâmetros antigos. 
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
rem NAME: defrg73.sql
rem FUNCTION: Uses the "set events" command to manually coalesce
rem FUNCTION: any tablespace with greater than 1 fragment. You
rem FUNCTION: may wish to alter to exclude the temporary tablespace.
rem FUNCTION: The procedure uses the FREE_SPACE view which is a 
rem FUNCTION: summarized version of the DBA_FREE_SPACE view.
rem FUNCTION: This procedure must be run from SYS user id.
rem
rem HISTORY:
rem WHO		WHAT		WHEN
rem Mike Ault	Created		1/4/96
rem
@free_spc
clear columns
clear computes
define cr='chr(10)'
ttitle off
set heading off feedback off echo off termout off
spool def.sql
select 
	'alter tablespace '||tablespace||' coalesce;'||&&cr||
	'commit;'
from
	free_space
where
	pieces>1;
spool off
@def.sql
host del def.sql
set heading on feedback on termout on echo off
@free_spc
ttitle off
