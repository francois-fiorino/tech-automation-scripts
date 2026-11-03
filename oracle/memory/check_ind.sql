/*
===============================================================================
SCRIPT: check_ind.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / misc_scripts/check_ind.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Contar headers de buffer associados a índices no cache local.

FUNCIONAMENTO DETALHADO
  Relaciona X$BH.OBJ a DBA_OBJECTS.DATA_OBJECT_ID, filtra OBJECT_TYPE=INDEX e agrupa proprietário/nome.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Acesso administrativo autorizado aos objetos internos listados; conferir estrutura por versão.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_OBJECTS, X$BH

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não conta blocos únicos ou tamanho completo do índice; versões CR podem repetir bloco. Não inclui tipos INDEX PARTITION/SUBPARTITION. X$ e CON_ID precisam de validação por versão/container.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @check_ind.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OWNER.OBJECT_NAME e quantidade de headers de buffer.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  OBJECT_ID substituído por DATA_OBJECT_ID para associar o identificador físico usado por X$BH, incluindo objetos reconstruídos. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
rem check_ind.sql
rem FUNCTION: SHow which indexes are in the SGA
rem MRA
rem
ttitle 'Indexes in SGA'
spool check_ind.lst
select owner||'.'||object_name, count(*)
from dba_objects o, x$bh bh
where bh.obj = o.data_object_id
and o.object_type='INDEX'
group by owner,object_name;
spool off
ttitle off
