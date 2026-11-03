/*
===============================================================================
SCRIPT: reads_10g.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _i_o_scripts/reads_10g.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar razões legadas de tempo global cache e conversões expiradas por instância.

FUNCIONAMENTO DETALHADO
  Une cinco ocorrências de GV$SYSSTAT por INST_ID; divide tempos de conversão/get pelas contagens correspondentes e exibe timeouts.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$SYSSTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Nomes global cache convert/get são legados e podem estar ausentes; INNER JOIN então não retorna instância. Não substituir por estatísticas gc atuais sem revisar semântica.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @reads_10g.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Instance, Avg Cache Conv. Time, Avg Cache Get Time e GC Convert Timeouts. Razões acumuladas, unidades conforme estatística da versão.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF aplicado aos denominadores B.VALUE e D.VALUE. 
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

-- cache_conv.sql

select
  a.inst_id "Instance",
  a.value/nullif(b.value,0) "Avg Cache Conv. Time",
  c.value/nullif(d.value,0) "Avg Cache Get Time",
  e.value "GC Convert Timeouts"
from
   GV$SYSSTAT A,
   GV$SYSSTAT B,
   GV$SYSSTAT C,
   GV$SYSSTAT D,
   GV$SYSSTAT E
where
  a.name='global cache convert time' and
  b.name='global cache converts' and
  c.name='global cache get time' and
  d.name='global cache gets' and
  e.name='global cache convert timeouts' and
  b.inst_id=a.inst_id and
  c.inst_id=a.inst_id and
  d.inst_id=a.inst_id and
  e.inst_id=a.inst_id
order by
  a.inst_id;
