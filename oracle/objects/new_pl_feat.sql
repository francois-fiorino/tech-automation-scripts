/*
===============================================================================
SCRIPT: new_pl_feat.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/new_pl_feat.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Contar linhas de fonte que contêm palavras de recursos PL/SQL.

FUNCIONAMENTO DETALHADO
  Três ramos UNION agrupam owner/tipo para FORALL, BULK e NOCOPY, com zeros por COUNT(NULL) nos outros campos.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_SOURCE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não é parser: comentários/literais contam e uma linha pode conter mais de uma ocorrência. UNION mantém linhas separadas por recurso, não consolida necessariamente três campos por owner/tipo. Não comprova otimização efetiva.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @new_pl_feat.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner/tipo e contagens de linhas contendo cada fragmento.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Typo BULD BIND corrigido para BULK BIND; três ramos mantidos. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col owner format a15 heading 'Object Owner'
col type heading 'Object Type'
col num1 format 9,999,999 heading 'Times|FORALL|Used'
col num2 format 9,999,999 heading 'Times|BULK BIND|Used'
col num3 format 9,999,999 heading 'Times|NOCOPY|Used'
ttitle 'New PL/SQL Feature Usage'
spool new_pl_feat.lst
select a.owner, a.type,count(a.text) num1, count(NULL) num2, count(NULL) num3 
from 
    dba_source a
where
     upper(a.text) like '%FORALL%'
group by a.owner, a.type
union
select b.owner, b.type,count(null) num1, count(b.text) num2, count(NULL) num3 
from 
    dba_source b
where
     upper(b.text) like '%BULK%'
group by b.owner, b.type
UNION
select c.owner, c.type,count(null) num1, count(null) num2, count(c.text) num3 
from 
     dba_source c
where
     upper(c.text) like '%NOCOPY%'
group by 
   c.owner, c.type;
spool off
clear col
ttitle off
