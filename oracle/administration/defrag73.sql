/*
===============================================================================
SCRIPT: defrag73.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/defrag73.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Executar variante de coalescência manual com relatório FREE2_SPC.

FUNCIONAMENTO DETALHADO
  Relatório inicial, gera ALTER TABLESPACE COALESCE por TABLESPACES/FREE_SPACE com pieces>1, executa DEF.SQL e HOST DEL; relatório final.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas conforme limitações individuais.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLESPACES, FREE_SPACE, FREE2_SPC.SQL, SQL*Plus HOST

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  ALTER TABLESPACE confirma DDL; múltiplas linhas por datafile podem gerar comando repetido por tablespace. Não filtra SYSTEM/TEMP e não é defrag físico ou recomendação ASSM/LMT. Saída/arquivos podem colidir com scripts existentes.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório DMT/Windows e helpers revisados.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Coalescências executadas e arquivo temporário apagado.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos de criação, staging, autenticação, sessão
  ou código gerado descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código e crédito M. Ault 1998 preservados; variante não é duplicata de DEFRG73 pela consulta/helper e ausência de COMMIT textual gerado. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 043 — 04/11/2026
  Correções e melhorias: DISTINCT evita comandos repetidos por arquivo; nome de tablespace citado com escape.
  Limitações e pendências: Ainda executa DEF.SQL automaticamente e HOST DEL remove arquivo; não filtra DMT/ONLINE/SYSTEM/TEMP. Helper FREE2_SPC e contrato FREE_SPACE devem ser revisados.
  Homologação necessária: Dois arquivos no mesmo tablespace, nomes com aspas, helpers ausentes e erro parcial; apenas simular saída nesta revisão.
  Parâmetros/execução: contratos acima e corpo histórico; somente laboratório.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral/análise estática; sem compilação ou execução Oracle,
  Windows, escrita de arquivo no servidor, backup/recovery ou alteração de contas.

AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de qualquer utilização em produção. Sua execução é de responsabilidade do profissional responsável pelo ambiente. Os mantenedores deste repositório não se responsabilizam por indisponibilidade, perda de dados, alterações indevidas ou outros impactos decorrentes de sua utilização.

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
rem NAME: defrag73.sql
rem FUNCTION: Uses the "alter tablespace" command to manually coalesce
rem FUNCTION: any tablespace with greater than 1 fragment. You
rem FUNCTION: may wish to alter to exclude the temporary tablespace.
rem FUNCTION: The procedure uses the FREE_SPACE view which is a 
rem FUNCTION: summarized version of the DBA_FREE_SPACE view.
rem FUNCTION: This procedure must be run from SYS user id.
rem
rem HISTORY:
rem WHO		WHAT		WHEN
rem Mike Ault	Created		6/17/98
rem
@free2_spc
clear columns
clear computes
ttitle off
set heading off feedback off echo off termout off
spool def.sql
select 
	distinct 'alter tablespace "'||replace(tablespace_name,'"','""')||'" coalesce;'
from
	dba_tablespaces,
	free_space
where
	tablespace=tablespace_name and pieces>1;
spool off
@def.sql
host del def.sql
set heading on feedback on termout on
@free2_spc

