/*
===============================================================================
SCRIPT: gc_ratio.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_grid_scripts/gc_ratio.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar razão acumulada de blocos perdidos para blocos current/CR servidos.

FUNCIONAMENTO DETALHADO
  Associa três ocorrências de GV$SYSSTAT por INST_ID e calcula A.VALUE/(B.VALUE+C.VALUE).

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$SYSSTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Nomes de estatísticas global cache são legados; confirmar existência e unidades na versão RAC. INNER JOIN omite instâncias se alguma estatística não existir. Contadores acumulados, não métricas do último intervalo. A interpretação do denominador servido é histórica; não é indicador direto de perda de pacote.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @gc_ratio.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  instance e três contadores de cache, seguidos da razão.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Removida vírgula indevida entre A.INST_ID e alias "instance", que era interpretado como coluna inexistente; NULLIF protege soma zero. 
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

/*  */
select a.inst_id "instance", a.value "global cache blocks lost",
b.value "global cache current blocks served",
c.value "global cache cr blocks served",
a.value/nullif(b.value+c.value,0) ratio
from gv$sysstat a, gv$sysstat b, gv$sysstat c
where a.name='global cache blocks lost' and
      b.name='global cache current blocks served' and
      c.name='global cache cr blocks served' and
      b.inst_id=a.inst_id and c.inst_id = a.inst_id
/

