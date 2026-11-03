/*
===============================================================================
SCRIPT: buffer_pools.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/buffer_pools.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Contar buffers por nome de objeto nos três pools usando índice de descritor legado.

FUNCIONAMENTO DETALHADO
  Três ramos consultam X$BH/SYS.OBJ$ e subconsultas escalares V$BUFFER_POOL/X$KCBWDS para START/END_BUF#.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Acesso administrativo autorizado às estruturas internas listadas; validar layout e custo antes de uso.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.OBJ$, X$BH, V$BUFFER_POOL, X$KCBWDS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Relação V.ID=X.INDX é interna e dependente de versão. Mais de uma linha na subconsulta causa ORA-01427; não escolher linha arbitrariamente. Agrupa homônimos e pode custar caro.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @buffer_pools.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  KEEP/DEFAULT/RECYCLE, nome e número de buffers não livres de owners diferentes de SYS.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  OBJ$ qualificado com SYS; lógica interna preservada para homologação. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem buffer_pools.sql
rem FUNCTION; Show status of blocks in all pools
rem from pipeline
rem
ttitle 'Buffer Pool Status'
spool buffer_pools.lst
select 'KEEP' POOL, o.name, count(buf#) BLOCKS
from sys.obj$ o, x$bh x
where o.dataobj# = x.obj
and x.state !=0
and o.owner# !=0
and buf# >= (select x.start_buf# from v$buffer_pool v, x$kcbwds x
where v.id = x.indx and v.id>0 and v.name='KEEP')
and buf# <= (select x.end_buf# from v$buffer_pool v, x$kcbwds x
where v.id = x.indx and v.id>0 and v.name='KEEP')
group by 'KEEP',o.name
union all
select 'DEFAULT' POOL, o.name, count(buf#) BLOCKS
from sys.obj$ o, x$bh x
where o.dataobj# = x.obj
and x.state !=0
and o.owner# !=0
and buf# >= (select x.start_buf# from v$buffer_pool v, x$kcbwds x
where v.id = x.indx and v.id>0 and v.name='DEFAULT')
and buf# <= (select x.end_buf# from v$buffer_pool v, x$kcbwds x
where v.id = x.indx and v.id>0 and v.name='DEFAULT')
group by 'DEFAULT',o.name
union all
select 'RECYCLE' POOL, o.name, count(buf#) BLOCKS
from sys.obj$ o, x$bh x
where o.dataobj# = x.obj
and buf# >= (select x.start_buf# from v$buffer_pool v, x$kcbwds x
where v.id = x.indx and v.id>0 and v.name='RECYCLE')
and x.state !=0
and o.owner# !=0
and buf# <= (select x.end_buf# from v$buffer_pool v, x$kcbwds x
where v.id = x.indx and v.id>0 and v.name='RECYCLE')
group by 'RECYCLE',o.name 
/
spool off
ttitle off
