/*
===============================================================================
SCRIPT: undoc.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/UNDOC.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar nomes e valores de sessão de parâmetros iniciados por underscore.

FUNCIONAMENTO DETALHADO
  Une SYS.X$KSPPI a SYS.X$KSPPCV por INDX e filtra prefixo underscore literal usando ESCAPE.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Acesso administrativo autorizado aos objetos internos listados; conferir estrutura por versão.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.X$KSPPI, SYS.X$KSPPCV

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Tabelas internas sem contrato estável; exige acesso administrativo e validação de colunas por versão/CON_ID. Não altera parâmetros nem recomenda mudanças; valores podem ser sensíveis.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @undoc.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Parameter, Value e KSPPIDF como alias histórico de ISDEFAULT.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Colunas antigas KSPPIVL/KSPPIDF de KSPPI substituídas por KSPPSTVL/KSPPSTDF na tabela de valores de sessão; alias de saída preservado. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
column parameter format a40
column value format a30
column ksppidf heading 'Is|Default'
set feedback off verify off pages 55
ttitle 'Undocumented Init.ora Parameters'
spool undoc.lst
select  p.KSPPINM "Parameter",
  c.KSPPSTVL "Value",
  c.KSPPSTDF KSPPIDF
   from sys.x$ksppi p join sys.x$ksppcv c on p.indx=c.indx
where p.ksppinm like '/_%' escape '/'
/
spool off
ttitle off
