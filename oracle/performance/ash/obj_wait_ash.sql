/*
===============================================================================
SCRIPT: obj_wait_ash.sql
CATEGORIA: Oracle / performance/ash
ORIGEM: Oracle Script Collection 2015 / _ash_scripts/obj_wait_ash.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relacionar objetos atuais a amostras ASH das últimas 24h disponíveis.

FUNCIONAMENTO DETALHADO
  Une CURRENT_OBJ# a DBA_OBJECTS.OBJECT_ID e soma WAIT_TIME+TIME_WAITED por nome/tipo/evento.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Confirmar direito de uso do Diagnostics Pack antes de consultar AWR/ASH.

OBJETOS, VIEWS E PACOTES
  V$ACTIVE_SESSION_HISTORY, DBA_OBJECTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Soma não representa duração total confiável. Sem OWNER/CON_ID na chave, homônimos podem se agregar. Objetos removidos ou sem mapeamento desaparecem; retenção pode ser menor que 24h.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @obj_wait_ash.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Nome, tipo, evento e soma histórica, decrescente.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  AWR/ASH pode consultar volume relevante e expor atividade de usuários.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Corpo original preservado, sem substituir por outra metodologia não homologada. 
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
select 
   obj.object_name,
   obj.object_type,
   ash.event,
   sum(ash.wait_time + ash.time_waited) wait_time
from 
   v$active_session_history ash,
   dba_objects              obj
where 
   ash.sample_time > sysdate -1 
and 
   ash.current_obj# = obj.object_id
group by 
   obj.object_name, 
   obj.object_type, 
   ash.event
order by 4 desc;
