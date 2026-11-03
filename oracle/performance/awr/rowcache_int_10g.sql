/*
===============================================================================
SCRIPT: rowcache_int_10g.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/rowcache_int_10g.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Medir deltas de acessos e misses do dictionary cache.

FUNCIONAMENTO DETALHADO
  Pareia ROWCACHE_SUMMARY por parâmetro/DBID/instância e calcula GETS/SCANS/misses/modificações; preserva USAGE final.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_ROWCACHE_SUMMARY

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Definir pBgnSnap, pEndSnap, pDbId e pInstNum com snapshots crescentes da mesma instância, DBID e STARTUP_TIME. Reinício ou baseline ausente pode invalidar deltas. Validar CON_ID e unicidade das linhas na versão; modelo histórico 10g. Só parâmetros com aumento de GETS aparecem. USAGE não é delta.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE pBgnSnap = 100
  DEFINE pEndSnap = 101
  DEFINE pDbId = 123456789
  DEFINE pInstNum = 1
  @rowcache_int_10g.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Parâmetro, deltas e percentuais; Final Usage é gauge do snapshot final.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta e proteções DECODE originais preservadas. 
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
select
  param "Parameter",
  gets "Get Requests",
  getm "Pct Miss",
  scans "Scan Requests",
  scanm "Pct Miss",
  mods "Mod Req",
  usage "Final Usage"
From
(select lower(b.parameter)                                        param
     , e.gets - b.gets                                           gets
     , to_number(decode(e.gets,b.gets,null,
       (e.getmisses - b.getmisses) * 100/(e.gets - b.gets)))     getm
     , e.scans - b.scans                                         scans
     , to_number(decode(e.scans,b.scans,null,
       (e.scanmisses - b.scanmisses) * 100/(e.scans - b.scans))) scanm
     , e.modifications - b.modifications                         mods
     , e.usage                                                   usage
  from dba_hist_rowcache_summary  b
     , dba_hist_rowcache_summary  e
 where b.snap_id         = &pBgnSnap
   and e.snap_id         = &pEndSnap
   and b.dbid            = &pDbId
   and e.dbid            = &pDbId
   and b.dbid            = e.dbid
   and b.instance_number = &pInstNum
   and e.instance_number = &pInstNum
   and b.instance_number = e.instance_number
   and b.parameter       = e.parameter
   and e.gets - b.gets   > 0   )
 order by param;
