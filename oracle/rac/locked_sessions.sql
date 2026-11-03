/*
===============================================================================
SCRIPT: locked_sessions.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/locked_sessions.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Listar locks TX de recursos com pedidos pendentes no cluster.

FUNCIONAMENTO DETALHADO
  Filtra GV$LOCK por TYPE=TX e IDs de transações solicitadas; classifica REQUEST/BLOCK/LMODE.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$LOCK

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não constrói grafo completo nem identidade SID/SERIAL#. BLOCK=2 é candidato remoto, não prova local de bloqueio. Flags podem mudar durante leitura.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @locked_sessions.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Instância, SID, TYPE, ID1/ID2 e ACTION como Waiter/Blocker/Holder/Remote candidate.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Tipo TX incluído no filtro externo; detentor com LMODE>0 deixou de ser rotulado automaticamente Blocker. 
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
   inst_id,
   sid,
   type,
   id1,
   id2,
   case
   when request>0 then 'Waiter'
   when block=1 then 'Blocker'
   when block=2 then 'Remote candidate'
   when lmode>0 then 'Holder'
   else 'Other'
   end as action
from
   gv$lock
where
   type='TX' and (id1,id2) in (select
                    id1,
                    id2
                 from
                    gv$lock
                 where
                    type='TX'
                    and
                    request<>0)
order by
   id1,
   id2;