/*
===============================================================================
SCRIPT: buf_stat_xbh.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/buf_stat_xbh.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Contar buffers de objetos por pool com mapeamento de conjuntos internos.

FUNCIONAMENTO DETALHADO
  Três ramos KEEP/DEFAULT/RECYCLE ligam DATAOBJ# a X$BH e delimitam BUF# por MIN/MAX de X$KCBWDS via X$KCBWBPD.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Acesso administrativo autorizado às estruturas internas listadas; validar layout e custo antes de uso.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.OBJ$, X$BH, X$KCBWBPD, X$KCBWDS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Acesso interno pode ser caro e gerar contenção. Intervalo MIN/MAX pressupõe distribuição válida dos sets; nomes iguais de owners distintos são agrupados. Não são blocos físicos únicos nem tamanho de segmento.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @buf_stat_xbh.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Pool, nome e quantidade de cabeçalhos de buffer, excluindo OWNER#=0 e STATE=0.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Algoritmo histórico integral preservado; validar mapeamento dos sets na versão. 
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
col name for a30
break on pool skip 1

select 'KEEP' POOL, o.name, count(buf#) BLOCKS 
from sys.obj$ o, x$bh x 
where o.dataobj# = x.obj 
and x.state !=0 
and o.owner# !=0 
and buf# >= (select min(b.START_BUF#) from x$kcbwbpd a, X$KCBWDS b
 where a.bp_name = 'KEEP'
 and b.set_id between a.BP_LO_SID and a.BP_HI_SID
 and a.bp_size > 0)
and buf# <= (select max(b.END_BUF#) from x$kcbwbpd a, X$KCBWDS b
 where a.bp_name = 'KEEP'
 and b.set_id between a.BP_LO_SID and a.BP_HI_SID
 and a.bp_size > 0)
group by 'KEEP',o.name 
union all 
select 'DEFAULT' POOL, o.name, count(buf#) BLOCKS 
from sys.obj$ o, x$bh x 
where o.dataobj# = x.obj 
and x.state !=0 
and o.owner# !=0 
and buf# >= (select min(b.START_BUF#) from x$kcbwbpd a, X$KCBWDS b
 where a.bp_name = 'DEFAULT'
 and b.set_id between a.BP_LO_SID and a.BP_HI_SID
 and a.bp_size > 0)
and buf# <= (select max(b.END_BUF#) from x$kcbwbpd a, X$KCBWDS b
 where a.bp_name = 'DEFAULT'
 and b.set_id between a.BP_LO_SID and a.BP_HI_SID
 and a.bp_size > 0)
group by 'DEFAULT',o.name 
union all 
select 'RECYCLE' POOL, o.name, count(buf#) BLOCKS 
from sys.obj$ o, x$bh x 
where o.dataobj# = x.obj 
and x.state !=0 
and o.owner# !=0 
and buf# >= (select min(b.START_BUF#) from x$kcbwbpd a, X$KCBWDS b
 where a.bp_name = 'RECYCLE'
 and b.set_id between a.BP_LO_SID and a.BP_HI_SID
 and a.bp_size > 0)
and buf# <= (select max(b.END_BUF#) from x$kcbwbpd a, X$KCBWDS b
 where a.bp_name = 'RECYCLE'
 and b.set_id between a.BP_LO_SID and a.BP_HI_SID
 and a.bp_size > 0)
group by 'RECYCLE',o.name 
/

clear break
