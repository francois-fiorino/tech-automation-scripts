/*
===============================================================================
SCRIPT: service_io_stats.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/service_io_stats.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Agregar estatísticas físicas de I/O por serviço no cluster.

FUNCIONAMENTO DETALHADO
  Consulta GV$SERVICE_STATS com STAT_NAME LIKE physical%, exclui SERVICE_NAME LIKE SYS% e soma VALUE por serviço/estatística.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$SERVICE_STATS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não soma entre nomes diferentes e não é IOPS. Filtro SYS% também pode excluir serviço customizado com esse prefixo. Estatísticas acumuladas podem reiniciar com instância/serviço.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @service_io_stats.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  SERVICE_NAME, STAT_NAME e TOTAL_VAL; unidade depende do nome da estatística.

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

select
   service_name,
   stat_name,
   sum(value) as total_val
from
   gv$service_stats
where
   stat_name like 'physical%'
   and
   service_name not like 'SYS%'
group by
   service_name,
   stat_name
order by
   service_name,
   stat_name;
