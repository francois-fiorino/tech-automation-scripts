/*
===============================================================================
SCRIPT: gv_sysstat.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_grid_scripts/gv_sysstat.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Calcular razões históricas de tempo CR por bloco servido.

FUNCIONAMENTO DETALHADO
  Une tempos de build, flush e send aos blocos CR servidos por INST_ID; calcula três razões acumuladas.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$SYSSTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Nomes de estatísticas global cache são legados; confirmar existência e unidades na versão RAC. INNER JOIN omite instâncias se alguma estatística não existir. Contadores acumulados, não métricas do último intervalo. Unidades permanecem as dos contadores originais por bloco; não aplicar conversão sem confirmar documentação.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @gv_sysstat.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Instance, Consistent Read Build, Log Flush Wait e Send Time.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Marca BOM removida e D.VALUE protegido por NULLIF nas três razões. BOM UTF-8 da origem normalizado sem inserir caracteres no SQL.
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

-- gv_sysstat.sql

SELECT
   A.inst_id "Instance",
   (A.value/nullif(D.value,0)) "Consistent Read Build",
   (B.value/nullif(D.value,0)) "Log Flush Wait",
   (C.value/nullif(D.value,0)) "Send Time"
FROM
  GV$SYSSTAT A,
  GV$SYSSTAT B,
  GV$SYSSTAT C,
  GV$SYSSTAT D
WHERE
  A.name = 'global cache cr block build time' AND
  B.name = 'global cache cr block flush time' AND
  C.name = 'global cache cr block send time' AND
  D.name = 'global cache cr blocks served' AND
  B.inst_id=a.inst_id AND
  C.inst_id=a.inst_id AND
  D.inst_id=a.inst_id
ORDER BY
  A.inst_id;

