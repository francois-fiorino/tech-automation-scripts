/*
===============================================================================
SCRIPT: physical_reads_writes_awr.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/physical_reads_writes_awr.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Somar contadores históricos de leitura/escrita de segmentos de um objeto configurado.

FUNCIONAMENTO DETALHADO
  Une estatísticas AWR de segmentos/objetos/snapshots com DBID, TS#, OBJ#, DATAOBJ# e instância e agrupa dia completo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_SEG_STAT, DBA_HIST_SEG_STAT_OBJ, DBA_HIST_SNAPSHOT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  São somas de contadores TOTAL através de snapshots, não operações/deltas diários confiáveis. Partições são agregadas pelo nome. Confirmar CON_ID/CON_DBID se usar AWR multitenant.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @physical_reads_writes_awr.sql
  -- Editar owner XXX e object_name YYY antes do uso.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  C1 em YYYY-MM-DD e somas de PHYSICAL_READS_TOTAL/PHYSICAL_WRITES_TOTAL.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Chaves históricas incompletas corrigidas; dia agora inclui ano, evitando combinar MM/DD de anos distintos. Métrica TOTAL preservada e ressalvada. 
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

select distinct
   to_char(begin_interval_time,'yyyy-mm-dd') c1,
   sum(physical_reads_total)            reads,
   sum(physical_writes_total)           writes
from
   dba_hist_seg_stat     s,
   dba_hist_seg_stat_obj o,
   dba_hist_snapshot    sn
where
   o.owner = 'XXX'
and
   s.obj# = o.obj#
and s.dbid=o.dbid and s.ts#=o.ts# and s.dataobj#=o.dataobj#
and
   sn.snap_id = s.snap_id
and sn.dbid=s.dbid and sn.instance_number=s.instance_number
and
   object_name = 'YYY'
group by
   to_char(begin_interval_time,'yyyy-mm-dd')
order by 1;