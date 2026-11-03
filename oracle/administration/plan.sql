/*
===============================================================================
SCRIPT: plan.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/PLAN.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir plano de PLAN_TABLE e depois limpar a tabela de planos.

FUNCIONAMENTO DETALHADO
  CONNECT BY a partir de ID=0 em OWNER.PLAN_TABLE, spool, TRUNCATE e abertura de editor com ED.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/execução e SELECT DIRETO conforme LIMITAÇÕES; roles
  podem não atender compilação de objetos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  PLAN_TABLE do owner, SQL*Plus ED; TRUNCATE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  TRUNCATE confirma transação e exige posse/privilégio. Múltiplos planos sem filtro podem cruzar nós. OWNER e editor devem ser controlados; não usar PLAN_TABLE compartilhada.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente tabela de planos descartável: DEFINE owner = HR
  @plan.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Relatório e edição local; todas as linhas de PLAN_TABLE são removidas após a consulta.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cria/modifica objetos, dados, credenciais ou sessão
  conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código completo preservado, inclusive limpeza e editor; esses efeitos impedem classificar como simples consulta. 
  Revisão estática somente; implantação depende de laboratório e aprovação do PR.
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
set lines 132 pages 47
COLUMN QUERY_PLAN FORMAT A80
column statement_id format a11 heading ID
spool ex_plan..lis
SELECT statement_id,
LPAD( '  ' , 2*LEVEL)||OPERATION||' '||options||' '||OBJECT_NAME||
' cost: '||cost ||' goal:'||optimizer QUERY_PLAN
FROM &&owner..PLAN_TABLE
CONNECT BY PRIOR ID = PARENT_ID
START WITH ID=0;
spool off
truncate table &&owner..plan_table;
ed ex_plan..lis
undef owner

