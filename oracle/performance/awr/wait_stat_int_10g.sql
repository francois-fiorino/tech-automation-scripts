/*
===============================================================================
SCRIPT: wait_stat_int_10g.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _wait_event_scripts/wait_stat_int_10g.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Comparar contenção por classe de bloco entre dois snapshots AWR.

FUNCIONAMENTO DETALHADO
  Une DBA_HIST_WAITSTAT por DBID, instância e CLASS, aplicando snapshots informados; retorna aumento de WAIT_COUNT e TIME e média por espera.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_WAITSTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Oracle 10g+. Escolher snapshots da mesma inicialização e DBID, início menor que fim. INNER JOIN exclui classes ausentes no início; NVL não implementa baseline ausente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE pBgnSnap = 100
  DEFINE pEndSnap = 101
  DEFINE pDbId = 123456789
  DEFINE pInstNum = 1
  @wait_stat_int_10g.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Classe, Waits, Total Wait Time (cs), Avg Time (cs), ordenados por tempo e contagem.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Acrescentado terminador SQL ausente. Filtro de crescimento já protege divisão; não modificado. 
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
select e.class "E.CLASS"
     , e.wait_count  - nvl(b.wait_count,0)     "Waits"
     , e.time        - nvl(b.time,0)           "Total Wait Time (cs)"
     , (e.time       - nvl(b.time,0)) /
       (e.wait_count - nvl(b.wait_count,0)) "Avg Time (cs)"
  from dba_hist_waitstat b
     , dba_hist_waitstat e
 where b.snap_id         = &pBgnSnap
   and e.snap_id         = &pEndSnap
   and b.dbid            = &pDbId
   and e.dbid            = &pDbId
   and b.dbid            = e.dbid
   and b.instance_number = &pInstNum
   and e.instance_number = &pInstNum
   and b.instance_number = e.instance_number
   and b.class           = e.class
   and b.wait_count      < e.wait_count
 order by 3 desc, 2 desc;
