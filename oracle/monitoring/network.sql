/*
===============================================================================
SCRIPT: network.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / misc_scripts/network.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Combinar estatísticas de parallel query e filas/ocupação de dispatchers.

FUNCIONAMENTO DETALHADO
  UNION de V$PQ_SYSSTAT com proporção BUSY/(BUSY+IDLE) por rede e espera média WAIT/TOTALQ das filas DISPATCHER.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$PQ_SYSSTAT, V$DISPATCHER, V$QUEUE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não mede throughput de rede. Contadores acumulados e shared server precisa estar configurado para filas relevantes. UNION pode eliminar linhas iguais.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @network.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  STATISTIC e valor textual; unidades variam por conjunto, busy em fração e espera em centésimos de segundo.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  GROUP BY NETWORK adicionado à proporção; alias inválido em GROUP BY removido; denominador protegido e referência à view PQ sem schema incorreto. 
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
select statistic,to_char(value) from v$pq_sysstat
union
select network "Statistic",to_char(sum(busy)/nullif(sum(busy)+sum(idle),0)) "Value"
from v$dispatcher
group by network
union
select network "Statitistic",
decode(sum(totalq), 0, 'No Responses',
sum(wait)/sum(totalq)||' hundreths of seconds')
from v$queue q, v$dispatcher d
where q.type='DISPATCHER'
and q.paddr=d.paddr
group by network; 
