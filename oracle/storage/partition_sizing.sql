/*
===============================================================================
SCRIPT: partition_sizing.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _table_scripts/partition_sizing.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar segmentos e exemplificar distribuição de blocos ASSM.

FUNCIONAMENTO DETALHADO
  Três consultas DBA_SEGMENTS com nomes de exemplo e um bloco DBMS_SPACE.SPACE_USAGE para SCOTT.EMP.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_SEGMENTS, DBMS_SPACE.SPACE_USAGE, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  SPACE_USAGE exige segmento ASSM suportado e autorização de acesso/EXECUTE; SCOTT.EMP pode não existir. Sem partition_name no exemplo não mede partição individual. Não inclui unformatted no total impresso e tamanho alocado difere de usado.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @partition_sizing.sql
  -- Revisar os nomes MYTABLE/SEG1..3 e SCOTT.EMP em laboratório.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Somas MiB de segmentos e total de blocos/bytes formatados retornados por SPACE_USAGE.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Aspas ausentes em SCOTT/EMP corrigidas; label total esclarece blocos formatados, sem remover saídas ou parâmetros. 
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

select 
   sum(bytes/1024/1024) 
from 
   dba_segments 
where 
   segment_name='MYTABLE';


select 
   owner, 
   segment_name, 
   partition_name, 
   segment_type, 
   bytes / 1024/1024 "MB" 
from 
   dba_segments 
where 
   segment_name in ('SEG1','SEG2','SEG3');

select 
   owner,
   segment_name,
   partition_name,segment_type,bytes/1024/1024 "MB"
from 
   dba_segments 
where 
   segment_type = 'TABLE PARTITION';


set serveroutput on
declare
l_fs1_bytes number;
l_fs2_bytes number;
l_fs3_bytes number;
l_fs4_bytes number;
l_fs1_blocks number;
l_fs2_blocks number;
l_fs3_blocks number;
l_fs4_blocks number;
l_full_bytes number;
l_full_blocks number;
l_unformatted_bytes number;
l_unformatted_blocks number;
v_segname varchar2(500);
begin 
dbms_space.space_usage( 
segment_owner => 'SCOTT',
segment_name => 'EMP', 
segment_type => 'TABLE', 
fs1_bytes => l_fs1_bytes,
fs1_blocks => l_fs1_blocks, 
fs2_bytes => l_fs2_bytes,
fs2_blocks => l_fs2_blocks, 
fs3_bytes => l_fs3_bytes,
fs3_blocks => l_fs3_blocks,
fs4_bytes => l_fs4_bytes,
fs4_blocks => l_fs4_blocks,
full_bytes => l_full_bytes,
full_blocks => l_full_blocks,
unformatted_blocks => l_unformatted_blocks,
unformatted_bytes => l_unformatted_bytes
);
dbms_output.enable;
dbms_output.put_line('=============================================');
dbms_output.put_line('formatted blocks = '||to_char(l_fs1_blocks + l_fs2_blocks +
l_fs3_blocks + l_fs4_blocks + l_full_blocks)|| ' || formatted bytes = '||
to_char(l_fs1_bytes + l_fs2_bytes +
l_fs3_bytes + l_fs4_bytes + l_full_bytes));
end;
/
