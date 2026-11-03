/*
===============================================================================
SCRIPT: data_blk_waits.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/data_blk_waits.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exportar série customizada de esperas de bloco de dados após um dia informado.

FUNCIONAMENTO DETALHADO
  Filtra DBA_RUNNING_STATS pelo nome data block waits e TRUNC(MEAS_DATE)>dia; concatena NAME, VALUE, DELTA e MEAS_DATE com vírgulas, ordenando por data real.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_RUNNING_STATS (objeto customizado)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Objeto/coletor não são padrão Oracle. DD-MON-YY depende da língua de mês; números podem conter vírgula decimal em NLS, portanto saída não é CSV robusto. Não alterar dados nem presumir unidade.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE dd_mon_yy = 03-NOV-26
  @data_blk_waits.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Linhas separadas por vírgulas; VALUE e DELTA conforme coletor. Dia informado é excluído integralmente pelo operador > sobre TRUNC.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta preservada; formato histórico e exclusão do dia documentados. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
set pages 0 lines 80 heading off feedback off verify off
ttitle ''
ttitle off
set pages 0 lines 80 heading off feedback off verify off
spool data_blk_waits.lst
select 
name||','||to_char(value)||','||to_char(delta)||','||to_char(meas_date,'dd-mon-yy hh24:mi')
from dba_running_stats where name ='data block waits' 
and trunc(meas_date)>to_date('&dd_mon_yy','dd-mon-yy')
order by meas_date
/
spool off
