/*
===============================================================================
SCRIPT: get_cond.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/get_cond.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar função que retorna condição de constraint por nome/proprietário.

FUNCIONAMENTO DETALHADO
  SELECT SEARCH_CONDITION em USER_CONSTRAINTS para variáveis upper-case e retorna VARCHAR2.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/alteração/execução e SELECT DIRETO conforme LIMITAÇÕES.
  Grants por role podem não valer para views/procedimentos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  USER_CONSTRAINTS; função GET_COND

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Exige CREATE PROCEDURE e privilégios diretos; SEARCH_CONDITION LONG e buffer de 2000 limitam tamanho. Pode gerar NO_DATA_FOUND/TOO_MANY_ROWS e erro para condições longas; identificadores quoted ficam limitados por UPPER.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @get_cond.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Função compilada; retorno de condição de CHECK ou NULL conforme constraint.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PROPOSTA DE REVISÃO: o código pode modificar objetos, dados, jobs,
  arquivos ou sessão, conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta original USER_CONSTRAINTS restaurada após conferir Oracle Database Reference: a view contém OWNER. A mudança anterior para ALL_CONSTRAINTS era desnecessária e alterava o escopo. 
  Revisão estática somente; implantação depende de testes e aprovação do PR.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 043 — 04/11/2026
  Correções e melhorias: Buffer de condição ampliado de2000 para32767; escopo USER_CONSTRAINTS preservado.
  Limitações e pendências: LONG continua limitado ao buffer/retornoVARCHAR2 e ao contexto SQL/PLSQL. OWNER não amplia USER_* para outro schema; UPPER não resolve quoted mixed case. NO_DATA_FOUND preservado.
  Homologação necessária: Condição2001/32767/maior, outro owner, nomequoted e constraint sem condição; não declarar suporte a todo LONG.
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
create or replace function get_cond(con_name varchar2, owner_name varchar2)
return varchar2 as
ser_cond varchar2(32767);
begin
select search_condition into ser_cond from user_constraints
where constraint_name=upper(con_name) and owner=upper(owner_name);
return ser_cond;
end;
/
