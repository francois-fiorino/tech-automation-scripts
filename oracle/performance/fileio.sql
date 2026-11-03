/*
===============================================================================
SCRIPT: fileio.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/FILEIO.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Comparar operações de I/O acumuladas de datafiles e tempfiles e participação no total.

FUNCIONAMENTO DETALHADO
  Agrega PHYRDS+PHYWRTS separadamente em FILESTAT e TEMPSTAT e usa NEW_VALUE para obter total; UNION combina operações e blocos por arquivo, com percentual e blocos por operação.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$FILESTAT, SYS.V_$TEMPSTAT, SYS.V_$DBFILE, SYS.V_$TEMPFILE, DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Contadores acumulados, não IOPS recentes. As leituras do total e dos detalhes não são atômicas; percentuais podem não somar 100. UNION e GREATEST(contador,1) históricos preservados. NEW_VALUE pode sofrer arredondamento pelo formato do cliente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @fileio.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  FILE#, nome, leituras/escritas, percentual de operações, blocos e razões bloco/operação.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Percentuais protegidos por NULLIF no total. As duas variantes de apresentação FILEIO2/FILEIO_NH serão mapeadas a esta consulta canônica. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem NAME: fileio.sql
rem
rem FUNCTION: Reports on the file io status of all of the
rem FUNCTION: datafiles in the database.

rem HISTORY:
rem WHO		WHAT		WHEN
rem Mike Ault		Created		1/5/96
rem
column sum_io1 new_value st1 noprint
column sum_io2 new_value st2 noprint
column sum_io new_value divide_by noprint
column Percent format 999.999 heading 'Percent|Of IO'
column brratio format 999.99 heading 'Block|Read|Ratio'
column bwratio format 999.99 heading 'Block|Write|Ratio'
column phyrds heading 'Physical | Reads'
column phywrts heading 'Physical | Writes'
column phyblkrd heading 'Physical|Block|Reads'
column phyblkwrt heading 'Physical|Block|Writes'
column name format a45 heading 'File|Name'
column file# format 9999 heading 'File'
set feedback off verify off lines 132 pages 60 sqlbl on trims on
rem
select
	nvl(sum(a.phyrds+a.phywrts),0) sum_io1
from 
	sys.v_$filestat a;
select nvl(sum(b.phyrds+b.phywrts),0) sum_io2
from
        sys.v_$tempstat b;
select &st1+&st2 sum_io from dual;
rem
ttitle 'File IO Statistics Report'
spool fileio.lst
select
	a.file#,b.name, a.phyrds, a.phywrts,
	(100*(a.phyrds+a.phywrts)/nullif(&divide_by,0)) Percent,
	a.phyblkrd, a.phyblkwrt, (a.phyblkrd/greatest(a.phyrds,1)) brratio,
      (a.phyblkwrt/greatest(a.phywrts,1)) bwratio
from
	sys.v_$filestat a, sys.v_$dbfile b
where
	a.file#=b.file#
union
select
	c.file#,d.name, c.phyrds, c.phywrts,
	(100*(c.phyrds+c.phywrts)/nullif(&divide_by,0)) Percent,
	c.phyblkrd, c.phyblkwrt,(c.phyblkrd/greatest(c.phyrds,1)) brratio,
      (c.phyblkwrt/greatest(c.phywrts,1)) bwratio
from
	sys.v_$tempstat c, sys.v_$tempfile d
where
	c.file#=d.file#
order by
	1
/
spool off
pause Press enter to continue
set feedback on verify on lines 80 pages 22
clear columns
ttitle off
