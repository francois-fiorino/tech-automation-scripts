/*
===============================================================================
SCRIPT: hot_segments.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/hot_segments.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Classificar nomes de objetos pela soma histórica de estatísticas físicas de leitura/escrita.

FUNCIONAMENTO DETALHADO
  Lê GV$SEGMENT_STATISTICS com nomes physical%read% ou physical%write%, aplica exclusões de owners e soma VALUE por OWNER/OBJECT_NAME.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$SEGMENT_STATISTICS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  A seleção pode misturar blocos, requisições e subconjuntos de estatísticas, causando dupla contagem ou unidades incompatíveis. Não é IOPS nem soma física canônica; partições e instâncias agregadas. Não recomendar storage apenas por essa soma.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @hot_segments.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OWNER, OBJECT_NAME e TOTAL_IOS segundo a soma original.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Fórmula preservada e erro potencial de interpretação explicitado; redefinir a métrica exige revisão/homologação. CR isolados normalizados. 
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
   owner,
   object_name,
   sum(value) as total_ios
from 
   gv$segment_statistics
where
   (statistic_name like 'physical%read%'
    or statistic_name like 'physical%write%')
   and
   owner not in ('SYS','XDB','SYSTEM','APEX_030200','MDSYS',
        'WMSYS','DBSNMP','EXFSYS','AUDSYS','GSMADMIN_INTERNAL')
group by
   owner,
   object_name
order by
   sum(value) desc;
