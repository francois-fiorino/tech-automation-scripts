/*
===============================================================================
SCRIPT: undoc73a.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/undoc73a.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar parâmetros underscore com valor de instância pela estrutura interna histórica.

FUNCIONAMENTO DETALHADO
  Une X$KSPPI/X$KSPPSV por INDX, filtra underscore literal e ordena nome.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Acesso administrativo autorizado às tabelas internas listadas; validar campos/CON_ID na versão.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  X$KSPPI, X$KSPPSV

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Alvo histórico 7.3/8.0.2 conforme comentário; sem compatibilidade moderna homologada. Diferente de UNDOC: lê valor de instância, não de sessão. Não alterar parâmetros com base só no relatório.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @undoc73a.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Parameter, Description e Instance Value.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta e créditos RevealNet/MRA preservados. 
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
column parameter format a40
column description format a25 word_wrapped
column "Instance Value" format a10 heading "Value"
set lines 80
set pages 1000
spool undoc.lis
select  
	a.ksppinm  "Parameter",  
	a.ksppdesc "Description", 
	c.ksppstvl "Instance Value"
from 
	x$ksppi a, 
	x$ksppsv c
where 
        a.indx = c.indx
	and a.ksppinm like '/_%' escape '/'
order by 1
/
spool off


