/*
===============================================================================
SCRIPT: isvaldat.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/ISVALDAT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar função de validação de conversão de data com código 0/1.

FUNCIONAMENTO DETALHADO
  TO_DATE com máscara fornecida; retorna 0 se não gera erro e 1 no tratamento de exceção.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/execução e SELECT DIRETO conforme LIMITAÇÕES; roles
  podem não atender compilação de objetos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DUAL, TO_DATE; função ISVALIDDATE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE. NULL é aceito por TO_DATE e retorna 0; sem FX pode haver conversão flexível. OTHERS não distingue erro de máscara de data inválida.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @isvaldat.sql; testar chamadas com data válida, inválida e NULL.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Função compilada; código numérico de resultado.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cria/modifica objetos, dados, credenciais ou sessão
  conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  SELECT INTO variável DATE adicionado; OTHER corrigido para OTHERS; terminador / adicionado. Contrato 0/1 preservado. 
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
CREATE OR REPLACE FUNCTION IsValidDate (in_date varchar2, in_format varchar2)
RETURN INTEGER IS
rtn_code integer;
v_date date;
BEGIN
select to_date(in_date,in_format) into v_date from dual;
rtn_code:=0;
RETURN rtn_code;
EXCEPTION
When OTHERS then
rtn_code:=1;
RETURN rtn_code;
END;
/
