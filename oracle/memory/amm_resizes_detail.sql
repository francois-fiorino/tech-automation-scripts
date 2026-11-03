/*
===============================================================================
SCRIPT: amm_resizes_detail.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/amm_resizes_detail.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar eventos distintos de resize de memória com parâmetro e tipo da operação.

FUNCIONAMENTO DETALHADO
  Consulta V$MEMORY_RESIZE_OPS, formata START_TIME e combina DISTINCT com PARAMETER e OPER_TYPE; ordena pelo texto temporal em formato ISO.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$MEMORY_RESIZE_OPS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Oracle 11g+ para AMM; histórico circular e DISTINCT podem colapsar operações iguais no mesmo minuto. Não exibe tamanho final nem status de sucesso.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @amm_resizes_detail.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  C1 início, C2 parâmetro e C3 tipo de operação, em ordem temporal até precisão de minuto.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Data formatada alterada para YYYY-MM-DD HH24:MI, tornando ORDER BY C1 cronológico em vez de ordenar DD-MON-YY lexicograficamente. 
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

set pages 999

col c1 heading "start|time"
col c2 heading "type"       format a20
col c3 heading "operation"  format a20


break on c1 skip 2

select distinct
   to_char(start_time,'YYYY-MM-DD hh24:mi') c1,
   parameter c2,
   oper_type c3
from
   v$memory_resize_ops
order by
   c1
;