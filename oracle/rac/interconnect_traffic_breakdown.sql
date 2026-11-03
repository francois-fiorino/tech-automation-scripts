/*
===============================================================================
SCRIPT: interconnect_traffic_breakdown.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/interconnect_traffic_breakdown.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar tráfego acumulado por cliente interno do interconnect.

FUNCIONAMENTO DETALHADO
  Consulta SYS.X$KSXPCLIENT, converte bytes enviados/recebidos em MiB truncados e calcula participação no total com soma analítica.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Acesso administrativo autorizado a SYS.X$KSXPCLIENT; conferir campos na versão antes de usar.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.X$KSXPCLIENT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Tabela fixa não documentada: privilégios administrativos e validação por versão são necessários. Não mede taxa, latência ou tráfego por link físico; contadores podem ter ciclos próprios.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @interconnect_traffic_breakdown.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  NAME, MB_SENT, MB_RECV, MB_TOTAL em MiB e TOTAL_PERC formatado.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF protege soma analítica zero; ORDER BY usa bytes totais numéricos em vez de texto de percentual. 
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
   name,
   trunc(bytes_sent/1024/1024) as mb_sent,
   trunc(bytes_rcv/1024/1024) as mb_recv,
   trunc((bytes_sent+bytes_rcv)/1024/1024) as mb_total,
   to_char(round(100*(((bytes_sent+bytes_rcv)/1024/1024)/
      nullif(sum((bytes_sent+bytes_rcv)/1024/1024) over (),0)),2),'990.00') as total_perc
from
   sys.x$ksxpclient
order by
   (bytes_sent+bytes_rcv) desc;