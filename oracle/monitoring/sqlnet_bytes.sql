/*
===============================================================================
SCRIPT: sqlnet_bytes.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / misc_scripts/sqlnet_bytes.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Calcular bytes acumulados por roundtrip SQL*Net entre cliente e banco.

FUNCIONAMENTO DETALHADO
  Relaciona três estatísticas por nome e apresenta razões de total enviado+recebido, enviado e recebido.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SYSSTAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Contadores globais acumulados não medem banda, latência ou sessão individual. Não mede toda rede RAC/Data Guard. Estatísticas podem não refletir custos em camada física.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @sqlnet_bytes.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Três médias em bytes por roundtrip; NULL sem roundtrips.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF nos três divisores e grafia received corrigida. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
ttitle 'SQLNet Byte report'
spool sqlnet_bytes.lst
select 'Bytes per roundtrip', (a.value+b.value)/nullif(c.value,0) BPRT
from
v$sysstat a, v$sysstat b, v$sysstat c
where
a.name='bytes sent via SQL*Net to client'
and b.name='bytes received via SQL*Net from client'
and c.name='SQL*Net roundtrips to/from client'
union
select 'Bytes sent per trip', a.value/nullif(c.value,0) 
from
v$sysstat a, v$sysstat c
where
a.name='bytes sent via SQL*Net to client'
and c.name='SQL*Net roundtrips to/from client'
union
select 'Bytes received per Trip', b.value/nullif(c.value,0)
from
v$sysstat b, v$sysstat c
where
b.name='bytes received via SQL*Net from client'
and c.name='SQL*Net roundtrips to/from client'
/
spool off
