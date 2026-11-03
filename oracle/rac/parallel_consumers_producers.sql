/*
===============================================================================
SCRIPT: parallel_consumers_producers.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/parallel_consumers_producers.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Identificar conjuntos de processos PX e classificá-los pela convenção histórica de SERVER_SET.

FUNCIONAMENTO DETALHADO
  Lê GV$PX_SESSION com QCSID, SID, INST_ID, SERVER_GROUP/SET e SERVER#; rotula set 1 como Producer, 2 como Consumer e NULL como QC.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$PX_SESSION

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Produtor/consumidor depende do plano e fluxo; classificação pelo set é convenção, não prova de direção em todas as fases. QCSID pode repetir entre nós; QCINST_ID não está na saída.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @parallel_consumers_producers.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Coordenador SID, processo SID/instância, grupo, SLAVE_TYPE e número do servidor PX.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  CASE simples WHEN NULL nunca correspondia; alterado para CASE pesquisado com SERVER_SET IS NULL, preservando NULL para valores não mapeados. 
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
   qcsid,
   sid,
   inst_id,
   server_group,
   case
      when server_set=1 then 'Producer'
      when server_set=2 then 'Consumer'
      when server_set is null then 'QC'
   end as slave_type,
   server#
from
   gv$px_session
order by
   qcsid,
   server_group desc,
   inst_id,
   server_set,
   server#;