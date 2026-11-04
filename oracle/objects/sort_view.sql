/*
===============================================================================
SCRIPT: sort_view.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/SORT_view.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar view SORTERS de sessões com uso de segmentos temporários.

FUNCIONAMENTO DETALHADO
  Une SESSION a SORT_USAGE por endereço e SQLAREA por endereço/hash do SQL da sessão.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION, V$SORT_USAGE, V$SQLAREA; view SORTERS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE VIEW/SELECT direto. SORT_USAGE é nome legado; temp pode servir hash/LOB e não apenas sort. SQL atual da sessão pode diferir do que alocou temp; não garante atribuição causal.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @sort_view.sql; grants diretos antes.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  View criada; consulta retorna timestamp, SID/user, extents/blocks e prefixo SQL.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  conforme descritos. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  SQL_HASH_VALUE acrescentado ao join SQLAREA para não associar endereço reutilizado; colunas preservadas. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 042 — 04/11/2026
  Correções e melhorias: Definição da view preservada.
  Limitações e pendências: Join só SESSION_ADDR não inclui SERIAL#; SQL atual pode não ser alocador de TEMP. Inner join SQLAREA elimina sessão sem SQL correspondente e RAC/root multitenant requer identidade adicional.
  Homologação necessária: Uso temp com SQL atual trocado, sessão encerrada, ausência de SQLAREA e container; não atribuir causalidade pelo texto exibido.
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

/*  */
rem Code for view: SORTERS                                                    
CREATE OR REPLACE VIEW sorters as                                       
select SYSDATE system_date                                                                 
, s.sid                                                                        
, s.username                                                                   
, b.extents                                                                    
, b.blocks                                                                     
, c.sql_text                                                                   
from v$session s                                                               
, v$sort_usage b                                                               
, v$sqlarea c                                                                  
where s.saddr = b.session_addr                                                 
and s.sql_address = c.address and s.sql_hash_value=c.hash_value;
                                              
                                                                               
