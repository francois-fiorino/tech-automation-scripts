/*
===============================================================================
SCRIPT: disk_mem.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/disk_mem.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Calcular razão entre contadores customizados de sorts em disco e em memória.

FUNCIONAMENTO DETALHADO
  Une duas ocorrências de DBA_RUNNING_STATS pela mesma MEAS_DATE, filtra nomes sorts (disk)/sorts (memory) e calcula A.VALUE/B.VALUE*100 após dia inclusivo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_RUNNING_STATS (objeto customizado)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Razão disk/memory não é disk/(disk+memory), pode exceder 100. Exige no máximo uma medida por nome/data para não multiplicar linhas. Máscara de data tem língua de mês e vírgula decimal NLS pode afetar exportação.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE dd_mon_yy = 03-NOV-26
  @disk_mem.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Texto separado por vírgulas com razão percentual e data; NULL/valor vazio quando denominador zero.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF protege VALUE zero; máscara numérica TO_CHAR passada como literal entre aspas em vez de número convertido implicitamente. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
set pages 0 lines 80
ttitle 'Disk to Memory Sorts Percent'
spool disk_mem.lst
ttitle off
set pages 0 lines 80 heading off
select 
'Disk to memory Sorts percent'||','||to_char((a.value/nullif(b.value,0))*100,'999.9999')||','||to_char(a.meas_date,'dd-mon-yy hh24:mi')
from dba_running_stats a, dba_running_stats b where a.name = 'sorts (disk)' and
b.name='sorts (memory)' and a.meas_date=b.meas_date
and trunc(a.meas_date)>=to_date('&dd_mon_yy','dd-mon-yy')
order by a.meas_date
/
spool off
set echo off
