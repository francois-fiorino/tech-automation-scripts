/*
===============================================================================
SCRIPT: see_threads.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/see_threads.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir mapeamento histórico de processos Oracle/threads Windows NT.

FUNCIONAMENTO DETALHADO
  Une PROCESS com BGPROCESS/SESSION por endereços e chama DBA_UTILITIES.HEXTOINTEGER para SPID.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$PROCESS, V$BGPROCESS, V$SESSION, DBA_UTILITIES.HEXTOINTEGER

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Depende de função customizada e convenção histórica de SPID hexadecimal; não aplicar conversão a PID decimal/Linux sem validar. Pode haver múltiplas sessões por processo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @see_threads.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tipo do processo, usuário, thread convertido, SPID original e PID interno.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta e crédito Mike Ault preservados. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Dependência de título externo substituída por TTITLE local.
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
rem see_threads.sql
rem example select to see threads on NT with names
rem Mike Ault
col Process format a7 heading 'Process'
col username format a10 heading 'Owner'
col thread format 999999 heading 'Decimal|Thread'
col non_con heading 'Hex|Thread'
col pid heading 'PID'
set trimspool on
ttitle "Oracle Threads Report"
spool see_threads.lst
select 
	decode(b.name,null,'User',b.name) Process, 
	decode(s.username,null,'Internal',s.username) username, 
	dba_utilities.hextointeger(p.spid) Thread,p.spid non_con,p.pid
from 
	v$bgprocess b, 
	v$session s, 
	v$process p
where 
	p.addr=b.paddr(+)
	and p.addr=s.paddr(+)
order by 5
/
spool off
