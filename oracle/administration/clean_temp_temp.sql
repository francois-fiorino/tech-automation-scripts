/*
===============================================================================
SCRIPT: clean_temp_temp.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/clean_temp_temp.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exemplo legado de evento interno para remoção de segmentos temporários.

FUNCIONAMENTO DETALHADO
  ALTER SESSION SET EVENTS aciona IMMEDIATE TRACE NAME DROP_SEGMENTS com nível &X.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/alteração/execução e SELECT DIRETO conforme LIMITAÇÕES.
  Grants por role podem não valer para views/procedimentos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  Mecanismo interno de eventos Oracle

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  ALTO: evento não documentado e nível calculado por regra histórica TS#+1 não deve ser aplicado em versões atuais sem orientação específica. Pode causar indisponibilidade/perda. Sem suporte de compatibilidade garantido.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Não executar. Revisar com Oracle Support e reproduzir apenas em ambiente descartável.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Efeito interno de remoção de segmentos; não há resultado tabular.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PROPOSTA DE REVISÃO: o código pode modificar objetos, dados, jobs,
  arquivos ou sessão, conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Comando histórico preservado somente para revisão; nunca executado. 
  Revisão estática somente; implantação depende de testes e aprovação do PR.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 042 — 04/11/2026
  Correções e melhorias: Bloqueio EXIT incondicional antes do evento interno.
  Limitações e pendências: DROP_SEGMENTS e regra TS#+1 não possuem garantia de segurança/compatibilidade moderna; comando histórico permanece abaixo apenas para inspeção com suporte do fabricante.
  Homologação necessária: Verificar barreira antes do ALTER SESSION; não executar evento ou fornecer nível em banco real.
  Parâmetros e execução: contratos descritos acima e no corpo histórico.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  backup/recovery, comandos Windows/Unix ou uso de credenciais reais.

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
PROMPT BLOQUEADO: evento interno DROP_SEGMENTS; somente revisao.
EXIT FAILURE ROLLBACK


/*  */
rem Used to clean up temp segments in temporary tablespace
rem x is the temp tablespace number in TS$ plus 1
rem
ALTER SESSION SET EVENTS 'IMMEDIATE TRACE NAME DROP_SEGMENTS LEVEL &x';
