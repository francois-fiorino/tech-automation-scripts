/*
===============================================================================
SCRIPT: get_hitratio.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/get_hitratio.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar razão acumulada de hits por buffer pool e estimativa histórica de buffers livres por instância.

FUNCIONAMENTO DETALHADO
  Calcula 1-PHYSICAL_READS/(DB_BLOCK_GETS+CONSISTENT_GETS) em GV$BUFFER_POOL_STATISTICS; subconsulta conta entradas GV$BH com FILE#=0 e multiplica pelo DB_BLOCK_SIZE por INST_ID.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$BUFFER_POOL_STATISTICS, GV$BH, GV$PARAMETER

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  GV$BH pode ser custosa em caches grandes. FREE_MEG usa hipótese legada FILE#=0 e tamanho padrão, não memória livre total nem por pool; repete por pool. INNER JOIN omite instâncias sem linhas na subconsulta. Hit ratio isolado não indica saúde.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @get_hitratio.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  INST_ID, POOL, HIT_RATIO como fração (multiplicar por 100 para percentual) e FREE_MEG.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF protege total de gets igual a zero; ORDER BY A.INST_ID elimina ambiguidade entre aliases A e B. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
ttitle 'Cummulative Hit Ratio'
spool get_hitratio.lst
select a.inst_id, a.name pool, (1-(a.physical_reads/nullif(a.db_block_gets+a.consistent_gets,0))) hit_ratio,
b.free_meg
from gv$buffer_pool_statistics a, (select d.inst_id, sum(decode(d.file#,0,1)*c.value)/(1024*1024) free_meg from gv$bh d, gv$parameter c where d.file#=0 and c.name='db_block_size' and d.inst_id=c.inst_id group by d.inst_id) b
where a.inst_id=b.inst_id 
order by a.inst_id
/
spool off
ttitle off
