/*
===============================================================================
SCRIPT: submit_flush.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/submit_flush.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Cadastrar job legado que chama FLUSH_IT periodicamente.

FUNCIONAMENTO DETALHADO
  DBMS_JOB.SUBMIT recebe bloco FLUSH_IT(85,10), data inicial atual e intervalo SYSDATE+1/8; COMMIT torna job persistente.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/alteração/execução e SELECT DIRETO conforme LIMITAÇÕES.
  Grants por role podem não valer para views/procedimentos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBMS_JOB, procedimento customizado FLUSH_IT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Exige permissões de job conforme versão e EXECUTE direto no procedimento. Efeitos de FLUSH_IT desconhecidos sem fonte; pode afetar shared pool. Não é simples relatório.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @submit_flush.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Bind :X com número do job; execução poderá ocorrer após COMMIT e repetir a cada três horas.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PROPOSTA DE REVISÃO: o código pode modificar objetos, dados, jobs,
  arquivos ou sessão, conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código preservado; valores/agenda e COMMIT explicitados. 
  Revisão estática somente; implantação depende de testes e aprovação do PR.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 044 — 04/11/2026
  Correções e melhorias: Agenda de3horas eCOMMIT preservados.
  Limitações e pendências: DBMS_JOB dispara após confirmação; nova execução do arquivo cria outro job e COMMIT confirma transação do chamador. FLUSH_IT85/10 depende de definição compatível, não equivale a chamada85/100.
  Homologação necessária: Revisar rotina/grants/usuárioexecutor, duplicidade de job e intervalo; não agendar nesta revisão.
  Parâmetros/execução: contratos descritos acima e no corpo; somente laboratório.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  submissão de jobs, backup/recovery, Shell/Windows/VMS ou coleta de credenciais.

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
var x number;
begin
dbms_job.submit(:x,'begin flush_it(85,10); end;',sysdate,'sysdate+1/8');
commit;
end;
/
