/*
===============================================================================
SCRIPT: fileio_mp2.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/fileio_mp2.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Agregar I/O por prefixo fixo de 35 caracteres, separando temporários.

FUNCIONAMENTO DETALHADO
  Obtém operações totais, agrupa FILESTAT e TEMPSTAT por SUBSTR(nome,1,35), acrescenta tmp no rótulo temporário e soma operações, percentual e blocos.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$FILESTAT, SYS.V_$TEMPSTAT, SYS.V_$DBFILE, SYS.V_$TEMPFILE, DUAL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  35 caracteres são fixos e não representam necessariamente mountpoint; nomes distintos podem colapsar. Métricas acumuladas, não IOPS ou throughput em bytes.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @fileio_mp2.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  NAME, SUM_PHY_IO, PERCENT e SUM_BLK_IO por prefixo/tipo.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF aplicado ao denominador dos percentuais de datafiles e tempfiles. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
column sum_io1 new_value st1 noprint
column sum_io2 new_value st2 noprint
column sum_io new_value divide_by noprint
column name format a40 heading 'Mount Point'
column sum_blk_io format 999,999,999 heading 'Sum|Block IO'
column sum_phy_io format 9,999,999,999 heading 'Sum|Physical IO'
column percent format 999.99
set verify off feedback off sqlbl on 
set lines 132 pages 47
ttitle off
select
	nvl(sum(a.phyrds+a.phywrts),0) sum_io1
from 
	sys.v_$filestat a;
select nvl(sum(b.phyrds+b.phywrts),0) sum_io2
from
        sys.v_$tempstat b;
select &st1+&st2 sum_io from dual;
ttitle 'File IO by Mount Point'
spool fileio_mp2.lst
select
	substr(b.name,1,35) name, sum(a.phyrds+a.phywrts) sum_phy_io,
	sum((100*(a.phyrds+a.phywrts)/nullif(&divide_by,0))) Percent,
	sum(a.phyblkrd+a.phyblkwrt) sum_blk_io
from
	sys.v_$filestat a, sys.v_$dbfile b
where
	a.file#=b.file#
group by substr(b.name,1,35) 
union
select
	substr(d.name,1,35)||'tmp' name, sum(c.phyrds+c.phywrts) sum_phy_io,
	sum((100*(c.phyrds+c.phywrts)/nullif(&divide_by,0))) Percent,
	sum(c.phyblkrd+c.phyblkwrt) sum_blk_io
from
	sys.v_$tempstat c, sys.v_$tempfile d
where
	c.file#=d.file#
group by substr(d.name,1,35)
order by 1,2
/
spool off

