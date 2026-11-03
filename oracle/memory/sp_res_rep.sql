/*
===============================================================================
SCRIPT: sp_res_rep.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / misc_scripts/sp_res_rep.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar memória e falhas de alocação do reserved shared pool.

FUNCIONAMENTO DETALHADO
  Seleciona espaços/fragmentos médios e REQUEST_FAILURES/LAST_FAILURE_SIZE em V$SHARED_POOL_RESERVED.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SHARED_POOL_RESERVED

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não cobre toda SGA ou todas as causas de ORA-04031. Contadores são acumulados; ausência de falha não prova capacidade para qualquer pedido.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @sp_res_rep.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Espaço livre/usado, tamanhos médios, contadores de falha e tamanho da última falha, em bytes quando tamanho.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta preservada. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col free_space heading 'Free|Space'
col avg_free_size heading 'Average|Free|Size'
col used_space heading 'Used|Space'
col avg_used_size heading 'Average|Used|Size'
col request_failures heading 'Request|Failures'
col last_failure_size heading 'Last|Failure|Size'
set lines 132 pages 47
ttitle 'Shared Pool Reserved Space Report'
spool sp_res_rep.lst
select free_space,avg_free_size, used_space,
avg_used_size,request_failures,last_failure_size
from v$shared_pool_reserved
/
spool off
ttitle off
set lines 80 pages 22

