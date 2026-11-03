/*
===============================================================================
SCRIPT: undoc73.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/undoc73.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar parâmetros underscore com valores de sessão e instância.

FUNCIONAMENTO DETALHADO
  Une X$KSPPI/KSPPCV/KSPPSV por INDX e filtra underscore literal.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Acesso administrativo autorizado às estruturas internas listadas; não conceder privilégios amplos para um relatório.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  X$KSPPI, X$KSPPCV, X$KSPPSV

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Alvo histórico 7.3/8.0.2; estruturas internas não têm contrato estável moderno. Não alterar parâmetros por este relatório; valores podem ser sensíveis. Variante UNDOC73A só mostra instância.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @undoc73.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Nome, descrição, Session Value e Instance Value.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta e crédito RevealNet/MRA preservados. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
REM Script for getting undocumented init.ora
REM parameters from a 7.3 or 8.0.2 instance
REM MRA - Revealnet 4/23/97
REM
column parameter format a37
column description format a30 word_wrapped
column "Session Value" format a10
column "Instance Value" format a10
set lines 100
set pages 1000
ttitle 'Undocumented Parameters'
spool undoc73.lst
select  
	a.ksppinm  "Parameter",  
	a.ksppdesc "Description", 
	b.ksppstvl "Session Value",
	c.ksppstvl "Instance Value"
from 
	x$ksppi a, 
	x$ksppcv b, 
	x$ksppsv c
where 
	a.indx = b.indx 
	and a.indx = c.indx
	and a.ksppinm like '/_%' escape '/'
order by 1
/
spool off
ttitle off

