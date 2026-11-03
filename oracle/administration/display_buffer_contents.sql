/*
===============================================================================
SCRIPT: display_buffer_contents.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/display_buffer_contents.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Materializar buffers por objeto e comparar com blocos de segmento.

FUNCIONAMENTO DETALHADO
  DROP TABLE T1 e CTAS a partir de OBJECTS/BH; relatório associa segmentos por owner/nome/tipo/partição.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme LIMITAÇÕES; roles não
  bastam para compilar dependências de rotinas armazenadas.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  T1, DBA_OBJECTS, V$BH, DBA_SEGMENTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DROP destrutivo e CTAS confirmam transação; CREATE TABLE/quota/SELECT. Varredura de buffer headers pode custar recursos. Snapshot cache e segmentos são instantes diferentes; multitenant requer avaliar CON_ID. Percentual é estimativa e não prova benefício de KEEP.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema descartável sem tabela T1 valiosa: revisar arquivo.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  T1 persistente e relatório para objetos com mais de dez buffers.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados ou sessão descritos
  acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Delimitador entre FILE#/BLOCK# evita colisão de concatenação; formato COLUMN quebrado reunido e NULLIF no cálculo bytes/blocos. 
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

set pages 999
set lines 92

ttitle 'Contents of Data Buffers'

drop table t1;

create table t1 as
select
   o.owner          owner,
   o.object_name    object_name,
   o.subobject_name subobject_name,
   o.object_type    object_type,
   count(distinct file# || ':' || block#)         num_blocks
from
   dba_objects  o,
   v$bh         bh
where
   o.data_object_id  = bh.objd
and
   o.owner not in ('SYS','SYSTEM')
and
   bh.status != 'free'
group by
   o.owner,
   o.object_name,
   o.subobject_name,
   o.object_type
order by
   count(distinct file# || ':' || block#) desc
;

column c0 heading "Owner"                                    format a12
column c1 heading "Object|Name"                              format a30
column c2 heading "Object|Type"                              format a8
column c3 heading "Number of|Blocks in|Buffer|Cache"         format 99,999,999
column c4 heading "Percentage|of object|blocks in|Buffer"    format 999
column c5 heading "Buffer|Pool"                              format a7
column c6 heading "Block|Size"                               format 99,999

select
   t1.owner                                          c0,
   object_name                                       c1,
   case when object_type = 'TABLE PARTITION' then 'TAB PART'
        when object_type = 'INDEX PARTITION' then 'IDX PART'
        else object_type end c2,
   sum(num_blocks)                                     c3,
   (sum(num_blocks)/greatest(sum(blocks), .001))*100 c4,
   buffer_pool                                       c5,
   sum(bytes)/nullif(sum(blocks),0)                            c6
from
   t1,
   dba_segments s
where
   s.segment_name = t1.object_name
and
   s.owner = t1.owner
and
   s.segment_type = t1.object_type
and
   nvl(s.partition_name,'-') = nvl(t1.subobject_name,'-')
group by
   t1.owner,
   object_name,
   object_type,
   buffer_pool
having
   sum(num_blocks) > 10
order by
   sum(num_blocks) desc
;