/*
===============================================================================
SCRIPT: amm_resizes_per_day.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/amm_resizes_per_day.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Contar registros de operações de resize de memória por dia.

FUNCIONAMENTO DETALHADO
  Agrupa V$MEMORY_RESIZE_OPS por START_TIME formatado YYYY-MM-DD e calcula COUNT(*); ordena pelo mesmo dia.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$MEMORY_RESIZE_OPS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Oracle 11g+; histórico retido pode não cobrir todos os dias. Contagem inclui estados/tipos presentes, não apenas resizes bem-sucedidos. DISTINCT é redundante com GROUP BY, mas foi preservado.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @amm_resizes_per_day.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  C1 dia e C2 número de operações registradas.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original preservada. 
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
col c2 heading "nbr|resizes" format 9,999

break on c1 skip 1

select distinct
   to_char(start_time,'YYYY-MM-DD') c1,
   count(*) c2
from
   v$memory_resize_ops
group by
   to_char(start_time,'YYYY-MM-DD')
order by
   to_char(start_time,'YYYY-MM-DD')
;