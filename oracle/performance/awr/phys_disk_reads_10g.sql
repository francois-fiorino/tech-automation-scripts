/*
===============================================================================
SCRIPT: phys_disk_reads_10g.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/phys_disk_reads_10g.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar contadores acumulados de leituras de datafiles associados a snapshots AWR.

FUNCIONAMENTO DETALHADO
  Relaciona DBA_HIST_FILESTATXS a DBA_HIST_SNAPSHOT por SNAP_ID, DBID e INSTANCE_NUMBER e apresenta início do intervalo, arquivo e PHYRDS.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_FILESTATXS, DBA_HIST_SNAPSHOT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Oracle 10g+ com AWR. Sem filtro de período e sem ordenação garantida; BREAK do cliente não substitui ORDER BY. Reinícios alteram baseline dos contadores.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @phys_disk_reads_10g.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  BEGIN_INTERVAL_TIME, FILENAME e PHYRDS; valor acumulado observado no snapshot, não delta do intervalo.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NATURAL JOIN substituído por chaves explícitas de snapshot para impedir mudança silenciosa de semântica por colunas comuns adicionais. 
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
break on begin_interval_time skip 2

column phyrds              format 999,999,999
column begin_interval_time format a25

select 
   begin_interval_time, 
   filename,
   phyrds
from
   dba_hist_filestatxs f
join dba_hist_snapshot sn
  on sn.snap_id=f.snap_id
 and sn.dbid=f.dbid
 and sn.instance_number=f.instance_number
;
