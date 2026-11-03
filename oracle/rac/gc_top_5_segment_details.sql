/*
===============================================================================
SCRIPT: gc_top_5_segment_details.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/gc_top_5_segment_details.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Detalhar estatísticas gc dos cinco pares owner/nome com maior soma.

FUNCIONAMENTO DETALHADO
  Agrupa GV$SEGMENT_STATISTICS por owner/nome para top cinco e retorna soma de cada estatística gc desses pares.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$SEGMENT_STATISTICS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Soma estatísticas gc de naturezas diferentes para ranking: heurística, não DB time. Junta partições/subobjetos com mesmo nome; CON_ID pode exigir filtro multitenant. Retenção é acumulada/volátil, não janela.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @gc_top_5_segment_details.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner/nome, statistic_name e total_value entre instâncias.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta integral preservada com limitações de agrupamento e unidade explícitas. 
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
   top5.owner,
   top5.object_name,
   stats.statistic_name,
   sum(stats.value) as total_value
from (
      select 
         owner,
         object_name
      from (
         select 
            owner,
            object_name,
            sum(value)
         from 
            gv$segment_statistics
         where 
            statistic_name like 'gc%'
         group by 
            owner,
            object_name
         order by 
            sum(value) desc)
      where 
         rownum <= 5) top5
join
   gv$segment_statistics stats
on top5.owner = stats.owner
   and
   top5.object_name = stats.object_name
where 
   stats.statistic_name like 'gc%'
group by
   top5.owner,
   top5.object_name,
   stats.statistic_name
order by
   top5.owner,
   top5.object_name,
   stats.statistic_name;