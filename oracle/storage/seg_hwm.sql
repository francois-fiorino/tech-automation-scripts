/*
===============================================================================
SCRIPT: seg_hwm.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _segment_scripts/seg_hwm.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar espaço não usado e posição do último extent com dados de um segmento.

FUNCIONAMENTO DETALHADO
  Chama DBMS_SPACE.UNUSED_SPACE, busca maior EXTENT_ID e extent correspondente em DBA_EXTENTS e imprime totais/bytes livres e sua fração.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  EXECUTE em DBMS_SPACE e DBMS_OUTPUT, propriedade do segmento ou ANALYZE ANY
  conforme versão do pacote; SELECT autorizado em DBA_EXTENTS.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBMS_SPACE.UNUSED_SPACE, DBMS_OUTPUT, SYS.DBA_EXTENTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  EXECUTE em DBMS_SPACE/DBMS_OUTPUT e propriedade do segmento ou ANALYZE ANY conforme pacote/versão. Não informa partition_name, portanto não suporta partições de forma geral. SELECT INTO pode falhar em segmento sem extent/objeto incompatível; conferir IDs de arquivo na versão. Espaço unused não é todo espaço reaproveitável abaixo do HWM.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE schema = HR
  DEFINE segment = EMPLOYEES
  DEFINE segtype = TABLE
  @seg_hwm.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Total de blocos/bytes, unused blocks/bytes, percentual, IDs e posição do último extent/bloco usado.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF em TOTAL_BYTES evita divisão por zero. Operações de shrink/move/deallocate não são executadas. 
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
set serveroutput on
set verify off
declare
v1 number;
v2 number;
v3 number;
v4 number;
v5 number;
v6 number;
v7 number;
emax number;
euse number;
eublk number;
fp number;
begin

dbms_space.unused_space(upper('&&schema'), upper('&&segment'),
upper('&&segtype'),v1,v2,v3,v4,v5,v6,v7);

select max(extent_id) into emax
from sys.dba_extents
where
owner = upper('&&SCHEMA')
and segment_name = upper('&&SEGMENT');

select extent_id, blocks into euse, eublk
from sys.dba_extents
where
owner = upper('&&SCHEMA')
and segment_name = upper('&&SEGMENT')
and file_id = v5
and block_id = v6;

fp := (v4 * 100) / nullif(v2,0);
dbms_output.put_line (' ');
dbms_output.put_line ('Schema: '||'&&schema'||' Segment: '||'&&segment'||' Type: '||'&&segtype');
dbms_output.put_line ('total_blocks '||v1);
dbms_output.put_line ('total_bytes '||v2);
dbms_output.put_line ('unused_blocks '||v3);
dbms_output.put_line ('unused_bytes '||v4||' = '||
ltrim(to_char(fp,'999'))||'%');
dbms_output.put_line ('last_used_extent '||euse||'/'||emax);
dbms_output.put_line ('last_used_extent_file_id '||v5);
dbms_output.put_line ('last_used_extent_block_id '||v6);
dbms_output.put_line ('last_used_block '||v7);
dbms_output.put_line ('last_used_extent_blocks '||eublk);
end;
/
undef schema
undef segment
undef segtype
set serveroutput off
set verify on
