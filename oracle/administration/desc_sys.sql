/*
===============================================================================
SCRIPT: desc_sys.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/DESC_SYS.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Descrever lista histórica de tabelas internas do catálogo SYS.

FUNCIONAMENTO DETALHADO
  Executa DESC de objetos como OBJ$/TAB$/USER$/UNDO$/views de privilégios e grava spool.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  Tabelas/views SYS literais listadas no corpo

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não concede nem implica autorização para ler dados sensíveis de USER$/LINK$. Sem qualificação no corpo, exige resolver objetos corretos no contexto SYS/sinônimos autorizados. Estruturas e nomes variam e alguns já não existem.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @desc_sys.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Estruturas de colunas/tipos visíveis ao usuário administrativo.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Lista e nomes históricos completos preservados; sem leitura de registros ou extração de senhas. 
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
spool sys_desc.lis
desc ACCESS$                                                                                        
desc ARGUMENT$                                                                                      
desc AUD$                                                                                           
desc AUDIT$                                                                                         
desc AUDIT_ACTIONS                                                                                  
desc BOOTSTRAP$                                                                                     
desc CCOL$                                                                                          
desc CDEF$                                                                                          
desc CLU$                                                                                           
desc COL$                                                                                           
desc COM$                                                                                           
desc CON$                                                                                           
desc DBMS_ALERT_INFO                                                                                
desc DBMS_LOCK_ALLOCATED                                                                            
desc DEFCALLARGS                                                                                    
desc DEFROLE$                                                                                       
desc DEPENDENCY$                                                                                    
desc DUAL                                                                                           
desc DUC$                                                                                           
desc ERROR$                                                                                         
desc EXPACT$                                                                                        
desc FET$                                                                                           
desc FILE$                                                                                          
desc HELP                                                                                           
desc HISTOGRAM$                                                                                     
desc ICOL$                                                                                          
desc IDL_CHAR$                                                                                      
desc IDL_SB4$                                                                                       
desc IDL_UB1$                                                                                       
desc IDL_UB2$                                                                                       
desc INCEXP                                                                                         
desc INCFIL                                                                                         
desc INCVID                                                                                         
desc IND$                                                                                           
desc JOB$                                                                                           
desc LAB$                                                                                           
desc LINK$                                                                                          
desc MLOG$                                                                                          
desc OBJ$                                                                                           
desc OBJAUTH$                                                                                       
desc OBJPRIV$                                                                                       
desc PENDING_SESSIONS$                                                                              
desc PENDING_SUB_SESSIONS$                                                                          
desc PENDING_TRANS$                                                                                 
desc PROCEDURE$                                                                                     
desc PROFILE$                                                                                       
desc PROFNAME$                                                                                      
desc PROPS$                                                                                         
desc PSTUBTBL                                                                                       
desc RESOURCE_COST$                                                                                 
desc RESOURCE_MAP                                                                                   
desc RGCHILD$                                                                                       
desc RGROUP$                                                                                        
desc ROSLFDESC                                                                                      
desc ROSOBJMAP                                                                                      
desc ROSSEQUENCES                                                                                   
desc ROSSTRINGS                                                                                     
desc ROSTFDESC                                                                                      
desc SEG$                                                                                           
desc SEQ$                                                                                           
desc SLOG$                                                                                          
desc SNAP$                                                                                          
desc SOURCE$                                                                                        
desc STMT_AUDIT_OPTION_MAP                                                                          
desc SYN$                                                                                           
desc SYSAUTH$                                                                                       
desc SYSTEM_PRIVILEGE_MAP                                                                           
desc TAB$                                                                                           
desc TABLE_PRIVILEGE_MAP                                                                            
desc TRIGGER$                                                                                       
desc TRIGGERCOL$                                                                                    
desc TS$                                                                                            
desc TSQ$                                                                                           
desc UET$                                                                                           
desc UNDO$                                                                                          
desc USER$                                                                                          
desc VIEW$                                                                                          
desc _default_auditing_options_                                                                     

spool off
