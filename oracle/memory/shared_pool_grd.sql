/*
===============================================================================
SCRIPT: shared_pool_grd.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/shared_pool_grd.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar memória de estruturas GCS/GES e total de shared pool na instância local.

FUNCIONAMENTO DETALHADO
  Primeiro SELECT soma BYTES de V$SGASTAT com POOL=shared pool; segundo soma nomes gcs%/ges%; terceiro detalha esses nomes com pool e bytes.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SGASTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Nomes de alocações variam por versão. Segundo SELECT não filtra POOL e não comprova inventário completo de GRD; GRD_MB não deve ser percentual do primeiro valor sem revisar escopo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @shared_pool_grd.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  TOTAL_MB e GRD_MB em MiB arredondados; último conjunto mostra POOL, NAME e BYTES.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consultas originais preservadas; CR isolados normalizados. 
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
   round(sum(bytes)/1024/1024,2) as total_mb
from
   v$sgastat
where
   pool='shared pool';

select
   round(sum(bytes)/1024/1024,2) as grd_mb
from
   v$sgastat
where
   name like 'gcs%'
   or
   name like 'ges%';

select
   pool,
   name,
   bytes
from
   v$sgastat
where
   name like 'gcs%'
   or
   name like 'ges%'
order by
   name;







