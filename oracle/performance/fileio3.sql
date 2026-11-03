/*
===============================================================================
SCRIPT: fileio3.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/fileio3.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar I/O acumulado de arquivos com padrões TOOL/TEMP no nome.

FUNCIONAMENTO DETALHADO
  UNION de datafiles cujo nome contém TOOL ou TEMP e tempfiles com TEMP; exibe operações, blocos e razões por operação.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$FILESTAT, SYS.V_$DBFILE, SYS.V_$TEMPSTAT, SYS.V_$TEMPFILE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Filtro textual não identifica tablespace nem classe real de arquivo; pode excluir tempfiles OMF sem TEMP. GREATEST(contador,1) evita zero, mas razão sem operações não significa média medida.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @fileio3.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  FILE#, nome, PHYRDS/PHYWRTS, PHYBLKRD/PHYBLKWRT e blocos por operação.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta e filtros originais preservados. 
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
column brratio format 999.99 heading 'Block|Read|Ratio'
column bwratio format 999.99 heading 'Block|Write|Ratio'
column phyrds heading 'Physical| Reads' format 99999999
column phywrts heading 'Physical| Writes' format 99999999
column phyblkrd heading 'Physical|Block|Reads' format 99999999
column phyblkwrt heading 'Physical|Block|Writes' format 99999999
column name format a38 heading 'File|Name'
column file# format 9999 heading 'File'
set sqlbl on trims on
select
	a.file#,b.name, a.phyrds, a.phywrts,
	a.phyblkrd, a.phyblkwrt, (a.phyblkrd/greatest(a.phyrds,1)) brratio,
      (a.phyblkwrt/greatest(a.phywrts,1)) bwratio
from
	sys.v_$filestat a, sys.v_$dbfile b
where
        (upper(b.name) like '%TOOL%' or upper(b.name) like '%TEMP%')
        and a.file#=b.file#
union
select
	c.file#,d.name, c.phyrds, c.phywrts,
	c.phyblkrd, c.phyblkwrt,(c.phyblkrd/greatest(c.phyrds,1)) brratio,
      (c.phyblkwrt/greatest(c.phywrts,1)) bwratio
from
	sys.v_$tempstat c, sys.v_$tempfile d
where
	c.file#=d.file#
        and upper(d.name) like '%TEMP%'
order by
	1
/
clear columns

