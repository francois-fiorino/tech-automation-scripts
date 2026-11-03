/*
===============================================================================
SCRIPT: gc_blocks_received.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/gc_blocks_received.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Somar blocos CR/current recebidos por instância RAC.

FUNCIONAMENTO DETALHADO
  Une GV$SYSSTAT e GV$INSTANCE por INST_ID, filtra gc cr blocks received/gc current blocks received e soma VALUE por INSTANCE_NAME.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$SYSSTAT, GV$INSTANCE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não mede bytes, tempo ou requisições pendentes. Reinícios de instância reiniciam contadores; nome de instância não substitui identificação global de banco/container.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @gc_blocks_received.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  INSTANCE_NAME e BLOCKS_RECEIVED como soma acumulada de duas categorias.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Coluna NAME do filtro qualificada como SS.NAME, eliminando dependência de resolução quando versões adicionam colunas. Consulta mantida. 
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
   instance_name,
   sum(value) as blocks_received
from
   gv$sysstat ss
join
   gv$instance i
on 
  ss.inst_id=i.inst_id   
where
   ss.name in ('gc cr blocks received',
            'gc current blocks received')
group by
   instance_name
order by 
   instance_name;
            