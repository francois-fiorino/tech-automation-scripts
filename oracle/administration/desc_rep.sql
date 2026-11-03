/*
===============================================================================
SCRIPT: desc_rep.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/DESC_REP.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Descrever catálogos de Advanced Replication legada.

FUNCIONAMENTO DETALHADO
  Sequência de DESC sobre famílias ALL_REP/DBA_REP/USER_REP e REPCAT com spool.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  Objetos ALL_REP*, DBA_REP*, USER_REP*, REPCAT* listados no corpo

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Mecanismo Advanced Replication legado pode não estar instalado/suportado na versão atual. Não faz replicação nem extrai dados de filas; múltiplos DESCRIBEs requerem metadados acessíveis.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @desc_rep.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Definições de colunas/tipos ou erros por objeto ausente.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Todos os DESCRIBEs originais preservados. 
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
set echo on
spool desc_rep.lis
desc ALL_REPAUDIT_ATTRIBUTE                                                                         
desc ALL_REPAUDIT_COLUMN                                                                            
desc ALL_REPCAT                                                                                     
desc ALL_REPCATLOG                                                                                  
desc ALL_REPCOLUMN_GROUP                                                                            
desc ALL_REPCONFLICT                                                                                
desc ALL_REPDDL                                                                                     
desc ALL_REPGENERATED                                                                               
desc ALL_REPGROUPED_COLUMN                                                                          
desc ALL_REPKEY_COLUMNS                                                                             
desc ALL_REPOBJECT                                                                                  
desc ALL_REPPARAMETER_COLUMN                                                                        
desc ALL_REPPRIORITY                                                                                
desc ALL_REPPRIORITY_GROUP                                                                          
desc ALL_REPPROP                                                                                    
desc ALL_REPRESOLUTION                                                                              
desc ALL_REPRESOLUTION_METHOD                                                                       
desc ALL_REPRESOLUTION_STATISTICS                                                                   
desc ALL_REPRESOL_STATS_CONTROL                                                                     
desc ALL_REPSCHEMA                                                                                  
desc DBA_REPAUDIT_ATTRIBUTE                                                                         
desc DBA_REPAUDIT_COLUMN                                                                            
desc DBA_REPCAT                                                                                     
desc DBA_REPCATLOG                                                                                  
desc DBA_REPCOLUMN_GROUP                                                                            
desc DBA_REPCONFLICT                                                                                
desc DBA_REPDDL                                                                                     
desc DBA_REPGENERATED                                                                               
desc DBA_REPGROUPED_COLUMN                                                                          
desc DBA_REPKEY_COLUMNS                                                                             
desc DBA_REPOBJECT                                                                                  
desc DBA_REPPARAMETER_COLUMN                                                                        
desc DBA_REPPRIORITY                                                                                
desc DBA_REPPRIORITY_GROUP                                                                          
desc DBA_REPPROP                                                                                    
desc DBA_REPRESOLUTION                                                                              
desc DBA_REPRESOLUTION_METHOD                                                                       
desc DBA_REPRESOLUTION_STATISTICS                                                                   
desc DBA_REPRESOL_STATS_CONTROL                                                                     
desc DBA_REPSCHEMA                                                                                  
desc REPCAT$_CDEF                                                                                   
desc REPCAT_GENERATED                                                                               
desc REPCAT_REPCAT                                                                                  
desc REPCAT_REPCATLOG                                                                               
desc REPCAT_REPOBJECT                                                                               
desc REPCAT_REPPROP                                                                                 
desc REPCAT_REPSCHEMA                                                                               
desc USER_REPAUDIT_ATTRIBUTE                                                                        
desc USER_REPAUDIT_COLUMN                                                                           
desc USER_REPCAT                                                                                    
desc USER_REPCATLOG                                                                                 
desc USER_REPCOLUMN_GROUP                                                                           
desc USER_REPCONFLICT                                                                               
desc USER_REPDDL                                                                                    
desc USER_REPGENERATED                                                                              
desc USER_REPGROUPED_COLUMN                                                                         
desc USER_REPKEY_COLUMNS                                                                            
desc USER_REPOBJECT                                                                                 
desc USER_REPPARAMETER_COLUMN                                                                       
desc USER_REPPRIORITY                                                                               
desc USER_REPPRIORITY_GROUP                                                                         
desc USER_REPPROP                                                                                   
desc USER_REPRESOLUTION                                                                             
desc USER_REPRESOLUTION_METHOD                                                                      
desc USER_REPRESOLUTION_STATISTICS                                                                  
desc USER_REPRESOL_STATS_CONTROL                                                                    
desc USER_REPSCHEMA                                                                                 
spool off
