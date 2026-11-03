/*
===============================================================================
SCRIPT: gc_bad_transfers.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/gc_bad_transfers.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir contadores de blocos perdidos/corrompidos e idade da instância de startup mais antigo.

FUNCIONAMENTO DETALHADO
  Três agregações de GV$SYSSTAT/GV$INSTANCE combinadas numa linha; DAYS_UP usa SYSDATE-MIN(STARTUP_TIME).

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$SYSSTAT, GV$INSTANCE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DAYS_UP não prova uptime contínuo de todos os nós. Contadores têm baselines locais e não são taxa; ausência de estatística não equivale a zero erros.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @gc_bad_transfers.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  DAYS_UP, BLOCKS_LOST e BLOCKS_CORRUPT; NULL se estatística não existir.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta integral preservada. 
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
   days_up,
   blocks_lost,
   blocks_corrupt
from (select 
         sum(value) as blocks_lost
      from 
         gv$sysstat
      where 
         name='gc blocks lost'),
     (select 
         sum(value) as blocks_corrupt
      from 
         gv$sysstat
      where 
         name='gc blocks corrupt'),         
     (select 
         round(sysdate-min(startup_time),2) as days_up
      from
         gv$instance);