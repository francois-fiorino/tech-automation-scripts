/*
===============================================================================
SCRIPT: my_trace_file.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/my_trace_file.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar caminho de trace corrente e comparar com construção legada.

FUNCIONAMENTO DETALHADO
  Preserva concatenação de diagnostic_dest/DB/instância/SPID e acrescenta Default Trace File de V$DIAG_INFO.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION, V$PROCESS, V$PARAMETER, V$INSTANCE, V$DATABASE, V$DIAG_INFO, SYS_CONTEXT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Oracle 11g+ com ADR. Caminho legado pode divergir por DB_UNIQUE_NAME, trace identifier ou modo de processo; em shared server validar servidor/contexto. Não ativa trace nem lê/cria seu arquivo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @my_trace_file.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  LEGACY_TRACE_FILE calculado e TRACE_FILE efetivo informado por ADR.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Caminho legado renomeado e saída oficial acrescentada, preservando construção original. 
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
   pm.value||'/diag/rdbms/'||d.name||'/'||i.instance_name||
   '/trace/'||i.instance_name||'_ora_'||pr.spid||'.trc' as legacy_trace_file,
   di.value as trace_file
from
  (select 
      p.spid
   from 
      v$session s
   join 
      v$process p
      on s.paddr=p.addr
   where 
      s.sid=SYS_CONTEXT('USERENV','SID')) pr
   cross join
     (select 
         value 
      from 
         v$parameter 
      where 
         name='diagnostic_dest') pm 
   cross join
     (select 
         instance_name 
      from 
         v$instance) i
   cross join
     (select
         lower(name) as name
      from 
         v$database) d
   cross join (select value from v$diag_info where name='Default Trace File') di
/