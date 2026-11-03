/*
===============================================================================
SCRIPT: parallel_sessions.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/parallel_sessions.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relacionar sessões PX a processos de sistema operacional por instância.

FUNCIONAMENTO DETALHADO
  Une GV$PX_SESSION a GV$SESSION por INST_ID/SID/SERIAL# e GV$PROCESS por INST_ID/PADDR=ADDR; mostra graus requerido/efetivo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$PX_SESSION, GV$SESSION, GV$PROCESS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  QCSID identifica coordenador junto de QCINST_ID, que não é exibido; INST_ID é da sessão PX. Grau pode variar ao longo da execução; não atribui plano ou SQL_ID.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @parallel_sessions.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  QCSID, SID, SPID, INST_ID, DEGREE e REQ_DEGREE.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Adicionada igualdade PS.SERIAL#=S.SERIAL# para evitar vínculo de SID reutilizado; ORDER BY qualificado com PS. 
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
   ps.qcsid,
   ps.sid,
   p.spid,
   ps.inst_id,
   ps.degree,
   ps.req_degree
from
   gv$px_session ps
   join
   gv$session s
      on ps.sid=s.sid
         and ps.serial#=s.serial#
         and
         ps.inst_id=s.inst_id
   join
   gv$process p
      on p.addr=s.paddr
         and
         p.inst_id=s.inst_id 
order by
   ps.qcsid,
   ps.server_group desc,
   ps.inst_id,
   ps.sid;
