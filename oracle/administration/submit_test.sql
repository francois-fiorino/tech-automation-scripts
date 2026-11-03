/*
===============================================================================
SCRIPT: submit_test.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/submit_test.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Cadastrar job diário para o procedimento customizado SUBMIT_CHECKS.

FUNCIONAMENTO DETALHADO
  Submete chamada com proprietário informado, data TRUNC(SYSDATE), intervalo TRUNC(SYSDATE+1) e confirma transação.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/alteração/execução e SELECT DIRETO conforme LIMITAÇÕES.
  Grants por role podem não valer para views/procedimentos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBMS_JOB, SUBMIT_CHECKS(OWNER_NAME)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Dependências customizadas devem estar compiladas e autorizadas; job pode executar verificações/flushes. Conferir janela e usuário executor antes de agendar.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: DEFINE owner = HR
  @submit_test.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Job persistente com número em :X; primeira data pode já ter passado e tornar execução imediata.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PROPOSTA DE REVISÃO: o código pode modificar objetos, dados, jobs,
  arquivos ou sessão, conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Chamada sem argumento corrigida para passar OWNER_NAME, obrigatório na definição da coleção; nenhuma submissão realizada. 
  Revisão estática somente; implantação depende de testes e aprovação do PR.
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
var x number;
begin
dbms_job.submit(:x,'begin submit_checks(''&&owner''); end;',trunc(sysdate),'trunc(sysdate+1)');
commit;
end;
/
