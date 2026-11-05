/*
===============================================================================
SCRIPT: def.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/def.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Executar COALESCE em seis tablespaces nomeados no exemplo.

FUNCIONAMENTO DETALHADO
  Seis ALTER TABLESPACE COALESCE para UNDOTBS1/PERFSTAT/SYSAUX/USERS/SYSTEM/EXAMPLE.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/execução e SELECT DIRETO conforme LIMITAÇÕES; roles
  podem não atender compilação de objetos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  Tablespaces literais, ALTER TABLESPACE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Exige ALTER TABLESPACE e confirma transações. Coalescência manual é conceito legado de DMT e pode não ter efeito/relevância em LMT; não é defrag geral de banco.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Não executar em produção; revisar nomes e método de gerenciamento em laboratório.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  DDL executadas ou erros de objeto/compatibilidade.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cria/modifica objetos, dados, credenciais ou sessão
  conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Controle form-feed inicial removido; comandos e nomes preservados para revisão. 
  Revisão estática somente; implantação depende de laboratório e aprovação do PR.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 043 — 04/11/2026
  Correções e melhorias: Seis COALESCE literais preservados em ordem.
  Limitações e pendências: Inclui SYSTEM/SYSAUX/UNDO e não verifica DMT/ONLINE; não é defrag físico geral nem recomendação LMT. DDL confirma trabalho do chamador.
  Homologação necessária: Confirmar nomes/tipos/estado no catálogo e escopo autorizado; não executar lista como manutenção genérica.
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

alter tablespace UNDOTBS1 coalesce;                                             
alter tablespace PERFSTAT coalesce;                                             
alter tablespace SYSAUX coalesce;                                               
alter tablespace USERS coalesce;                                                
alter tablespace SYSTEM coalesce;                                               
alter tablespace EXAMPLE coalesce;                                              
