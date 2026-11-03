/*
===============================================================================
SCRIPT: con_owner.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/con_owner.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Contar constraints por owner/tipo após exclusões históricas.

FUNCIONAMENTO DETALHADO
  Agrupa DBA_CONSTRAINTS com DECODE de P/R/C/U/V e soma contagem.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_CONSTRAINTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CHECK inclui NOT NULL; Other reúne tipos não mapeados. Lista de owners pode ocultar dados de componentes. Não avalia status ou VALIDATED.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @con_owner.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Owner, classe de constraint e quantidade.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Tipo V traduzido para View Check Option em vez de Enabled, que era interpretação incorreta; demais grupos preservados. 
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
column constraint_type format a25 heading 'Constraint|Type'
column owner format a24 heading 'Constraint|Owner'
column num format 9,999 heading 'Number'
break on owner
set pages 54 lines 80 verify off feedback off
spool con_owner
ttitle 'Constraints by Owner'
select 
   owner, 
   decode(
          constraint_type, 'P','Primary Key',
          'R','Foreign Key',
          'C','Check',
          'U','Unique',
          'V','View Check Option','Other') Constraint_type,
   count(*) Num
from dba_constraints
where owner not in ('SYS','SYSTEM','SCOTT','SYSMAN','ORDSYS','CTXSYS','ODM',
 'XDB','RMAN','ODSYS','CTXSYS','MDSYS','WKSYS','WMSYS')
group by 
     owner, decode(
          constraint_type, 'P','Primary Key',
          'R','Foreign Key',
          'C','Check',
          'U','Unique',
          'V','View Check Option','Other')
/
spool off
set verify on feedback on
clear columns
clear breaks
ttitle off
