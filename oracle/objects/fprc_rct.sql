/*
===============================================================================
SCRIPT: fprc_rct.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/FPRC_RCT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar texto de recriação de módulo PL/SQL selecionado por três argumentos.

FUNCIONAMENTO DETALHADO
  Imprime CREATE OR REPLACE antes da linha 1, demais linhas em ordem e / final, a partir de SOURCE/OBJECTS.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_SOURCE, DBA_OBJECTS, DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Pode revelar credenciais em fonte; não tratar captura como autorizada para execução. Não preserva grants/edições/compilation settings e wrapped source continua wrapped. LINE/COLUMN widths podem limitar fidelidade de linhas longas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente revisão: @fprc_rct.sql HR PROCEDURE EXEMPLO; capturar saída como código sensível.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  DDL textual do módulo, não executada por este helper.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código original preservado; dependência de RUN_FPRC agora proposta na mesma branch. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 041 — 04/11/2026
  Correções e melhorias: Texto de recriação preservado.
  Limitações e pendências: A1000 WORD_WRAP pode alterar fonte; prefixo CREATE OR REPLACE assume linha1 convencional. JOIN DBA_OBJECTS pode duplicar linhas em certos escopos; sem edição/settings/grants e sem quoting.
  Homologação necessária: Fonte com linha>1000, wrapped, package/body, ausência de objeto e edição; comparar bytes antes de compilar saída.
  Parâmetros e execução: contratos acima e no corpo; só ambiente controlado.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e comparação estática; sem compilação/execução
  Oracle, Windows, alteração de privilégio ou gravação de arquivo no servidor.

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
REM
REM NAME:      FPRC_RPT.SQL 
REM
REM FUNCTION: Build a script to re-create functions, procedures, 
REM           packages or package bodies.
REM
REM
set termout off verify off feedback off lines 1000 pages 0 heading off
set recsep off space 0
column text format a1000 word_wrap
column line noprint
select 'create or replace '||text,line
from 
	dba_source
where
	owner = upper('&&1') and
	type = upper('&&2') and
	name = upper('&&3') and
	line = 1;
select text,line 
from
	dba_OBJECTS s1,
	dba_source s2
where
	s1.OBJECT_type = upper('&&2') and
	s1.owner = upper('&&1') and
	s1.object_name = upper('&&3') and
	s1.OBJECT_type = s2.type and
	s1.owner = s2.owner and
	s1.OBJECT_NAME = s2.name and
	line > 1
order by
	2;
select '/' from dual;
