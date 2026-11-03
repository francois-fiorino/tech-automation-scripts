/*
===============================================================================
SCRIPT: bound_ob.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _tablespace_scripts/BOUND_OB.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Investigar extents com espaço livre imediatamente antes e depois no dicionário legado.

FUNCIONAMENTO DETALHADO
  Consulta UET$/FET$ e mapeia cabeçalhos via SYS_OBJECTS, objetos, owners e tablespaces.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.UET$, SYS.FET$, SYS.OBJ$, SYS.SYS_OBJECTS (dependência legada/customizada), SYS.USER$, SYS.TS$

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Modelo DMT, não homologado em LMT. Original não restringe FET$ por arquivo/tablespace: pode cruzar blocos homônimos e produzir falsos positivos; usa bloco SYSTEM para todos. SYS_OBJECTS precisa existir com campos esperados. Não usar resultado para mover objetos automaticamente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @bound_ob.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tablespace, owner, tipo/nome e bytes calculados pelo tamanho de bloco histórico.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Algoritmo preservado sem inventar chaves de tabelas internas; problemas de identidade/unidade sinalizados para testes. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem  **************************************************************************
rem  NAME:    BOUND_OB.sql
rem  comment: Report on objects with extents bounded by freespace
rem  **************************************************************************
ttitle "Objects With Extents Bounded by Free Space"
spool bound_ob.lst
column e format a15 heading "TABLE SPACE"
column a format a6 heading "OBJECT|TYPE"
column b format a30 heading "OBJECT NAME"
column c format a10 heading "OWNER ID"
column d format 99,999,999 heading "SIZE|IN BYTES"
break on e skip 1 on c 
rem set feedback off
set verify off
rem set termout off
column bls new_value BLOCK_SIZE noprint
select blocksize bls
from sys.ts$
where name='SYSTEM';

select h.name e, g.name c, f.object_type a, e.name b, b.length*&&block_size d
  from sys.uet$ b, sys.fet$ c, sys.fet$ d, sys.obj$ e, sys.sys_objects f, sys.user$ g, sys.ts$ h
 where b.block# = c.block# + c.length
   and b.block# + b.length = d.block#
   and f.header_file = b.segfile#
   and f.header_block = b.segblock#
   and f.object_id = e.obj#
   and g.user# = e.owner#
   and b.ts# = h.ts#
 order by 1,2,3,4
/

column a clear
column b clear
column c clear
column d clear
set feedback on 
set verify on
set termout on
ttitle ''
ttitle off
spool off
clear breaks
