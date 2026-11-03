/*
===============================================================================
SCRIPT: hanging.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/HANGING.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Identificar objetos dependentes com timestamp diferente do objeto referenciado.

FUNCIONAMENTO DETALHADO
  Une OBJ$ ao objeto pai em DEPENDENCY$ e ao dependente; filtra STIME diferente de P_TIMESTAMP e dependente STATUS<>5.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.OBJ$, SYS.DEPENDENCY$

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Tabelas internas não documentadas: campos e significado de STATUS variam. Não diagnostica sessão travada nem garante necessidade de recompilar. Nenhum ALTER COMPILE é executado.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @hanging.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Número interno, nome e owner numérico dos objetos dependentes identificados.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta histórica preservada; interpretação de hanging corrigida na documentação. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior. Wrapper de título com aspas duplas substituído por TTITLE local.
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
rem
rem FUNCTION: Report objects that need to be recompiled
rem FUNCTION: because they may be hanging
rem FUNCTION: run from SYS only
rem
ttitle "Objects that need Recompilation"
column obj# heading Object|Number
column name heading Object|Name
column owner# heading Owner|Number
spool hanging.lst
select distinct o2.obj#,o2.name, o2.owner#
from sys.obj$ o,
     sys.dependency$ d,
     sys.obj$ o2
where o.obj# = d.p_obj#
and o.stime != d.p_timestamp
and d.d_obj# = o2.obj#
and o2.status != 5
order by o2.obj#
/
spool off
clear columns
ttitle off
