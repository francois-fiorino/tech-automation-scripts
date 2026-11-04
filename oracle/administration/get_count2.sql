/*
===============================================================================
SCRIPT: get_count2.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/get_count2.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar função GET_COUNT para contagem exata por objeto informado.

FUNCIONAMENTO DETALHADO
  DBMS_SQL abre/parseia SELECT COUNT, define coluna, executa, faz FETCH_ROWS e lê resultado; fecha cursor inclusive em erro.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/execução e SELECT DIRETO conforme LIMITAÇÕES; roles
  podem não atender compilação de objetos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBMS_SQL, DBMS_ASSERT.SQL_OBJECT_NAME; função GET_COUNT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE, EXECUTE direto e direitos de leitura no alvo. Varredura pode ser cara; definer rights exige avaliar quem recebe EXECUTE. Oracle 10.2+ para DBMS_ASSERT. Alternativa incompatível com procedimento homônimo GET_COUNT.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @get_count2.sql; testar tabela pequena e nome inválido.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Número de linhas; função criada/substituída.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cria/modifica objetos, dados, credenciais ou sessão
  conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Nome validado com DBMS_ASSERT, ; removido do SQL dinâmico, FETCH_ROWS adicionado, buffer ampliado e limpeza em exceção sem ocultar erro. 
  Revisão estática somente; implantação depende de laboratório e aprovação do PR.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 043 — 04/11/2026
  Correções e melhorias: AUTHID CURRENT_USER evita emprestar SELECT do definidor; NATIVE e cursor inicializado; contagem NUMBER.
  Limitações e pendências: DBMS_ASSERT valida nome, não autorização. COUNT exato pode fullscan; função GET_COUNT é alternativa incompatível com procedimento homônimo e depende de grants do invocador.
  Homologação necessária: Nome inválido/quoted, ausência deSELECT, tabela vazia, cursor em erro e número além de inteiro32; não instalar sobre variante sem decisão.
  Parâmetros/execução: contratos acima e corpo histórico; somente laboratório.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral/análise estática; sem compilação ou execução Oracle,
  Windows, escrita de arquivo no servidor, backup/recovery ou alteração de contas.

AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de qualquer utilização em produção. Sua execução é de responsabilidade do profissional responsável pelo ambiente. Os mantenedores deste repositório não se responsabilizam por indisponibilidade, perda de dados, alterações indevidas ou outros impactos decorrentes de sua utilização.

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
create or replace function get_count (tab_name varchar2) return number AUTHID CURRENT_USER as
cur integer := NULL;
sql_text varchar2(32767);
rowcount NUMBER;
row_proc integer;
BEGIN
    cur:=dbms_sql.open_cursor;
    sql_text:='select count(1) rowcount from '||dbms_assert.sql_object_name(tab_name);
    dbms_sql.parse(cur,sql_text,dbms_sql.NATIVE);
    dbms_sql.define_column(cur,1,rowcount);
    row_proc:=dbms_sql.execute(cur);
    row_proc:=dbms_sql.fetch_rows(cur);
    dbms_sql.column_value(cur,1,rowcount);
    dbms_sql.close_cursor(cur);
    return rowcount;
exception
 when others then
  if cur is not null and dbms_sql.is_open(cur) then dbms_sql.close_cursor(cur); end if;
  raise;
end;
/
