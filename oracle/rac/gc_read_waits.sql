/*
===============================================================================
SCRIPT: gc_read_waits.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/gc_read_waits.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Calcular razão acumulada entre tempo de gc read wait e sua contagem por instância.

FUNCIONAMENTO DETALHADO
  Une duas estatísticas de GV$SYSSTAT por INST_ID e divide tempo por número de waits.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$SYSSTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Confirmar existência/unidade dos nomes na versão; não presumir ms só pelo alias original. Não é latência de todos os blocos de cache fusion nem taxa instantânea.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @gc_read_waits.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  INST_ID, READ_WAITS, READ_WAIT_TIME e AVG_TIME_PER_WAIT.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Alias com aspas corrompidas substituído por identificador neutro; NULLIF protege contagem zero; codificação UTF-8 reconhecida. 
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
   a.inst_id,
   a.value as read_waits,
   b.value as read_wait_time,
   b.value/nullif(a.value,0) as avg_time_per_wait
from
   (select 
      inst_id,
      name,
      value
   from 
      gv$sysstat
   where 
      name ='gc read waits') a,
   (select 
      inst_id,
      name,
      value
   from 
      gv$sysstat
   where 
      name ='gc read wait time') b
where 
   a.inst_id=b.inst_id
order by
   a.inst_id;