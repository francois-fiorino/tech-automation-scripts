/*
===============================================================================
SCRIPT: excessive_undo_log_usage.sql
CATEGORIA: Oracle / performance/awr
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/excessive_undo_log_usage.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Obter textos dos SQLs de maior duração em intervalos AWR com alto consumo de undo.

FUNCIONAMENTO DETALHADO
  Ordena DBA_HIST_UNDOSTAT por UNDOBLKS e MAXQUERYLEN, seleciona dez intervalos e busca SQL_TEXT pelo par DBID/MAXQUERYSQLID em DBA_HIST_SQLTEXT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  DBA_HIST_UNDOSTAT, DBA_HIST_SQLTEXT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  MAXQUERYSQLID identifica a consulta de maior duração, não necessariamente quem gerou o undo. Top 10 é global sobre histórico retido, sem período ou instância fixados; empate no corte não é determinístico.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @excessive_undo_log_usage.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  SQL_TEXT dos identificadores presentes nos dez intervalos selecionados; múltiplos intervalos podem apontar ao mesmo SQL.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Delimitadores ? inválidos nas datas substituídos por aspas; aliases BEGIN/END trocados por nomes válidos; vínculo inclui DBID para não cruzar SQLs de bancos diferentes. 
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
   sql_text 
from 
   dba_hist_sqltext 
where 
  (dbid,sql_id) in 
  (select distinct dbid,maxquerysqlid from 
    (select * from 
      (select 
        dbid, snap_id,
        maxquerylen,
        undoblks,
        maxquerysqlid, 
        to_char(begin_time,'yyyy/mm/dd hh24:mi') begin_time_display, 
        to_char(end_time,'yyyy/mm/dd hh24:mi') end_time_display 
       from 
        dba_hist_undostat 
       order by 
        undoblks desc, 
        maxquerylen desc
      ) 
   where rownum<11
  )
);