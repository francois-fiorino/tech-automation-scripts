/*
===============================================================================
SCRIPT: slow_sql.sql
CATEGORIA: Oracle / performance/ash
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/slow_sql.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Encontrar execuções amostradas cuja duração observada ultrapassa limiar.

FUNCIONAMENTO DETALHADO
  Filtra ASH por USER_ID=93 e SQL_EXEC_ID não nulo; calcula diferença amostra/início, agrupa execução e exige MAX(TM)>EXEC_TIME.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  V$ACTIVE_SESSION_HISTORY

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não garante que execução ainda esteja ativa: ELA_TM pode incluir tempo após término. USER_ID fixo é exemplo. Agrupamento sem SID/SERIAL# pode mesclar execuções coincidentes; retenção e amostragem limitam cobertura.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE exec_time = 60
  @slow_sql.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  SQL_ID, SQL_EXEC_ID/START, TM observado e ELA_TM desde início até agora, em segundos.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código integral preservado; não apresentado como medição exata de elapsed runtime. 
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
   sql_id,
   sql_exec_id,
   sql_exec_start,
   max(tm) tm,
   (sysdate-sql_exec_start) * 3600*24 ela_tm
from 
   (select 
      sql_id,
      sql_exec_id,
      sql_exec_start,
      ( ( Cast(sample_time AS DATE) ) -
            ( Cast(sql_exec_start AS DATE) ) ) * ( 3600 * 24 ) tm
    from   
      v$active_session_history
    where  
      sql_exec_id is not null
    and 
      user_id=93
       )
   group by 
      sql_id,
      sql_exec_id,
     sql_exec_start
   having 
      max(tm) > &exec_time
order by 
   sql_exec_start;
