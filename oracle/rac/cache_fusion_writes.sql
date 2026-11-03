/*
===============================================================================
SCRIPT: cache_fusion_writes.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_grid_scripts/cache_fusion_writes.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Calcular razão histórica entre escritas de cache fusion e escritas físicas.

FUNCIONAMENTO DETALHADO
  Relaciona em GV$SYSSTAT o nome literal DBWR XE "DBWR" fusion writes com physical writes e divide os valores por instância.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$SYSSTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Nomes de estatísticas global cache são legados; confirmar existência e unidades na versão RAC. INNER JOIN omite instâncias se alguma estatística não existir. Contadores acumulados, não métricas do último intervalo. O literal original contém espaço não separável e grafia atípica; pode não corresponder a nenhum NAME. Não foi substituído por outra estatística sem prova de equivalência.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @cache_fusion_writes.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Instance e Cache Fusion Writes Ratio como fração, quando ambos os nomes forem encontrados.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  B.VALUE protegido por NULLIF; literal da estatística mantido e sinalizado para validação. 
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

-- cache_fusion_writes.sql

SELECT
a.inst_id "Instance",
A.VALUE/nullif(B.VALUE,0) "Cache Fusion Writes Ratio"
FROM
  GV$SYSSTAT A,
  GV$SYSSTAT B
WHERE
      a.name='DBWR XE "DBWR"  fusion writes'
  AND b.name='physical writes'
  AND b.inst_id=a.inst_id
ORDER BY
  A.INST_ID;