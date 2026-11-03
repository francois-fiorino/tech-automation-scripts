/*
===============================================================================
SCRIPT: shared_pool_grd_hist.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/shared_pool_grd_hist.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Calcular mínimo/média/máximo de memória GCS/GES observada em snapshots.

FUNCIONAMENTO DETALHADO
  Soma BYTES de nomes gcs%/ges% em shared pool por DBID/SNAP_ID, depois aplica MIN/AVG/MAX convertidos a MiB.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_SGASTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Soma instâncias em cada ponto; não é média por instância nem todas as estruturas GRD. Sem período/DBID fixado: resumo pode reunir bancos distintos, agora sem cruzar os pontos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @shared_pool_grd_hist.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  MIN_GRD_MBYTES, AVG_GRD_MBYTES e MAX_GRD_MBYTES.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  DBID incluído no GROUP BY de cada ponto para não somar snapshots homônimos de bancos diferentes. 
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
   round(min(grd_bytes)/1024/1024,2) as min_grd_mbytes, 
   round(avg(grd_bytes)/1024/1024,2) as avg_grd_mbytes,
   round(max(grd_bytes)/1024/1024,2) as max_grd_mbytes
from (
   select 
      dbid, snap_id,
      sum(bytes) as grd_bytes
   from 
      dba_hist_sgastat
   where 
      pool='shared pool'
      and 
         (name like 'gcs%' 
          or 
          name like 'ges%')
   group by 
      dbid,snap_id);


