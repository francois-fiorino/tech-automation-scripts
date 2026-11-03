/*
===============================================================================
SCRIPT: fill_sz.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/fill_sz.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Executar coleta histórica de blocos com linhas em 1290 tabelas nomeadas.

FUNCIONAMENTO DETALHADO
  1290 INSERT SELECT COUNT DISTINCT ROWID em TEMP_SIZE_TABLE, distribuídos por 19 owners, sem loop ou COMMIT explícito.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas/SO conforme limitações; ler todos
  os nomes e caminhos antes de qualquer teste em ambiente descartável.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  TEMP_SIZE_TABLE, DBMS_ROWID e 1290 tabelas literais de FLOWS_030000/SYSMAN/XDB/PERFSTAT e demais owners no corpo

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Full scans massivos e DML/undo/redo no staging. Lista de ambiente histórico não é portátil; sem owner na chave, homônimos não se distinguem e reexecução duplica linhas. ROWID físico não suporta IOT/UROWID genericamente. Não é HWM ou blocos alocados.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente clone isolado com staging descartável e lista integral revisada; não executar em produção.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  1290 linhas de contagem inseridas se todas as tabelas/acessos forem válidos.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cópia/restauração, DDL, estatísticas ou DML massivo
  conforme acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Prefixo ambíguo de ROWID restrito substituído por identidade OBJECT/RELATIVE_FNO/BLOCK_NUMBER com delimitadores em todos os 1290 comandos; três nomes XDB com hífen receberam aspas exatas, a validar case no catálogo. Nenhum comando/lista foi removido. 
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
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_ICON_BAR'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_ICON_BAR;                                            
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_ICON_BAR_ATTRIBUTES'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_ICON_BAR_ATTRIBUTES;                                 
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_IMAGE_REPOSITORY'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_IMAGE_REPOSITORY;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_IMPORT_EXPORT'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_IMPORT_EXPORT;                                       
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_INSTALL'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_INSTALL;                                             
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_INSTALL_BUILD_OPT'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_INSTALL_BUILD_OPT;                                   
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_INSTALL_CHECKS'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_INSTALL_CHECKS;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_INSTALL_SCRIPTS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_INSTALL_SCRIPTS;                                     
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_ITEMS'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_ITEMS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_JOBS'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_JOBS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_LANGUAGES'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_LANGUAGES;                                           
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_LANGUAGE_MAP'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_LANGUAGE_MAP;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_SC_TRANS'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_SC_TRANS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_SECURITY_SCHEMES'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_SECURITY_SCHEMES;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_SESSIONS$'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_SESSIONS$;                                           
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_SHARED_QUERIES'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_SHARED_QUERIES;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_SHARED_WEB_SERVICES'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_SHARED_WEB_SERVICES;                                 
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_SHORTCUTS'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_SHORTCUTS;                                           
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_SHORTCUT_USAGE_MAP'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_SHORTCUT_USAGE_MAP;                                  
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_STANDARD_CSS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_STANDARD_CSS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_STANDARD_ICONS'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_STANDARD_ICONS;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_STANDARD_JS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_STANDARD_JS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_STEPS'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_STEPS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_STEP_BRANCHES'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_STEP_BRANCHES;                                       
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_STEP_BRANCH_ARGS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_STEP_BRANCH_ARGS;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_STEP_BUTTONS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_STEP_BUTTONS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_STEP_COMPUTATIONS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_STEP_COMPUTATIONS;                                   
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_STEP_ITEMS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_STEP_ITEMS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_STEP_ITEM_HELP'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_STEP_ITEM_HELP;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_STEP_PROCESSING'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_STEP_PROCESSING;                                     
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_STEP_VALIDATIONS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_STEP_VALIDATIONS;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_SW_BINDS'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_SW_BINDS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_SW_CREATE_KEYWORDS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_SW_CREATE_KEYWORDS;                                  
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_SW_DETAIL_RESULTS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_SW_DETAIL_RESULTS;                                   
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_SW_MAIN_KEYWORDS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_SW_MAIN_KEYWORDS;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_SW_RESULTS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_SW_RESULTS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_MODELS'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_MODELS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_MODEL_PAGES'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_MODEL_PAGES;                                         
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_MODEL_PAGE_COLS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_MODEL_PAGE_COLS;                                     
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_ONLINE_HELP'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_ONLINE_HELP;                                         
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_ONLINE_HELP_JA'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_ONLINE_HELP_JA;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_PAGES_RESERVED'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_PAGES_RESERVED;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_PAGE_CACHE'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_PAGE_CACHE;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_PAGE_GENERIC_ATTR'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_PAGE_GENERIC_ATTR;                                   
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_PAGE_GROUPS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_PAGE_GROUPS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_PAGE_PLUGS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_PAGE_PLUGS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_PAGE_PLUG_TEMPLATES'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_PAGE_PLUG_TEMPLATES;                                 
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_PAGE_SUBMISSIONS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_PAGE_SUBMISSIONS;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_PATCHES'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_PATCHES;                                             
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_PICK_DATABASE_SIZE'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_PICK_DATABASE_SIZE;                                  
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_PICK_END_USERS'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_PICK_END_USERS;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_PICK_PAGE_VIEWS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_PICK_PAGE_VIEWS;                                     
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_PLATFORM_PREF'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_PLATFORM_PREF;                                       
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_PLATFORM_PREFS'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_PLATFORM_PREFS;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_POPUP_LOV_TEMPLATE'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_POPUP_LOV_TEMPLATE;                                  
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_SW_SET_KEYWORDS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_SW_SET_KEYWORDS;                                     
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_SW_SQLPLUS_CMD'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_SW_SQLPLUS_CMD;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_SW_SQL_CMDS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_SW_SQL_CMDS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_SW_STMTS'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_SW_STMTS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_TABS'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_TABS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_TEMPLATES'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_TEMPLATES;                                           
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_TEMPLATES$'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_TEMPLATES$;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_TEMPLATE_PREFERENCES'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_TEMPLATE_PREFERENCES;                                
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_TEMPLATE_THEMES$'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_TEMPLATE_THEMES$;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_THEMES'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_THEMES;                                              
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_TOPLEVEL_TABS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_TOPLEVEL_TABS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_TRANSLATABLE_COLS$'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_TRANSLATABLE_COLS$;                                  
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_TRANSLATABLE_TEXT$'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_TRANSLATABLE_TEXT$;                                  
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_TREES'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_TREES;                                               
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_TREE_STATE'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_TREE_STATE;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_UPGRADE_PROGRESS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_UPGRADE_PROGRESS;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_UPG_COL_NAME_CHANGES'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_UPG_COL_NAME_CHANGES;                                
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_UPG_TAB_NAME_CHANGES'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_UPG_TAB_NAME_CHANGES;                                
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_UPG_TAB_OBSOLETE'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_UPG_TAB_OBSOLETE;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_USER_ACCESS_LOG1$'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_USER_ACCESS_LOG1$;                                   
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_USER_ACCESS_LOG2$'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_USER_ACCESS_LOG2$;                                   
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_USER_ACCESS_LOG_NUM$'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_USER_ACCESS_LOG_NUM$;                                
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_DATA'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_DATA;                                                
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_DATA_LOAD_BAD_LOG'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_DATA_LOAD_BAD_LOG;                                   
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_DATA_LOAD_UNLOAD'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_DATA_LOAD_UNLOAD;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_DB_AUTH'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_DB_AUTH;                                             
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_DEBUG'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_DEBUG;                                               
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_DEVELOPERS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_DEVELOPERS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_DEVELOPER_ROLES'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_DEVELOPER_ROLES;                                     
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_DICTIONARY$'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_DICTIONARY$;                                         
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_DUAL100'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_DUAL100;                                             
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_DYNAMIC_TRANSLATIONS$'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_DYNAMIC_TRANSLATIONS$;                               
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_EFFECTIVE_USERID_MAP'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_EFFECTIVE_USERID_MAP;                                
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_ENTRY_POINTS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_ENTRY_POINTS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_ENTRY_POINT_ARGS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_ENTRY_POINT_ARGS;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_FIELD_TEMPLATES'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_FIELD_TEMPLATES;                                     
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_FILE_OBJECTS$PART'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_FILE_OBJECTS$PART;                                   
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_FLASH_CHARTS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_FLASH_CHARTS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_FLASH_CHART_SERIES'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_FLASH_CHART_SERIES;                                  
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_68114'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.SYS_IOT_OVER_68114;                                           
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_VERSION$'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_VERSION$;                                            
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_WORKSPACE_REQ_SIZE'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_WORKSPACE_REQ_SIZE;                                  
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_WS_OPERATIONS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_WS_OPERATIONS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_WS_PARAMETERS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_WS_PARAMETERS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_WS_PROCESS_PARMS_MAP'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_WS_PROCESS_PARMS_MAP;                                
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACCESS'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACCESS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_COLUMNS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_COLUMNS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_FORMS'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_FORMS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_FORMS_CONTROLS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_FORMS_CONTROLS;                                   
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_FORMS_MODULES'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_FORMS_MODULES;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_FORMS_PERM'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_FORMS_PERM;                                       
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_GROUPS'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_GROUPS;                                           
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_GRPSMEMBERS'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_GRPSMEMBERS;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_INDEXES'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_INDEXES;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_INDEXES_COLS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_INDEXES_COLS;                                     
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_ALTERNATE_CONFIG'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_ALTERNATE_CONFIG;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_ALT_CONFIG_DETAIL'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_ALT_CONFIG_DETAIL;                                   
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_ALT_CONFIG_PICK'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_ALT_CONFIG_PICK;                                     
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_APP_BUILD_PREF'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_APP_BUILD_PREF;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_APP_COMMENTS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_APP_COMMENTS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_BANNER'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_BANNER;                                              
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_BUILDER_AUDIT_TRAIL'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_BUILDER_AUDIT_TRAIL;                                 
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_BUTTON_TEMPLATES'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_BUTTON_TEMPLATES;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_CALS'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_CALS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_CAL_TEMPLATES'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_CAL_TEMPLATES;                                       
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_CHARSETS'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_CHARSETS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_CLICKTHRU_LOG$'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_CLICKTHRU_LOG$;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_CLICKTHRU_LOG2$'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_CLICKTHRU_LOG2$;                                     
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_CLICKTHRU_LOG_NUMBER$'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_CLICKTHRU_LOG_NUMBER$;                               
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_COLLECTIONS$'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_COLLECTIONS$;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_COLLECTION_MEMBERS$'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_COLLECTION_MEMBERS$;                                 
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_COMPANIES'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_COMPANIES;                                           
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_COMPANY_SCHEMAS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_COMPANY_SCHEMAS;                                     
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_COMPANY_TYPES'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_COMPANY_TYPES;                                       
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_COMPOUND_CONDITIONS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_COMPOUND_CONDITIONS;                                 
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_COMPUTATIONS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_COMPUTATIONS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_COUNTRIES'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_COUNTRIES;                                           
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_CSS_REPOSITORY'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_CSS_REPOSITORY;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_CUSTOMIZED_TASKS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_CUSTOMIZED_TASKS;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_CUSTOM_AUTH_SETUPS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_CUSTOM_AUTH_SETUPS;                                  
INSERT INTO temp_size_table                                                     
SELECT 'WWV_COLUMN_EXCEPTIONS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_COLUMN_EXCEPTIONS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOWS'                                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOWS;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOWS_RESERVED'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOWS_RESERVED;                                           
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_ACTIVITY_LOG1$'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_ACTIVITY_LOG1$;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_ACTIVITY_LOG2$'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_ACTIVITY_LOG2$;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_ACTIVITY_LOG_NUMBER$'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_ACTIVITY_LOG_NUMBER$;                                
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_PREFERENCES$'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_PREFERENCES$;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_PROCESSING'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_PROCESSING;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_PROVISION_COMPANY'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_PROVISION_COMPANY;                                   
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_PROVISION_SERICE_MOD'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_PROVISION_SERICE_MOD;                                
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_PURGED_SESSIONS$'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_PURGED_SESSIONS$;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_QB_SAVED_COND'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_QB_SAVED_COND;                                       
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_QB_SAVED_JOIN'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_QB_SAVED_JOIN;                                       
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_QB_SAVED_QUERY'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_QB_SAVED_QUERY;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_QB_SAVED_TABS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_QB_SAVED_TABS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_QUERY_COLUMN'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_QUERY_COLUMN;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_QUERY_CONDITION'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_QUERY_CONDITION;                                     
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_QUERY_DEFINITION'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_QUERY_DEFINITION;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_QUERY_OBJECT'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_QUERY_OBJECT;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_RANDOM_IMAGES'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_RANDOM_IMAGES;                                       
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_REGION_CHART_SER_ATTR'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_REGION_CHART_SER_ATTR;                               
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_REGION_REPORT_COLUMN'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_REGION_REPORT_COLUMN;                                
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_REGION_REPORT_FILTER'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_REGION_REPORT_FILTER;                                
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_REGION_UPD_RPT_COLS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_REGION_UPD_RPT_COLS;                                 
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_REPORT_LAYOUTS'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_REPORT_LAYOUTS;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_REQUEST_VERIFICATIONS'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_REQUEST_VERIFICATIONS;                               
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_REQUIRED_ROLES'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_REQUIRED_ROLES;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_RESTRICTED_SCHEMAS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_RESTRICTED_SCHEMAS;                                  
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_ROW_TEMPLATES'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_ROW_TEMPLATES;                                       
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_RSCHEMA_EXCEPTIONS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_RSCHEMA_EXCEPTIONS;                                  
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_MODULES'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_MODULES;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_MODULES_PERM'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_MODULES_PERM;                                     
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_PAGES'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_PAGES;                                            
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_QUERIES'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_QUERIES;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_RELATIONS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_RELATIONS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_RELATION_COLS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_RELATION_COLS;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_REPORTS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_REPORTS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_RPTS_CONTROLS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_RPTS_CONTROLS;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_RPTS_MODULES'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_RPTS_MODULES;                                     
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_RPT_PERMS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_RPT_PERMS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_TABLES'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_TABLES;                                           
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_TAB_PERM'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_TAB_PERM;                                         
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_ACC_USERS'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_ACC_USERS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_EXPORTER'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_EXPORTER;                                             
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_PROJECTS'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_PROJECTS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_REV_APEXAPP'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_REV_APEXAPP;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_REV_FORMS'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_REV_FORMS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_REV_QUERIES'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_REV_QUERIES;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_REV_REPORTS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_REV_REPORTS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WWV_MIG_REV_TABLES'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_MIG_REV_TABLES;                                           
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_LISTS'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_LISTS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_LISTS_OF_VALUES$'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_LISTS_OF_VALUES$;                                    
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_LIST_ITEMS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_LIST_ITEMS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_LIST_OF_VALUES_DATA'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_LIST_OF_VALUES_DATA;                                 
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_LIST_TEMPLATES'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_LIST_TEMPLATES;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_LOCK_PAGE'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_LOCK_PAGE;                                           
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_LOCK_PAGE_LOG'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_LOCK_PAGE_LOG;                                       
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_LOV_VALUES'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_LOV_VALUES;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_MAIL_LOG'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_MAIL_LOG;                                            
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_MAIL_QUEUE'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_MAIL_QUEUE;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_MENUS'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_MENUS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_MENU_OPTIONS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_MENU_OPTIONS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_MENU_TEMPLATES'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_MENU_TEMPLATES;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_MESSAGES$'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_MESSAGES$;                                           
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_FND_GROUP_USERS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_FND_GROUP_USERS;                                     
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_FND_USER'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_FND_USER;                                            
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_FND_USER_GROUPS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_FND_USER_GROUPS;                                     
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_HNT_ARGUMENT_INFO'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_HNT_ARGUMENT_INFO;                                   
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_HNT_COLUMN_INFO'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_HNT_COLUMN_INFO;                                     
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_HNT_LOV_DATA'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_HNT_LOV_DATA;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_HNT_PROCEDURE_INFO'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_HNT_PROCEDURE_INFO;                                  
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_HNT_TABLE_INFO'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_HNT_TABLE_INFO;                                      
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_HTML_REPOSITORY'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_030000.WWV_FLOW_HTML_REPOSITORY;                                     
INSERT INTO temp_size_table                                                     
SELECT 'WWV_FLOW_FILE_OBJECTS$'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM FLOWS_FILES.WWV_FLOW_FILE_OBJECTS$;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BCN_STEPGROUP_DEFN'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BCN_STEPGROUP_DEFN;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BCN_STEPGROUP_STEPS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BCN_STEPGROUP_STEPS;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BCN_STEP_DEFN'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BCN_STEP_DEFN;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BCN_STEP_PROPS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BCN_STEP_PROPS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BCN_TARGET'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BCN_TARGET;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BCN_TXN_AUDIT'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BCN_TXN_AUDIT;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BCN_TXN_DEFN'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BCN_TXN_DEFN;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BCN_TXN_PROPS'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BCN_TXN_PROPS;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BLACKOUTS'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BLACKOUTS;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BLACKOUT_FLAT_TARGETS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BLACKOUT_FLAT_TARGETS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BLACKOUT_HISTORY'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BLACKOUT_HISTORY;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BLACKOUT_PROXY_TARGETS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BLACKOUT_PROXY_TARGETS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BLACKOUT_REASON'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BLACKOUT_REASON;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BLACKOUT_SCHEDULE'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BLACKOUT_SCHEDULE;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BLACKOUT_STATE'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BLACKOUT_STATE;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BLACKOUT_TARGET_DETAILS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BLACKOUT_TARGET_DETAILS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BSLN_BASELINES'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BSLN_BASELINES;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BSLN_DATASOURCES'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BSLN_DATASOURCES;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BSLN_INTERVALS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BSLN_INTERVALS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BSLN_METRICS'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BSLN_METRICS;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BSLN_STATISTICS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BSLN_STATISTICS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BSLN_THRESHOLD_PARMS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BSLN_THRESHOLD_PARMS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_MESSAGES'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_MESSAGES;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_METADATA_SETS'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_METADATA_SETS;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_METRICS'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_METRICS;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_METRICS_COMPOSITE_KEYS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_METRICS_COMPOSITE_KEYS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_METRICS_EXT'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_METRICS_EXT;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_METRIC_COLLECTIONS_REP'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_METRIC_COLLECTIONS_REP;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_METRIC_DEPENDENCY'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_METRIC_DEPENDENCY;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_METRIC_DEPENDENCY_DEF'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_METRIC_DEPENDENCY_DEF;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_METRIC_DEPENDENCY_DETAILS'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_METRIC_DEPENDENCY_DETAILS;                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_METRIC_ERRORS'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_METRIC_ERRORS;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_METRIC_VERSIONS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_METRIC_VERSIONS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_MNTR_SET_COPIES'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_MNTR_SET_COPIES;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_MP_CONTRIBUTORS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_MP_CONTRIBUTORS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_MP_CONTRIBUTOR_FILE'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_MP_CONTRIBUTOR_FILE;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_MP_DEPLOYMENTS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_MP_DEPLOYMENTS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_MP_DEPLOYMENT_ERRORS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_MP_DEPLOYMENT_ERRORS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_MP_FILES'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_MP_FILES;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_MP_FILE_PROPS'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_MP_FILE_PROPS;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CS_REUSABLE_QUERY'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CS_REUSABLE_QUERY;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CS_RQS_HIERARCHY'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CS_RQS_HIERARCHY;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CS_RQS_INCLUSION'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CS_RQS_INCLUSION;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CS_RULE'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CS_RULE;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CS_RULEFOLDER'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CS_RULEFOLDER;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CS_RULE_FIX_LINK'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CS_RULE_FIX_LINK;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CS_RULE_SIMPLE_TEST'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CS_RULE_SIMPLE_TEST;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CS_RULE_VIOL_CTX'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CS_RULE_VIOL_CTX;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CS_SCHEDULED_EVAL'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CS_SCHEDULED_EVAL;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CURRENT_METRIC_ERRORS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CURRENT_METRIC_ERRORS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CURRENT_VIOLATION'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CURRENT_VIOLATION;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DBNET_TNS_ADMINS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DBNET_TNS_ADMINS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DB_CONTROLFILES_ECM'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DB_CONTROLFILES_ECM;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DB_DATAFILES_ECM'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DB_DATAFILES_ECM;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DB_DBNINSTANCEINFO_ECM'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DB_DBNINSTANCEINFO_ECM;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DB_FEATUREUSAGE'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DB_FEATUREUSAGE;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DB_HDM_METRIC_HELPER'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DB_HDM_METRIC_HELPER;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DB_INVOBJS_ECM'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DB_INVOBJS_ECM;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DB_LATEST_HDM_FINDINGS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DB_LATEST_HDM_FINDINGS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DB_LICENSE_ECM'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DB_LICENSE_ECM;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DB_OPTIONS_ECM'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DB_OPTIONS_ECM;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DB_RECSEGMENTSETTINGS_ECM'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DB_RECSEGMENTSETTINGS_ECM;                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DB_RECTSSETTINGS_ECM'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DB_RECTSSETTINGS_ECM;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DB_RECUSERSETTINGS_ECM'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DB_RECUSERSETTINGS_ECM;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DB_REDOLOGS_ECM'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DB_REDOLOGS_ECM;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DB_ROLLBACK_SEGS_ECM'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DB_ROLLBACK_SEGS_ECM;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DB_SGA_ECM'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DB_SGA_ECM;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DB_TABLESPACES_ECM'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DB_TABLESPACES_ECM;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DELTA_COMPARISON_DELTAS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DELTA_COMPARISON_DELTAS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DELTA_COMP_DELTA_DETAILS'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DELTA_COMP_DELTA_DETAILS;                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DELTA_COMP_KEY_COLS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DELTA_COMP_KEY_COLS;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DELTA_COMP_PROPERTIES'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DELTA_COMP_PROPERTIES;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DELTA_COMP_SUMMARIES'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DELTA_COMP_SUMMARIES;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DELTA_ENTRY'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DELTA_ENTRY;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DELTA_ENTRY_VALUES'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DELTA_ENTRY_VALUES;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DELTA_IDS'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DELTA_IDS;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DELTA_ID_VALUES'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DELTA_ID_VALUES;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DELTA_SAVED_COMPARISON'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DELTA_SAVED_COMPARISON;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DELTA_SNAP'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DELTA_SNAP;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DEPLOYMENT_SECTIONS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DEPLOYMENT_SECTIONS;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DUPLICATE_TARGETS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_DUPLICATE_TARGETS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_E2E_DETAILS'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_E2E_DETAILS;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_E2E_DETAILS_1DAY'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_E2E_DETAILS_1DAY;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_E2E_DETAILS_1HOUR'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_E2E_DETAILS_1HOUR;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_E2E_JDBC'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_E2E_JDBC;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_E2E_JDBC_1DAY'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_E2E_JDBC_1DAY;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_E2E_JDBC_1HOUR'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_E2E_JDBC_1HOUR;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TASK_QTABLE'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TASK_QTABLE;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TEMPLATES'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TEMPLATES;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TEMPLATE_COPIES'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TEMPLATE_COPIES;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TEST'                                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TEST;                                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TEST_DEFAULT_PROMOTION'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TEST_DEFAULT_PROMOTION;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TEST_DEFAULT_THRESHOLDS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TEST_DEFAULT_THRESHOLDS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TEST_MCOLUMNS'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TEST_MCOLUMNS;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TEST_METRICS'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TEST_METRICS;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TEST_METRIC_PROPS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TEST_METRIC_PROPS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TEST_PROP'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TEST_PROP;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TEST_PROP_CHOICES'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TEST_PROP_CHOICES;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TEST_PROP_LEVEL'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TEST_PROP_LEVEL;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TEST_PROP_QUALIFIERS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TEST_PROP_QUALIFIERS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TEST_PROP_UIGROUP'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TEST_PROP_UIGROUP;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TEST_QUALIFIERS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TEST_QUALIFIERS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TEST_TARGET_MAP'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TEST_TARGET_MAP;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TEXTINDEX'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TEXTINDEX;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TEXTINDEX_LOGS_INFO'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TEXTINDEX_LOGS_INFO;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TEXT_INDEX_STATS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TEXT_INDEX_STATS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TOPO_PAGE_BG_IMAGE'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TOPO_PAGE_BG_IMAGE;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TOPO_PAGE_OBJ_POS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TOPO_PAGE_OBJ_POS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TOPO_PAGE_PREF'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TOPO_PAGE_PREF;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TYPE_PROPERTIES'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TYPE_PROPERTIES;                                               
INSERT INTO temp_size_table                                                     
SELECT 'DB_USER_PREFERENCES'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.DB_USER_PREFERENCES;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_POLICIES'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_POLICIES;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_POLICY_ASSOC_CFG'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_POLICY_ASSOC_CFG;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_POLICY_ASSOC_EVAL_DETAILS'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_POLICY_ASSOC_EVAL_DETAILS;                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_POLICY_ASSOC_EVAL_SUMM'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_POLICY_ASSOC_EVAL_SUMM;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_POLICY_PARAMETERS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_POLICY_PARAMETERS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_POLICY_VIOL_CTXT_DEF'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_POLICY_VIOL_CTXT_DEF;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PRIVS'                                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PRIVS;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_ASN_DEPENDENCIES'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_ASN_DEPENDENCIES;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_ASN_TARGETS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_ASN_TARGETS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_ASSIGNMENT'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_ASSIGNMENT;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_BOOTSERVER'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_BOOTSERVER;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_CLUSTER'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_CLUSTER;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_CLUSTER_NODES'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_CLUSTER_NODES;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_COLLECTION'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_COLLECTION;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_DEFAULT_IMAGE'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_DEFAULT_IMAGE;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_HARDWARE'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_HARDWARE;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_HISTORY'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_HISTORY;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_IP_RANGE'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_IP_RANGE;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_IP_RESERVED'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_IP_RESERVED;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_NET_CONFIG'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_NET_CONFIG;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_OPERATION'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_OPERATION;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_RPM_REP'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_RPM_REP;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_STAGED_COMPS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_STAGED_COMPS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_STAGING_DIRS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_STAGING_DIRS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_SUITE_INSTANCE'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_SUITE_INSTANCE;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_SUITE_INST_MEMBERS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_SUITE_INST_MEMBERS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PROV_TGT_STATUS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PROV_TGT_STATUS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PURGE_POLICY'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PURGE_POLICY;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PURGE_POLICY_GROUP'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PURGE_POLICY_GROUP;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PURGE_POLICY_TARGET_STATE'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PURGE_POLICY_TARGET_STATE;                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_IP_ELEM_DEFAULT_PARAMS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_IP_ELEM_DEFAULT_PARAMS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_IP_ELEM_PARAM_CLASSES'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_IP_ELEM_PARAM_CLASSES;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_IP_ELEM_TARGET_TYPES'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_IP_ELEM_TARGET_TYPES;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_IP_EMAIL_REPORT'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_IP_EMAIL_REPORT;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_IP_PURGE_POLICY'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_IP_PURGE_POLICY;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_IP_REPORT_DEF'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_IP_REPORT_DEF;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_IP_REPORT_DEF_ELEMENTS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_IP_REPORT_DEF_ELEMENTS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_IP_REPORT_DEF_JIT_TYPES'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_IP_REPORT_DEF_JIT_TYPES;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_IP_REPORT_ELEM_DEF'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_IP_REPORT_ELEM_DEF;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_IP_REPORT_ELEM_IMAGE'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_IP_REPORT_ELEM_IMAGE;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_IP_REPORT_ELEM_PARAMS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_IP_REPORT_ELEM_PARAMS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_IP_REPORT_ELEM_TARGETS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_IP_REPORT_ELEM_TARGETS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_IP_SQL_STATEMENTS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_IP_SQL_STATEMENTS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_IP_STORED_REPORT'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_IP_STORED_REPORT;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB'                                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB;                                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_ASSOC_PARAMS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_ASSOC_PARAMS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_BLACKOUT_ASSOC'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_BLACKOUT_ASSOC;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_CALLBACKS'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_CALLBACKS;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_COMMAND'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_COMMAND;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_COMMAND_BLOCK_PROCS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_COMMAND_BLOCK_PROCS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_CRED_PARAMS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_CRED_PARAMS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_DISPLAY_ERROR_CODES'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_DISPLAY_ERROR_CODES;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_EMD_STATUS_QUEUE'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_EMD_STATUS_QUEUE;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_EVENT'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_EVENT;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_EXECPLAN'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_EXECPLAN;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_EXECUTION'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_EXECUTION;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_EXEC_CRED_INFO'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_EXEC_CRED_INFO;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_EXEC_EVENT_PARAMS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_EXEC_EVENT_PARAMS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_EXEC_LOCKS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_EXEC_LOCKS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_EXEC_SUMMARY'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_EXEC_SUMMARY;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_EXT_TARGETS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_EXT_TARGETS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_FLAT_TARGETS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_FLAT_TARGETS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_HISTORY'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_HISTORY;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_LARGE_PARAMS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_LARGE_PARAMS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_LOCK_INFO'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_LOCK_INFO;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_LOCK_TARGETS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_LOCK_TARGETS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_NOTIFY_STATES'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_NOTIFY_STATES;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_OUTPUT'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_OUTPUT;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_PARAMETER'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_PARAMETER;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_PARAM_SOURCE'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_PARAM_SOURCE;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_COLLECTIONS'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_COLLECTIONS;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_COLLECTION_TASKS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_COLLECTION_TASKS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_COMP_RESULT_TO_JOB_MAP'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_COMP_RESULT_TO_JOB_MAP;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_COMP_SNAPSHOT_TO_STEP_MAP'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_COMP_SNAPSHOT_TO_STEP_MAP;                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CONTAINER_CREDENTIALS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CONTAINER_CREDENTIALS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CORRECTIVE_ACTION'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CORRECTIVE_ACTION;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CPF_METRIC_SOURCE'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CPF_METRIC_SOURCE;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CREATED_USERS'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CREATED_USERS;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CREDENTIALS'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CREDENTIALS;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CREDENTIALS2'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CREDENTIALS2;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CREDENTIAL_SETS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CREDENTIAL_SETS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CREDENTIAL_SET_COLUMNS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CREDENTIAL_SET_COLUMNS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CREDENTIAL_SET_COL_VALS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CREDENTIAL_SET_COL_VALS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CREDENTIAL_TYPES'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CREDENTIAL_TYPES;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CREDENTIAL_TYPE_COLUMNS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CREDENTIAL_TYPE_COLUMNS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CREDENTIAL_TYPE_COL_VALS'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CREDENTIAL_TYPE_COL_VALS;                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ERROR_MASTER'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ERROR_MASTER;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ESA_REPORT'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ESA_REPORT;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_FAILOVER_CALLBACKS'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_FAILOVER_CALLBACKS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_FAILOVER_TABLE'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_FAILOVER_TABLE;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_FBP_PATCHING_GUIDS'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_FBP_PATCHING_GUIDS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_FEATURES_MAPPING'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_FEATURES_MAPPING;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_FEATURE_PATCHES'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_FEATURE_PATCHES;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_FLAT_TARGET_ASSOC'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_FLAT_TARGET_ASSOC;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_GENSVC_AVAIL_BEACONS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_GENSVC_AVAIL_BEACONS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_GENSVC_AVAIL_CONFIG'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_GENSVC_AVAIL_CONFIG;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_GENSVC_AVAIL_EVENTS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_GENSVC_AVAIL_EVENTS;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_GENSVC_AVAIL_JOB'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_GENSVC_AVAIL_JOB;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_GENSVC_AVAIL_TESTS'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_GENSVC_AVAIL_TESTS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_GENSVC_JOBS_DETAILS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_GENSVC_JOBS_DETAILS;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_GENSVC_TEST_AVAIL'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_GENSVC_TEST_AVAIL;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_GENSVC_TEST_AVAIL_MARKER'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_GENSVC_TEST_AVAIL_MARKER;                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_GENSVC_TEST_CUR_AVAIL'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_GENSVC_TEST_CUR_AVAIL;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_GENSVC_TMPL_VARS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_GENSVC_TMPL_VARS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_GENSVC_UPDBCN_JOB'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_GENSVC_UPDBCN_JOB;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_GENSVC_UPDBCN_JOB_TESTS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_GENSVC_UPDBCN_JOB_TESTS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_GROUP_CHART'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_GROUP_CHART;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_GROUP_CHART_SELTARGETS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_GROUP_CHART_SELTARGETS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_GROUP_CUSTOM_COLUMNS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_GROUP_CUSTOM_COLUMNS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_GROUP_DEFAULT_CHART'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_GROUP_DEFAULT_CHART;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_GROUP_SUMMARY_CHART_DEF'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_GROUP_SUMMARY_CHART_DEF;                                       
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_64424'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.SYS_IOT_OVER_64424;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_64663'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.SYS_IOT_OVER_64663;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_64666'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.SYS_IOT_OVER_64666;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_64763'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.SYS_IOT_OVER_64763;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_64776'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.SYS_IOT_OVER_64776;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_64779'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.SYS_IOT_OVER_64779;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_64833'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.SYS_IOT_OVER_64833;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_64836'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.SYS_IOT_OVER_64836;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_64839'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.SYS_IOT_OVER_64839;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_64844'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.SYS_IOT_OVER_64844;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_65250'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.SYS_IOT_OVER_65250;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_65256'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.SYS_IOT_OVER_65256;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_65260'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.SYS_IOT_OVER_65260;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_65265'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.SYS_IOT_OVER_65265;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_65371'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.SYS_IOT_OVER_65371;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_67078'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.SYS_IOT_OVER_67078;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_67395'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.SYS_IOT_OVER_67395;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_PROP_PARAMS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_PROP_PARAMS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_PURGE_CRITERIA'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_PURGE_CRITERIA;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_PURGE_POLICIES'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_PURGE_POLICIES;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_PURGE_TARGETS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_PURGE_TARGETS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_PURGE_VALUES'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_PURGE_VALUES;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_QUEUES'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_QUEUES;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_SCHEDULE'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_SCHEDULE;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_SEC_INFO'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_SEC_INFO;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_SINGLE_TARGET_TYPES'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_SINGLE_TARGET_TYPES;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_SQL_PARAMS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_SQL_PARAMS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_STATE_CHANGES'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_STATE_CHANGES;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_STEP_COMMAND_LOG'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_STEP_COMMAND_LOG;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_STEP_PARAMS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_STEP_PARAMS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_STEP_TARGETS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_STEP_TARGETS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_SUBST_PARAMS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_SUBST_PARAMS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_TARGET'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_TARGET;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_TYPE_DISPLAY_INFO'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_TYPE_DISPLAY_INFO;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_TYPE_DISPLAY_PARAM'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_TYPE_DISPLAY_PARAM;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_TYPE_INFO'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_TYPE_INFO;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_TYPE_MAX_VERSIONS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_TYPE_MAX_VERSIONS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_TYPE_PARAM_DROPDOWNS'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_TYPE_PARAM_DROPDOWNS;                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_TYPE_PARAM_DSPLY_INFO'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_TYPE_PARAM_DSPLY_INFO;                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_TYPE_PARAM_URI_INFO'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_TYPE_PARAM_URI_INFO;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_TYPE_URI_INFO'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_TYPE_URI_INFO;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_USER_PARAMS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_USER_PARAMS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_JOB_VALUE_PARAMS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_JOB_VALUE_PARAMS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_LAST_SYNC_LOAD_DETAILS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_LAST_SYNC_LOAD_DETAILS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_LICENSES'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_LICENSES;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_LICENSE_DEFINITIONS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_LICENSE_DEFINITIONS;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_LOADER_DESIGNATORS'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_LOADER_DESIGNATORS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_LOADER_QTABLE'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_LOADER_QTABLE;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_LOGIN_ASSISTANTS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_LOGIN_ASSISTANTS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_LONG_TEXT'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_LONG_TEXT;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_MANAGEMENT_PLUGINS'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_MANAGEMENT_PLUGINS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_MASTER_AGENT'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_MASTER_AGENT;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_MASTER_CHANGED_CALLBACK'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_MASTER_CHANGED_CALLBACK;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SWLIB_DATA_DIRECTORIES'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SWLIB_DATA_DIRECTORIES;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SWLIB_DIRECTORIES'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SWLIB_DIRECTORIES;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SWLIB_ENTITIES'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SWLIB_ENTITIES;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SWLIB_ENTITY_DATA'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SWLIB_ENTITY_DATA;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SWLIB_ENTITY_DOCUMENTS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SWLIB_ENTITY_DOCUMENTS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SWLIB_ENTITY_PARAMETERS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SWLIB_ENTITY_PARAMETERS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SWLIB_ENTITY_PLATFORMS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SWLIB_ENTITY_PLATFORMS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SWLIB_ENTITY_REFERENCES'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SWLIB_ENTITY_REFERENCES;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SWLIB_ENTITY_REVISIONS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SWLIB_ENTITY_REVISIONS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SWLIB_MATURITY_STATUS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SWLIB_MATURITY_STATUS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SWLIB_REVISION_PARAMETERS'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SWLIB_REVISION_PARAMETERS;                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SYSTEM_CHANGES'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SYSTEM_CHANGES;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SYSTEM_ERROR_LOG'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SYSTEM_ERROR_LOG;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SYSTEM_PERFORMANCE_LOG'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SYSTEM_PERFORMANCE_LOG;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TABLE_SIZES'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TABLE_SIZES;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGETS'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGETS;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGETS_DELETE'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGETS_DELETE;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_ADD_CALLBACKS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_ADD_CALLBACKS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_AGENT_ASSOC'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_AGENT_ASSOC;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_ASSOC'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_ASSOC;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_ASSOCS'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_ASSOCS;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_ASSOC_DEFS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_ASSOC_DEFS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_ASSOC_ERROR'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_ASSOC_ERROR;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_ASSOC_INSTANCE'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_ASSOC_INSTANCE;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_ASSOC_PROP'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_ASSOC_PROP;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_ASSOC_PROP_DEFS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_ASSOC_PROP_DEFS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_ASSOC_STATUS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_ASSOC_STATUS;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_BASELINES'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_BASELINES;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_BASELINES_DATA'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_BASELINES_DATA;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_DELETE_CALLBACKS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_DELETE_CALLBACKS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_DELETE_EXCEPTIONS'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_DELETE_EXCEPTIONS;                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_PENDING_ASSOCS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_PENDING_ASSOCS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_PROPERTIES'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_PROPERTIES;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_PROP_DEFS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_PROP_DEFS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_ROLLUP_TIMES'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_ROLLUP_TIMES;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_TYPES'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_TYPES;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_TYPE_COMPONENT_MAP'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_TYPE_COMPONENT_MAP;                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_TARGET_TYPE_VERSIONS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_TARGET_TYPE_VERSIONS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RAC_SERVICES'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RAC_SERVICES;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RCA_EVENT'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RCA_EVENT;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RCA_EVENT_ASSOC'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RCA_EVENT_ASSOC;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RCA_METRIC_PROPS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RCA_METRIC_PROPS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RCA_METRIC_TEST'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RCA_METRIC_TEST;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RCA_RECOVERY'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RCA_RECOVERY;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RCA_RUN'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RCA_RUN;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RCA_SUMMARY'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RCA_SUMMARY;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RCA_TARGET_PROPS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RCA_TARGET_PROPS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RCA_TEST_RESULT'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RCA_TEST_RESULT;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RCA_TRACE'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RCA_TRACE;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RCVCAT_CONFIG'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RCVCAT_CONFIG;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RCVCAT_REPOS'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RCVCAT_REPOS;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_REBUILD_INDEXES'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_REBUILD_INDEXES;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_REPOS_TIME_COEFFICIENT'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_REPOS_TIME_COEFFICIENT;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ROLES'                                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ROLES;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ROWSET_HANDLERS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ROWSET_HANDLERS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_BOOTSTRAP_TIMES'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_BOOTSTRAP_TIMES;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_COOKIE_DATA'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_COOKIE_DATA;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_DOMAIN_1DAY'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_DOMAIN_1DAY;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_DOMAIN_1HOUR'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_DOMAIN_1HOUR;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_DOMAIN_BOOTSTRAP'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_DOMAIN_BOOTSTRAP;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_DOMAIN_DIST_1DAY'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_DOMAIN_DIST_1DAY;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_DOMAIN_DIST_1HOUR'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_DOMAIN_DIST_1HOUR;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_DOMAIN_DIST_BOOTSTRAP'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_DOMAIN_DIST_BOOTSTRAP;                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_INCOMPLETE_LOADS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_INCOMPLETE_LOADS;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_INCOMPLETE_LOADS_1DAY'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_INCOMPLETE_LOADS_1DAY;                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_INCOMPLETE_LOADS_1HOUR'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_INCOMPLETE_LOADS_1HOUR;                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_IP_1DAY'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_IP_1DAY;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_IP_1HOUR'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_IP_1HOUR;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_IP_BOOTSTRAP'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_IP_BOOTSTRAP;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_IP_DIST_1DAY'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_IP_DIST_1DAY;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_IP_DIST_1HOUR'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_IP_DIST_1HOUR;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_IP_DIST_BOOTSTRAP'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_IP_DIST_BOOTSTRAP;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_METRICS_RAW'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_METRICS_RAW;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_PR_MAPPING'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_PR_MAPPING;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_PR_MAPPING_1DAY'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_PR_MAPPING_1DAY;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_PR_MAPPING_1HOUR'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_PR_MAPPING_1HOUR;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_E2E_SQL'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_E2E_SQL;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_E2E_SQL_1DAY'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_E2E_SQL_1DAY;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_E2E_SQL_1HOUR'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_E2E_SQL_1HOUR;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_E2E_SQL_CONN'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_E2E_SQL_CONN;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_E2E_SQL_STMT'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_E2E_SQL_STMT;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_E2E_SUMMARY'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_E2E_SUMMARY;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_E2E_SUMMARY_1DAY'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_E2E_SUMMARY_1DAY;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_E2E_SUMMARY_1HOUR'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_E2E_SUMMARY_1HOUR;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_ARU_MAP'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_ARU_MAP;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_CSA'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_CSA;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_CSA_APPID_TARGET_MAP'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_CSA_APPID_TARGET_MAP;                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_CSA_COOKIES'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_CSA_COOKIES;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_CSA_CUSTOM'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_CSA_CUSTOM;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_CSA_FAILED'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_CSA_FAILED;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_CSA_GENERAL_INFO'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_CSA_GENERAL_INFO;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_CSA_OUT_OF_BOX'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_CSA_OUT_OF_BOX;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_CSA_RULES'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_CSA_RULES;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_CSA_SNAPSHOT_INFO'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_CSA_SNAPSHOT_INFO;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_GEN_SNAPSHOT'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_GEN_SNAPSHOT;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_HOSTPATCH_COMPL_HIST'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_HOSTPATCH_COMPL_HIST;                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_HOSTPATCH_GROUPS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_HOSTPATCH_GROUPS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_HOSTPATCH_GROUP_REPOS'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_HOSTPATCH_GROUP_REPOS;                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_HOSTPATCH_HOSTS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_HOSTPATCH_HOSTS;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_HOSTPATCH_HOST_COMPL'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_HOSTPATCH_HOST_COMPL;                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_HOSTPATCH_REPOS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_HOSTPATCH_REPOS;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_HOSTPATCH_REPOS_PKGS'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_HOSTPATCH_REPOS_PKGS;                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_HOST_CONFIGS_TO_DEL'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_HOST_CONFIGS_TO_DEL;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_HW'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_HW;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_HW_CPU'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_HW_CPU;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_HW_IOCARD'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_HW_IOCARD;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_HW_NIC'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_HW_NIC;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_LOADED_FILES'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_LOADED_FILES;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_MD_ALL_TBL_COLUMNS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_MD_ALL_TBL_COLUMNS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_MD_HIST_TBLS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_MD_HIST_TBLS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_OS'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_OS;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_OS_COMPONENT'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_OS_COMPONENT;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_OS_FILESYSTEM'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_OS_FILESYSTEM;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_OS_PROPERTY'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_OS_PROPERTY;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_OS_REGISTERED_SW'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_OS_REGISTERED_SW;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_OS_REGISTERED_SW_COMP'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_OS_REGISTERED_SW_COMP;                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_PATCH_CACHE'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_PATCH_CACHE;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_RESOURCES'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_RESOURCES;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_SAVEDHOSTCONFIG'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_SAVEDHOSTCONFIG;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_SNAPSHOT'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_SNAPSHOT;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_SNAPSHOT_MD_COLUMNS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_SNAPSHOT_MD_COLUMNS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_SNAPSHOT_MD_TABLES'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_SNAPSHOT_MD_TABLES;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_SNAPSHOT_METADATA'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_SNAPSHOT_METADATA;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ECM_SNAP_COMPONENT_INFO'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ECM_SNAP_COMPONENT_INFO;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_EMD_PING'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_EMD_PING;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_MP_HOMEPAGE_REPORTS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_MP_HOMEPAGE_REPORTS;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_MP_MECHANISMS'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_MP_MECHANISMS;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_MP_NLS_SUBSTITUTIONS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_MP_NLS_SUBSTITUTIONS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_MP_PROPS'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_MP_PROPS;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_NESTED_JOB_CRED_INFO'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_NESTED_JOB_CRED_INFO;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_NESTED_JOB_TARGETS'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_NESTED_JOB_TARGETS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_NET_EVENTS'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_NET_EVENTS;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_NOTIFICATION_LOG'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_NOTIFICATION_LOG;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_NOTIFY_DEVICES'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_NOTIFY_DEVICES;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_NOTIFY_DEVICE_PARAMS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_NOTIFY_DEVICE_PARAMS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_NOTIFY_DEV_SCHEDULES'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_NOTIFY_DEV_SCHEDULES;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_NOTIFY_EMAIL_GATEWAY'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_NOTIFY_EMAIL_GATEWAY;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_NOTIFY_FORMAT_HANDLERS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_NOTIFY_FORMAT_HANDLERS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_NOTIFY_JOB_RULE_CONFIGS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_NOTIFY_JOB_RULE_CONFIGS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_NOTIFY_PROFILES'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_NOTIFY_PROFILES;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_NOTIFY_QTABLE'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_NOTIFY_QTABLE;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_NOTIFY_QUEUES'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_NOTIFY_QUEUES;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_NOTIFY_REQUEUE'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_NOTIFY_REQUEUE;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_NOTIFY_RULES'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_NOTIFY_RULES;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_NOTIFY_RULE_CONFIGS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_NOTIFY_RULE_CONFIGS;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_NOTIFY_SCHEDULES'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_NOTIFY_SCHEDULES;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_OB_ADMIN_CLIENT_DB'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_OB_ADMIN_CLIENT_DB;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_OB_ADMIN_HOSTS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_OB_ADMIN_HOSTS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_OMS_PARAMETERS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_OMS_PARAMETERS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_OPERATIONS_MASTER'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_OPERATIONS_MASTER;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_OSM_DISK_GROUP_ECM'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_OSM_DISK_GROUP_ECM;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_OUI_ARU_MAP'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_OUI_ARU_MAP;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PAF_APPLICATIONS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PAF_APPLICATIONS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PAF_COMP_JOBTYPE_MAPPINGS'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PAF_COMP_JOBTYPE_MAPPINGS;                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PAF_ENCRYPTED_STRINGS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PAF_ENCRYPTED_STRINGS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PAF_INSTANCES'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PAF_INSTANCES;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PAF_JOBTYPES'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PAF_JOBTYPES;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PAF_JOBTYPE_PARAMS'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PAF_JOBTYPE_PARAMS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PAF_MSG_QTABLE_1'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PAF_MSG_QTABLE_1;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PAF_MSG_QTABLE_2'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PAF_MSG_QTABLE_2;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PAF_NOTIFICATION_LOG'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PAF_NOTIFICATION_LOG;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PAF_OMS_STATUS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PAF_OMS_STATUS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PAF_PARAM_GROUPS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PAF_PARAM_GROUPS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PAF_PAR_FILES'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PAF_PAR_FILES;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PAF_PROCEDURES'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PAF_PROCEDURES;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PAF_STATES'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PAF_STATES;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PAF_TEXTUAL_DATA'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PAF_TEXTUAL_DATA;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PARAMETERS'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PARAMETERS;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PERFORMANCE_NAMES'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PERFORMANCE_NAMES;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_PLANPROBLEM_FACTORS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_PLANPROBLEM_FACTORS;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_UPDATE_COLL_CREDS_DATA'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_UPDATE_COLL_CREDS_DATA;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_UPDATE_CREDENTIALS_DATA'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_UPDATE_CREDENTIALS_DATA;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_UPDATE_OPERATIONS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_UPDATE_OPERATIONS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_UPDATE_OPERATIONS_DATA'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_UPDATE_OPERATIONS_DATA;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_UPDATE_OPERATIONS_DETAILS'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_UPDATE_OPERATIONS_DETAILS;                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_UPDATE_PROPERTIES_DATA'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_UPDATE_PROPERTIES_DATA;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_UPDATE_TEMPLATE_DATA_MAP'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_UPDATE_TEMPLATE_DATA_MAP;                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_UPDATE_THRESHOLDS_DATA'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_UPDATE_THRESHOLDS_DATA;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_URL_CACHE'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_URL_CACHE;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_URL_PROXY'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_URL_PROXY;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_USER_FOLDERS'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_USER_FOLDERS;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_USER_PREFERENCES'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_USER_PREFERENCES;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_USER_SESSION'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_USER_SESSION;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_USER_SUBTAB_COL_PREFS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_USER_SUBTAB_COL_PREFS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_VERSIONS'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_VERSIONS;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_VIEW_USER_CREDENTIALS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_VIEW_USER_CREDENTIALS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_VIOLATIONS'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_VIOLATIONS;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_VIOLATION_CONTEXT'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_VIOLATION_CONTEXT;                                             
INSERT INTO temp_size_table                                                     
SELECT 'EM_COMPARISON_SUMMARY'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.EM_COMPARISON_SUMMARY;                                              
INSERT INTO temp_size_table                                                     
SELECT 'EM_IPW_INFO'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.EM_IPW_INFO;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'EM_PAGE_CONDITION_METADATA'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.EM_PAGE_CONDITION_METADATA;                                         
INSERT INTO temp_size_table                                                     
SELECT 'EM_PAGE_CUSTOMIZATIONS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.EM_PAGE_CUSTOMIZATIONS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'EM_PAGE_CUSTOM_CONDITIONS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.EM_PAGE_CUSTOM_CONDITIONS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'EM_PAGE_CUST_METADATA'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.EM_PAGE_CUST_METADATA;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HA_BACKUP'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HA_BACKUP;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HA_CLS_INTR_CONN'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HA_CLS_INTR_CONN;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HA_DG_TARGET_SUMMARY'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HA_DG_TARGET_SUMMARY;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HA_FILES_ECM'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HA_FILES_ECM;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HA_INFO_ECM'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HA_INFO_ECM;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HA_INIT_PARAMS_ECM'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HA_INIT_PARAMS_ECM;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HA_MTTR'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HA_MTTR;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HA_RAC_INTR_CONN'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HA_RAC_INTR_CONN;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HA_RMAN_CONFIG_ECM'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HA_RMAN_CONFIG_ECM;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HC_CPU_DETAILS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HC_CPU_DETAILS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HC_FS_MOUNT_DETAILS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HC_FS_MOUNT_DETAILS;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HC_HARDWARE_MASTER'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HC_HARDWARE_MASTER;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HC_IOCARD_DETAILS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HC_IOCARD_DETAILS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HC_NIC_DETAILS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HC_NIC_DETAILS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HC_OS_COMPONENTS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HC_OS_COMPONENTS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HC_OS_PROPERTIES'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HC_OS_PROPERTIES;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HC_OS_SUMMARY'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HC_OS_SUMMARY;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HC_SYSTEM_SUMMARY'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HC_SYSTEM_SUMMARY;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HC_VENDOR_SW_COMPONENTS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HC_VENDOR_SW_COMPONENTS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HC_VENDOR_SW_SUMMARY'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HC_VENDOR_SW_SUMMARY;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HTTP_SESSION_CALLBACKS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HTTP_SESSION_CALLBACKS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HTTP_SESSION_OBJECTS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_HTTP_SESSION_OBJECTS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_INDEX_SIZES'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_INDEX_SIZES;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_INV_COMPONENT'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_INV_COMPONENT;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_INV_COMPONENT_PATCH'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_INV_COMPONENT_PATCH;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_INV_CONTAINER'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_INV_CONTAINER;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_INV_CONTAINER_PROPERTY'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_INV_CONTAINER_PROPERTY;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_INV_DEPENDENCY_RULE'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_INV_DEPENDENCY_RULE;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_INV_FILE'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_INV_FILE;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_INV_PATCH'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_INV_PATCH;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_INV_PATCHED_FILE'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_INV_PATCHED_FILE;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_INV_PATCHED_FILE_COMP'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_INV_PATCHED_FILE_COMP;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_INV_PATCHSET'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_INV_PATCHSET;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_INV_PATCH_FIXED_BUG'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_INV_PATCH_FIXED_BUG;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_INV_SUMMARY'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_INV_SUMMARY;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_INV_VERSIONED_PATCH'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_INV_VERSIONED_PATCH;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ARU_RELEASES'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ARU_RELEASES;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_AUDIT_DESTINATION'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_AUDIT_DESTINATION;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_AUDIT_LOGS'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_AUDIT_LOGS;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_AUDIT_MASTER'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_AUDIT_MASTER;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_AVAILABILITY_RBK'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_AVAILABILITY_RBK;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_AVAILABLE_SEARCHES'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_AVAILABLE_SEARCHES;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BACKUP_CONFIGURATION'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BACKUP_CONFIGURATION;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BAM_DATA_HUBS'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BAM_DATA_HUBS;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BAM_DATA_ISESSIONS'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BAM_DATA_ISESSIONS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BAM_DATA_OSESSIONS'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BAM_DATA_OSESSIONS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BAM_ISESSION_DATASOURCE'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BAM_ISESSION_DATASOURCE;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BAM_ISESSION_DIAG'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BAM_ISESSION_DIAG;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BAM_ISESSION_KPIS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BAM_ISESSION_KPIS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BAM_OSESSION_DIAG'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BAM_OSESSION_DIAG;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BCN_AVAIL_DEF'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BCN_AVAIL_DEF;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BCN_AVAIL_JOB'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BCN_AVAIL_JOB;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BCN_AVAIL_LOG'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BCN_AVAIL_LOG;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BCN_BCNSTEP_PROPS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BCN_BCNSTEP_PROPS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BCN_BCNTXN_PROPS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BCN_BCNTXN_PROPS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ADMIN_LICENSES'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ADMIN_LICENSES;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ADMIN_METRIC_THRESHOLDS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ADMIN_METRIC_THRESHOLDS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_AGENT_SEC_INFO'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_AGENT_SEC_INFO;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ALL_TARGET_PROPS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ALL_TARGET_PROPS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ANNOTATION'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ANNOTATION;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ARU_CREDENTIALS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ARU_CREDENTIALS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ARU_FAMILY_PRODUCT_MAP'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ARU_FAMILY_PRODUCT_MAP;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ARU_LANGUAGES'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ARU_LANGUAGES;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ARU_OUI_COMPONENTS'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ARU_OUI_COMPONENTS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ARU_PLATFORMS'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ARU_PLATFORMS;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ARU_PRODUCTS'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ARU_PRODUCTS;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_ARU_PRODUCT_RELEASE_MAP'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_ARU_PRODUCT_RELEASE_MAP;                                       
INSERT INTO temp_size_table                                                     
SELECT 'EMDW_TRACE_CONFIG'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.EMDW_TRACE_CONFIG;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'EMDW_TRACE_DATA'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.EMDW_TRACE_DATA;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CSTMZ_CHARTS'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CSTMZ_CHARTS;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CSTMZ_CHART_SELTARGETS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CSTMZ_CHART_SELTARGETS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CSTMZ_CUSTOM_COLUMNS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CSTMZ_CUSTOM_COLUMNS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CSTMZ_DEFAULT_CHART'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CSTMZ_DEFAULT_CHART;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CSTMZ_SUMMARY_CHART_DEF'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CSTMZ_SUMMARY_CHART_DEF;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CS_CONFIG_STANDARD'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CS_CONFIG_STANDARD;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CS_EVAL_SUMM_RQS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CS_EVAL_SUMM_RQS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CS_EVAL_SUMM_RULE'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CS_EVAL_SUMM_RULE;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CS_EVAL_SUMM_RULEFOLDER'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CS_EVAL_SUMM_RULEFOLDER;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CS_HIERARCHY'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CS_HIERARCHY;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CS_INCLUSION'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CS_INCLUSION;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CS_INCLUSION_PARAMETER'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CS_INCLUSION_PARAMETER;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CS_KEYWORD'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CS_KEYWORD;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CS_PARAMETER'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CS_PARAMETER;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CS_PARAMETER_CHOICES'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CS_PARAMETER_CHOICES;                                          
INSERT INTO temp_size_table                                                     
SELECT 'ESM_COLLECTION'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.ESM_COLLECTION;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'EUME2E_ASSOCS_LOOKUP'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.EUME2E_ASSOCS_LOOKUP;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_REGIONS'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_REGIONS;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_REGION_ENTRIES'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_REGION_ENTRIES;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_REGION_MAPPING'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_REGION_MAPPING;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_TARGET_PROPERTIES'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_TARGET_PROPERTIES;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_URLS'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_URLS;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_URL_1DAY'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_URL_1DAY;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_URL_1HOUR'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_URL_1HOUR;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_URL_BOOTSTRAP'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_URL_BOOTSTRAP;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_URL_DIST_1DAY'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_URL_DIST_1DAY;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_URL_DIST_1HOUR'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_URL_DIST_1HOUR;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RT_URL_DIST_BOOTSTRAP'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_RT_URL_DIST_BOOTSTRAP;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SEC_INFO'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SEC_INFO;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SEVERITY_RBK'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SEVERITY_RBK;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SL_METRICS'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SL_METRICS;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SL_METRICS_HISTORY'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SL_METRICS_HISTORY;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SL_RULES'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SL_RULES;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SL_RULES_HISTORY'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SL_RULES_HISTORY;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SPACE_METRICS'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SPACE_METRICS;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SQLPROBLEM_FACTORS'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SQLPROBLEM_FACTORS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SQL_BIND_VARS'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SQL_BIND_VARS;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SQL_EVALUATION'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SQL_EVALUATION;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SQL_METRIC_HELPER'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SQL_METRIC_HELPER;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SQL_PLAN'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SQL_PLAN;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SQL_REUSE'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SQL_REUSE;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SQL_SUMMARY'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_SQL_SUMMARY;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_STORAGE_REPORT_ALIAS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_STORAGE_REPORT_ALIAS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_STORAGE_REPORT_DATA'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_STORAGE_REPORT_DATA;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_STORAGE_REPORT_ISSUES'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_STORAGE_REPORT_ISSUES;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_STORAGE_REPORT_KEYS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_STORAGE_REPORT_KEYS;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_STRING_METRIC_HISTORY'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_STRING_METRIC_HISTORY;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BUG_ADVISORY'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BUG_ADVISORY;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BUG_ADVISORY_BUG'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BUG_ADVISORY_BUG;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BUG_ADV_HOME_PATCH'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BUG_ADV_HOME_PATCH;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BUG_AVAILABLE_PATCH'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BUG_AVAILABLE_PATCH;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BUG_FIX_APPLICABLE_COMP'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BUG_FIX_APPLICABLE_COMP;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BUG_FIX_APPLIC_COMP_LIST'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BUG_FIX_APPLIC_COMP_LIST;                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BUG_PATCH_CERTIFICATE'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BUG_PATCH_CERTIFICATE;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BUG_PATCH_FIXES_BUG'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BUG_PATCH_FIXES_BUG;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BUG_PATCH_PLATFORM'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_BUG_PATCH_PLATFORM;                                            
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CALLBACKS'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CALLBACKS;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CATEGORIES'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CATEGORIES;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CATEGORY_CLASSES'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CATEGORY_CLASSES;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CATEGORY_MAP'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CATEGORY_MAP;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CHANGE_AGENT_URL'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CHANGE_AGENT_URL;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CM_BASELINES'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CM_BASELINES;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CM_BASELINE_CONS_GROUPS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CM_BASELINE_CONS_GROUPS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CM_BASELINE_DEPENDENTS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CM_BASELINE_DEPENDENTS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CM_BASELINE_INIT_PARAMS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CM_BASELINE_INIT_PARAMS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CM_BASELINE_OBJECTS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CM_BASELINE_OBJECTS;                                           
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CM_BASELINE_OBJGRANTS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CM_BASELINE_OBJGRANTS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CM_BASELINE_PROXYGRANTS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CM_BASELINE_PROXYGRANTS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CM_BASELINE_QUOTAGRANTS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CM_BASELINE_QUOTAGRANTS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CM_BASELINE_ROLEGRANTS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CM_BASELINE_ROLEGRANTS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CM_BASELINE_SYSGRANTS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CM_BASELINE_SYSGRANTS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CM_BASELINE_VERSIONS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CM_BASELINE_VERSIONS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CM_COMPARISONS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CM_COMPARISONS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CM_COMPARISON_INIT_PRMS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CM_COMPARISON_INIT_PRMS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CM_COMPARISON_OBJECTS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CM_COMPARISON_OBJECTS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CM_COMPARISON_VERSIONS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CM_COMPARISON_VERSIONS;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CM_SCHEMA_MAPS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CM_SCHEMA_MAPS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CM_SCOPESPECS'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CM_SCOPESPECS;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CM_SCOPESPEC_NAMES'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.MGMT_CM_SCOPESPEC_NAMES;                                            
INSERT INTO temp_size_table                                                     
SELECT 'AQ$_MGMT_LOADER_QTABLE_S'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.AQ$_MGMT_LOADER_QTABLE_S;                                           
INSERT INTO temp_size_table                                                     
SELECT 'AQ$_MGMT_NOTIFY_QTABLE_S'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SYSMAN.AQ$_MGMT_NOTIFY_QTABLE_S;                                           
INSERT INTO temp_size_table                                                     
SELECT 'DR$WK$DOC_PATH_IDX$I'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WK_TEST.DR$WK$DOC_PATH_IDX$I;                                              
INSERT INTO temp_size_table                                                     
SELECT 'DR$WK$DOC_PATH_IDX$R'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WK_TEST.DR$WK$DOC_PATH_IDX$R;                                              
INSERT INTO temp_size_table                                                     
SELECT 'WK$ACL'                                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WK_TEST.WK$ACL;                                                            
INSERT INTO temp_size_table                                                     
SELECT 'WK$ATTR_LOV'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WK_TEST.WK$ATTR_LOV;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'WK$ATTR_VAL'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WK_TEST.WK$ATTR_VAL;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'WK$CACHE'                                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WK_TEST.WK$CACHE;                                                          
INSERT INTO temp_size_table                                                     
SELECT 'WK$DOC'                                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WK_TEST.WK$DOC;                                                            
INSERT INTO temp_size_table                                                     
SELECT 'WK$STATISTIC'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WK_TEST.WK$STATISTIC;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'WK$URL'                                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WK_TEST.WK$URL;                                                            
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_63505'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.SYS_IOT_OVER_63505;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_63668'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.SYS_IOT_OVER_63668;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_63678'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.SYS_IOT_OVER_63678;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_63717'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.SYS_IOT_OVER_63717;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'WK$INSTANCE'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$INSTANCE;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'WK$INST_ADMIN'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$INST_ADMIN;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'WK$LANG'                                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$LANG;                                                             
INSERT INTO temp_size_table                                                     
SELECT 'WK$MIMETYPES'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$MIMETYPES;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'WK$SUBSCRIBER_LIST'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$SUBSCRIBER_LIST;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'WK$SYS_CONFIG'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$SYS_CONFIG;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'WK$SYS_PRIV'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$SYS_PRIV;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'WK$_AGENT'                                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_AGENT;                                                           
INSERT INTO temp_size_table                                                     
SELECT 'WK$_AGENT_INSTANCE'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_AGENT_INSTANCE;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'WK$_AGENT_PARAM'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_AGENT_PARAM;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'WK$_AGENT_PARAM_VAL'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_AGENT_PARAM_VAL;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'WK$_ATTR_MAPPING'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_ATTR_MAPPING;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'WK$ACL_SNAPSHOT'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$ACL_SNAPSHOT;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'WK$CHARSET'                                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$CHARSET;                                                          
INSERT INTO temp_size_table                                                     
SELECT 'WK$CRAWLER_CONFIG_DEFAULT'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$CRAWLER_CONFIG_DEFAULT;                                           
INSERT INTO temp_size_table                                                     
SELECT 'WK$DEFAULT_DATA_SOURCE_PARAM'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$DEFAULT_DATA_SOURCE_PARAM;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WK$DEFAULT_DATA_SOURCE_TYPE'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$DEFAULT_DATA_SOURCE_TYPE;                                         
INSERT INTO temp_size_table                                                     
SELECT 'WK$DOC_LANG'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$DOC_LANG;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'WK$_CRAWLER_CONFIG'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_CRAWLER_CONFIG;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'WK$_CRAWLER_SCHED'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_CRAWLER_SCHED;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'WK$_CRAWLER_STAT'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_CRAWLER_STAT;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'WK$_DATA_SOURCE'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_DATA_SOURCE;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'WK$_DATA_SOURCE_PARAM'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_DATA_SOURCE_PARAM;                                               
INSERT INTO temp_size_table                                                     
SELECT 'WK$_DATA_SOURCE_PARAM_VAL'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_DATA_SOURCE_PARAM_VAL;                                           
INSERT INTO temp_size_table                                                     
SELECT 'WK$_DATA_SOURCE_TL'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_DATA_SOURCE_TL;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'WK$_DATA_SOURCE_TYPE'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_DATA_SOURCE_TYPE;                                                
INSERT INTO temp_size_table                                                     
SELECT 'WK$_DS_PROPERTY'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_DS_PROPERTY;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'WK$_FORM'                                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_FORM;                                                            
INSERT INTO temp_size_table                                                     
SELECT 'WK$_JOB_INFO'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_JOB_INFO;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'WK$_MAILLIST'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_MAILLIST;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'WK$_PORTAL'                                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_PORTAL;                                                          
INSERT INTO temp_size_table                                                     
SELECT 'WK$_PORTAL_DS_MAP'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_PORTAL_DS_MAP;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'WK$_SCHED_MAPPING'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_SCHED_MAPPING;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'WK$_SYS_ADMIN'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_SYS_ADMIN;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'WK$_TDS_LOG'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_TDS_LOG;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'WK$_TRACE'                                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WKSYS.WK$_TRACE;                                                           
INSERT INTO temp_size_table                                                     
SELECT 'CWM$FACTLEVELGROUP'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$FACTLEVELGROUP;                                                
INSERT INTO temp_size_table                                                     
SELECT 'CWM$FACTLEVELUSE'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$FACTLEVELUSE;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'CWM$FACTTABLEMAP'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$FACTTABLEMAP;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'CWM$FACTUSE'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$FACTUSE;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'CWM$FUNCTION'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$FUNCTION;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'CWM$FUNCTIONUSE'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$FUNCTIONUSE;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'CWM$HIERARCHY'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$HIERARCHY;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'CWM$ITEMMAP'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$ITEMMAP;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'CWM$ITEMUSE'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$ITEMUSE;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'CWM$LEVEL'                                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$LEVEL;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'CWM$LEVELATTRIBUTE'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$LEVELATTRIBUTE;                                                
INSERT INTO temp_size_table                                                     
SELECT 'CWM$MEASURE'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$MEASURE;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'CWM$MEASUREDIMENSIONUSE'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$MEASUREDIMENSIONUSE;                                           
INSERT INTO temp_size_table                                                     
SELECT 'CWM$MODEL'                                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$MODEL;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'CWM$OBJECTTYPE'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$OBJECTTYPE;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'CWM$PARAMETER'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$PARAMETER;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'CWM$PROJECT'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$PROJECT;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWCOMPOSITESPEC'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWCOMPOSITESPEC;                                              
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWCOMPSPECMEMBERSHIP'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWCOMPSPECMEMBERSHIP;                                         
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWCUBEAGG'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWCUBEAGG;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWCUBEAGGLEVEL'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWCUBEAGGLEVEL;                                               
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWCUBEAGGMEASURE'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWCUBEAGGMEASURE;                                             
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWCUBECOMPPLAN'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWCUBECOMPPLAN;                                               
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWCUBELOAD'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWCUBELOAD;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWCUBELOADAGGPLAN'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWCUBELOADAGGPLAN;                                            
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWCUBELOADFILTER'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWCUBELOADFILTER;                                             
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWCUBELOADMEASURE'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWCUBELOADMEASURE;                                            
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWCUBELOADPARM'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWCUBELOADPARM;                                               
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWCUBELOADPARMVALUE'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWCUBELOADPARMVALUE;                                          
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWCUBELOADTYPE'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWCUBELOADTYPE;                                               
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWDIMLOAD'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWDIMLOAD;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWDIMLOADFILTER'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWDIMLOADFILTER;                                              
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWDIMLOADPARM'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWDIMLOADPARM;                                                
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWDIMLOADPARMVALUE'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWDIMLOADPARMVALUE;                                           
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWDIMLOADTYPE'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWDIMLOADTYPE;                                                
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWVIEWCOLS'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWVIEWCOLS;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AWVIEWS'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AWVIEWS;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AW_DIMENSIONMAP'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AW_DIMENSIONMAP;                                              
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$AW_MEASUREMAP'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$AW_MEASUREMAP;                                                
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$CLASSIFICATIONVALUEPAIR'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$CLASSIFICATIONVALUEPAIR;                                      
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$CUBE'                                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$CUBE;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$CUBEDIMENSIONUSE'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$CUBEDIMENSIONUSE;                                             
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$DIMENSION'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$DIMENSION;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$DIMENSIONATTRIBUTE'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$DIMENSIONATTRIBUTE;                                           
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$DIMHIERLVLMAP'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$DIMHIERLVLMAP;                                                
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$FACTDIMHIERMAP'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$FACTDIMHIERMAP;                                               
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$FACTDIMHIERTPLSDTL'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$FACTDIMHIERTPLSDTL;                                           
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$FACTKEYDIMHIERLVLMAP'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$FACTKEYDIMHIERLVLMAP;                                         
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$FACTKEYDIMHIERMAP'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$FACTKEYDIMHIERMAP;                                            
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$HIERARCHY'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$HIERARCHY;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$HIERCUSTOMSORT'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$HIERCUSTOMSORT;                                               
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$HIERLEVELREL'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$HIERLEVELREL;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$LEVEL'                                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$LEVEL;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$LEVELATTRIBUTE'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$LEVELATTRIBUTE;                                               
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$LEVELATTRIBUTEMAP'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$LEVELATTRIBUTEMAP;                                            
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MEASURE'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MEASURE;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MEASURETABLEMAP'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MEASURETABLEMAP;                                              
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_AWVIEWCOLS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_AWVIEWCOLS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_AWVIEWS'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_AWVIEWS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_CATALOGS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_CATALOGS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_CATALOG_ENTITY_USES'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_CATALOG_ENTITY_USES;                                    
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_CUBE_MEASURES'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_CUBE_MEASURES;                                          
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_CWM1_AGGOP'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_CWM1_AGGOP;                                             
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_CWM1_AGGORD'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_CWM1_AGGORD;                                            
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_DESCRIPTORS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_DESCRIPTORS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_DIM_ATTRIBUTES'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_DIM_ATTRIBUTES;                                         
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_DIM_HIERS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_DIM_HIERS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_DIM_HIER_LEVEL_USES'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_DIM_HIER_LEVEL_USES;                                    
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_DIM_LEVEL_ATTR_MAPS'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_DIM_LEVEL_ATTR_MAPS;                                    
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_ENTITY_DESC_USES'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_ENTITY_DESC_USES;                                       
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_ENTITY_EXT_PARMS'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_ENTITY_EXT_PARMS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_ENTITY_PARAMETERS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_ENTITY_PARAMETERS;                                      
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_FACTTBLFCTMAPS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_FACTTBLFCTMAPS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_FACTTBLKEYMAPS'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_FACTTBLKEYMAPS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_HIERDIMS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_HIERDIMS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_HIERDIM_KEYCOL_MAP'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_HIERDIM_KEYCOL_MAP;                                     
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_HIER_CUSTOM_SORT'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_HIER_CUSTOM_SORT;                                       
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_JOIN_KEY_COL_USES'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_JOIN_KEY_COL_USES;                                      
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_LISTDIMS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_LISTDIMS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRALL_OLAP2_AGG_USES'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRALL_OLAP2_AGG_USES;                                         
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRFACTTBLFCTMAPS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRFACTTBLFCTMAPS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$MRFACTTBLKEYMAPS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$MRFACTTBLKEYMAPS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$STOREDDIMLVLTPLS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$STOREDDIMLVLTPLS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$STOREDDIMLVLTPLSDTL'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$STOREDDIMLVLTPLSDTL;                                          
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$_AW_NEXT_PERM_CUST_MEAS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$_AW_NEXT_PERM_CUST_MEAS;                                      
INSERT INTO temp_size_table                                                     
SELECT 'CWM2$_AW_PERM_CUST_MEAS_MAP'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM2$_AW_PERM_CUST_MEAS_MAP;                                       
INSERT INTO temp_size_table                                                     
SELECT 'CWM$ARGUMENT'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$ARGUMENT;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'CWM$CLASSIFICATION'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$CLASSIFICATION;                                                
INSERT INTO temp_size_table                                                     
SELECT 'CWM$CLASSIFICATIONENTRY'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$CLASSIFICATIONENTRY;                                           
INSERT INTO temp_size_table                                                     
SELECT 'CWM$CLASSIFICATIONTYPE'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$CLASSIFICATIONTYPE;                                            
INSERT INTO temp_size_table                                                     
SELECT 'CWM$CUBE'                                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$CUBE;                                                          
INSERT INTO temp_size_table                                                     
SELECT 'CWM$CUBEDIMENSIONUSE'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$CUBEDIMENSIONUSE;                                              
INSERT INTO temp_size_table                                                     
SELECT 'CWM$DIMENSION'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$DIMENSION;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'CWM$DIMENSIONATTRIBUTE'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$DIMENSIONATTRIBUTE;                                            
INSERT INTO temp_size_table                                                     
SELECT 'CWM$DOMAIN'                                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.CWM$DOMAIN;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'MRAC_OLAP2_AWS_T'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.MRAC_OLAP2_AWS_T;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MRAC_OLAP2_AW_ATTRIBUTES_T'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.MRAC_OLAP2_AW_ATTRIBUTES_T;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MRAC_OLAP2_AW_CUBES_T'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.MRAC_OLAP2_AW_CUBES_T;                                             
INSERT INTO temp_size_table                                                     
SELECT 'MRAC_OLAP2_AW_CUBE_AGG_LVL_T'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.MRAC_OLAP2_AW_CUBE_AGG_LVL_T;                                      
INSERT INTO temp_size_table                                                     
SELECT 'MRAC_OLAP2_AW_CUBE_AGG_MEAS_T'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.MRAC_OLAP2_AW_CUBE_AGG_MEAS_T;                                     
INSERT INTO temp_size_table                                                     
SELECT 'MRAC_OLAP2_AW_CUBE_AGG_OP_T'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.MRAC_OLAP2_AW_CUBE_AGG_OP_T;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MRAC_OLAP2_AW_CUBE_AGG_SPECS_T'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.MRAC_OLAP2_AW_CUBE_AGG_SPECS_T;                                    
INSERT INTO temp_size_table                                                     
SELECT 'MRAC_OLAP2_AW_CUBE_DIM_USES_T'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.MRAC_OLAP2_AW_CUBE_DIM_USES_T;                                     
INSERT INTO temp_size_table                                                     
SELECT 'MRAC_OLAP2_AW_CUBE_MEASURES_T'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.MRAC_OLAP2_AW_CUBE_MEASURES_T;                                     
INSERT INTO temp_size_table                                                     
SELECT 'MRAC_OLAP2_AW_DIMENSIONS_T'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.MRAC_OLAP2_AW_DIMENSIONS_T;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MRAC_OLAP2_AW_DIM_LEVELS_T'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.MRAC_OLAP2_AW_DIM_LEVELS_T;                                        
INSERT INTO temp_size_table                                                     
SELECT 'MRAC_OLAP2_AW_HIER_LVL_ORD_T'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.MRAC_OLAP2_AW_HIER_LVL_ORD_T;                                      
INSERT INTO temp_size_table                                                     
SELECT 'MRAC_OLAP2_AW_MAP_ATTR_USE_T'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.MRAC_OLAP2_AW_MAP_ATTR_USE_T;                                      
INSERT INTO temp_size_table                                                     
SELECT 'MRAC_OLAP2_AW_MAP_DIM_USE_T'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.MRAC_OLAP2_AW_MAP_DIM_USE_T;                                       
INSERT INTO temp_size_table                                                     
SELECT 'MRAC_OLAP2_AW_MAP_MEAS_USE_T'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.MRAC_OLAP2_AW_MAP_MEAS_USE_T;                                      
INSERT INTO temp_size_table                                                     
SELECT 'MRAC_OLAP2_AW_PHYS_OBJ_PROP_T'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.MRAC_OLAP2_AW_PHYS_OBJ_PROP_T;                                     
INSERT INTO temp_size_table                                                     
SELECT 'MRAC_OLAP2_AW_PHYS_OBJ_T'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.MRAC_OLAP2_AW_PHYS_OBJ_T;                                          
INSERT INTO temp_size_table                                                     
SELECT 'XML_LOAD_LOG'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.XML_LOAD_LOG;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'XML_LOAD_RECORDS'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OLAPSYS.XML_LOAD_RECORDS;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'SI_FEATURES_TAB'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.SI_FEATURES_TAB;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'SI_IMAGE_FORMATS_TAB'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.SI_IMAGE_FORMATS_TAB;                                               
INSERT INTO temp_size_table                                                     
SELECT 'SI_VALUES_TAB'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.SI_VALUES_TAB;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_ANON_ACTION_TYPES'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_ANON_ACTION_TYPES;                                           
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_ANON_ATTRS'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_ANON_ATTRS;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_ANON_ATTRS_WRK'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_ANON_ATTRS_WRK;                                              
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_ANON_RULES'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_ANON_RULES;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_ANON_RULES_WRK'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_ANON_RULES_WRK;                                              
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_ANON_RULE_TYPES'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_ANON_RULE_TYPES;                                             
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_MAPPED_PATHS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_MAPPED_PATHS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_MAPPED_PATHS_WRK'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_MAPPED_PATHS_WRK;                                            
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_MAPPING_DOCS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_MAPPING_DOCS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_MAPPING_DOCS_WRK'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_MAPPING_DOCS_WRK;                                            
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_PREFS_LOOKUP'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_PREFS_LOOKUP;                                                
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_PRV_ATTRS'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_PRV_ATTRS;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_PRV_ATTRS_WRK'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_PRV_ATTRS_WRK;                                               
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_RT_PREF_PARAMS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_RT_PREF_PARAMS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_RT_PREF_PARAMS_WRK'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_RT_PREF_PARAMS_WRK;                                          
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_STD_ATTRS'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_STD_ATTRS;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_STD_ATTRS_WRK'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_STD_ATTRS_WRK;                                               
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_UID_DEFS'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_UID_DEFS;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_UID_DEFS_WRK'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_UID_DEFS_WRK;                                                
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_VR_DT_MAP'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_VR_DT_MAP;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_CT_ACTION'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_CT_ACTION;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_CT_ACTION_WRK'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_CT_ACTION_WRK;                                               
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_CT_DAREFS'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_CT_DAREFS;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_CT_DAREFS_WRK'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_CT_DAREFS_WRK;                                               
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_CT_MACRO_PAR'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_CT_MACRO_PAR;                                                
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_CT_MACRO_PAR_WRK'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_CT_MACRO_PAR_WRK;                                            
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_CT_PRED'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_CT_PRED;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_CT_PRED_OPRD'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_CT_PRED_OPRD;                                                
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_CT_PRED_OPRD_WRK'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_CT_PRED_OPRD_WRK;                                            
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_CT_PRED_PAR'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_CT_PRED_PAR;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_CT_PRED_PAR_WRK'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_CT_PRED_PAR_WRK;                                             
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_CT_PRED_SET'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_CT_PRED_SET;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_CT_PRED_SET_WRK'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_CT_PRED_SET_WRK;                                             
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_CT_PRED_WRK'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_CT_PRED_WRK;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_CT_VLD_MSG'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_CT_VLD_MSG;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_DATA_MODEL'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_DATA_MODEL;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_DATA_MODEL_WRK'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_DATA_MODEL_WRK;                                              
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_DICT_ATTRS'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_DICT_ATTRS;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_DICT_ATTRS_WRK'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_DICT_ATTRS_WRK;                                              
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_DOCS'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_DOCS;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_DOCS_WRK'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_DOCS_WRK;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_DOC_REFS'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_DOC_REFS;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_DOC_REFS_WRK'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_DOC_REFS_WRK;                                                
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_DOC_TYPES'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_DOC_TYPES;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'ORDDCM_INSTALL_DOCS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORDDCM_INSTALL_DOCS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'ORD_CARTRIDGE_COMPONENTS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORD_CARTRIDGE_COMPONENTS;                                           
INSERT INTO temp_size_table                                                     
SELECT 'ORD_USAGE_RECS'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM ORDSYS.ORD_USAGE_RECS;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'EXF$DEFIDXPARAM'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.EXF$DEFIDXPARAM;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'EXF$ESETIDXPARAM'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.EXF$ESETIDXPARAM;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'EXF$PARAMETER'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.EXF$PARAMETER;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'EXF$PLAN_TABLE'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.EXF$PLAN_TABLE;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'EXF$PREDATTRMAP'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.EXF$PREDATTRMAP;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'EXF$VALIDIOPER'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.EXF$VALIDIOPER;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'EXF$VALIDPRIVS'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.EXF$VALIDPRIVS;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'EXF$VERSION'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.EXF$VERSION;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'RLM$SCHACTLIST'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.RLM$SCHACTLIST;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_53577'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.SYS_IOT_OVER_53577;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_53587'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.SYS_IOT_OVER_53587;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_55473'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.SYS_IOT_OVER_55473;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_55481'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.SYS_IOT_OVER_55481;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_55488'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.SYS_IOT_OVER_55488;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_55491'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.SYS_IOT_OVER_55491;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_55494'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.SYS_IOT_OVER_55494;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_55514'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.SYS_IOT_OVER_55514;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_55517'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.SYS_IOT_OVER_55517;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_55520'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.SYS_IOT_OVER_55520;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_55523'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM EXFSYS.SYS_IOT_OVER_55523;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'WM$WORKSPACES_TABLE'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$WORKSPACES_TABLE;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'WM$WORKSPACE_PRIV_TABLE'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$WORKSPACE_PRIV_TABLE;                                             
INSERT INTO temp_size_table                                                     
SELECT 'WM$WORKSPACE_SAVEPOINTS_TABLE'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$WORKSPACE_SAVEPOINTS_TABLE;                                       
INSERT INTO temp_size_table                                                     
SELECT 'AQ$_WM$EVENT_QUEUE_TABLE_S'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.AQ$_WM$EVENT_QUEUE_TABLE_S;                                          
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_12358'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.SYS_IOT_OVER_12358;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'WM$ADT_FUNC_TABLE'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$ADT_FUNC_TABLE;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'WM$BATCH_COMPRESSIBLE_TABLES'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$BATCH_COMPRESSIBLE_TABLES;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WM$CONSTRAINTS_TABLE'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$CONSTRAINTS_TABLE;                                                
INSERT INTO temp_size_table                                                     
SELECT 'WM$CONS_COLUMNS'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$CONS_COLUMNS;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'WM$ENV_VARS'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$ENV_VARS;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'WM$EVENTS_INFO'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$EVENTS_INFO;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'WM$EVENT_QUEUE_TABLE'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$EVENT_QUEUE_TABLE;                                                
INSERT INTO temp_size_table                                                     
SELECT 'WM$HINT_TABLE'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$HINT_TABLE;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'WM$INSTEADOF_TRIGS_TABLE'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$INSTEADOF_TRIGS_TABLE;                                            
INSERT INTO temp_size_table                                                     
SELECT 'WM$LOCKROWS_INFO'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$LOCKROWS_INFO;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'WM$LOG_TABLE'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$LOG_TABLE;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'WM$LOG_TABLE_ERRORS'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$LOG_TABLE_ERRORS;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'WM$MODIFIED_TABLES'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$MODIFIED_TABLES;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'WM$MP_GRAPH_WORKSPACES_TABLE'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$MP_GRAPH_WORKSPACES_TABLE;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WM$MP_PARENT_WORKSPACES_TABLE'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$MP_PARENT_WORKSPACES_TABLE;                                       
INSERT INTO temp_size_table                                                     
SELECT 'WM$NESTED_COLUMNS_TABLE'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$NESTED_COLUMNS_TABLE;                                             
INSERT INTO temp_size_table                                                     
SELECT 'WM$NEXTVER_TABLE'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$NEXTVER_TABLE;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'WM$REMOVED_WORKSPACES_TABLE'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$REMOVED_WORKSPACES_TABLE;                                         
INSERT INTO temp_size_table                                                     
SELECT 'WM$REPLICATION_DETAILS_TABLE'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$REPLICATION_DETAILS_TABLE;                                        
INSERT INTO temp_size_table                                                     
SELECT 'WM$REPLICATION_TABLE'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$REPLICATION_TABLE;                                                
INSERT INTO temp_size_table                                                     
SELECT 'WM$RESOLVE_WORKSPACES_TABLE'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$RESOLVE_WORKSPACES_TABLE;                                         
INSERT INTO temp_size_table                                                     
SELECT 'WM$RIC_LOCKING_TABLE'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$RIC_LOCKING_TABLE;                                                
INSERT INTO temp_size_table                                                     
SELECT 'WM$RIC_TABLE'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$RIC_TABLE;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'WM$RIC_TRIGGERS_TABLE'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$RIC_TRIGGERS_TABLE;                                               
INSERT INTO temp_size_table                                                     
SELECT 'WM$SYSPARAM_ALL_VALUES'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$SYSPARAM_ALL_VALUES;                                              
INSERT INTO temp_size_table                                                     
SELECT 'WM$TMP_DBA_CONSTRAINTS'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$TMP_DBA_CONSTRAINTS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'WM$UDTRIG_DISPATCH_PROCS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$UDTRIG_DISPATCH_PROCS;                                            
INSERT INTO temp_size_table                                                     
SELECT 'WM$UDTRIG_INFO'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$UDTRIG_INFO;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'WM$VERSIONED_TABLES'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$VERSIONED_TABLES;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'WM$VERSION_HIERARCHY_TABLE'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$VERSION_HIERARCHY_TABLE;                                          
INSERT INTO temp_size_table                                                     
SELECT 'WM$VERSION_TABLE'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$VERSION_TABLE;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'WM$VT_ERRORS_TABLE'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM WMSYS.WM$VT_ERRORS_TABLE;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'BSLN_BASELINES'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM DBSNMP.BSLN_BASELINES;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'BSLN_METRIC_DEFAULTS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM DBSNMP.BSLN_METRIC_DEFAULTS;                                               
INSERT INTO temp_size_table                                                     
SELECT 'BSLN_STATISTICS'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM DBSNMP.BSLN_STATISTICS;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'BSLN_THRESHOLD_PARAMS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM DBSNMP.BSLN_THRESHOLD_PARAMS;                                              
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BASELINE'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM DBSNMP.MGMT_BASELINE;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_BASELINE_SQL'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM DBSNMP.MGMT_BASELINE_SQL;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CAPTURE'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM DBSNMP.MGMT_CAPTURE;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_CAPTURE_SQL'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM DBSNMP.MGMT_CAPTURE_SQL;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_DB_FEATURE_LOG'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM DBSNMP.MGMT_DB_FEATURE_LOG;                                                
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HISTORY'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM DBSNMP.MGMT_HISTORY;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_HISTORY_SQL'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM DBSNMP.MGMT_HISTORY_SQL;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_LATEST'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM DBSNMP.MGMT_LATEST;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_LATEST_SQL'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM DBSNMP.MGMT_LATEST_SQL;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_RESPONSE_CONFIG'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM DBSNMP.MGMT_RESPONSE_CONFIG;                                               
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SNAPSHOT'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM DBSNMP.MGMT_SNAPSHOT;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'MGMT_SNAPSHOT_SQL'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM DBSNMP.MGMT_SNAPSHOT_SQL;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'Folder36_TAB'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.Folder36_TAB;                                                          
INSERT INTO temp_size_table                                                     
SELECT 'MIGR9202STATUS'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.MIGR9202STATUS;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'SERVLET'                                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.SERVLET;                                                               
INSERT INTO temp_size_table                                                     
SELECT 'X$NM1TFI27JCELMFRV0G24J2PT4IJL'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.X$NM1TFI27JCELMFRV0G24J2PT4IJL;                                        
INSERT INTO temp_size_table                                                     
SELECT 'X$PT1TFI27JCELMFRV0G24J2PT4IJL'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.X$PT1TFI27JCELMFRV0G24J2PT4IJL;                                        
INSERT INTO temp_size_table                                                     
SELECT 'X$QN1TFI27JCELMFRV0G24J2PT4IJL'                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.X$QN1TFI27JCELMFRV0G24J2PT4IJL;                                        
INSERT INTO temp_size_table                                                     
SELECT 'XDB$ACL'                                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$ACL;                                                               
INSERT INTO temp_size_table                                                     
SELECT 'XDB$ALL_MODEL'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$ALL_MODEL;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'XDB$ANY'                                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$ANY;                                                               
INSERT INTO temp_size_table                                                     
SELECT 'XDB$ANYATTR'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$ANYATTR;                                                           
INSERT INTO temp_size_table                                                     
SELECT 'XDB$ATTRGROUP_DEF'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$ATTRGROUP_DEF;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'XDB$ATTRGROUP_REF'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$ATTRGROUP_REF;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'XDB$ATTRIBUTE'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$ATTRIBUTE;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'XDB$CHECKOUTS'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$CHECKOUTS;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'XDB$CHOICE_MODEL'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$CHOICE_MODEL;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'XDB$COLUMN_INFO'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$COLUMN_INFO;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'XDB$COMPLEX_TYPE'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$COMPLEX_TYPE;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'XDB$CONFIG'                                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$CONFIG;                                                            
INSERT INTO temp_size_table                                                     
SELECT 'XDB$DXPTAB'                                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$DXPTAB;                                                            
INSERT INTO temp_size_table                                                     
SELECT 'XDB$D_LINK'                                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$D_LINK;                                                            
INSERT INTO temp_size_table                                                     
SELECT 'XDB$ELEMENT'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$ELEMENT;                                                           
INSERT INTO temp_size_table                                                     
SELECT 'XDB$GROUP_DEF'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$GROUP_DEF;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'XDB$GROUP_REF'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$GROUP_REF;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'XDB$H_INDEX'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$H_INDEX;                                                           
INSERT INTO temp_size_table                                                     
SELECT 'XDB$H_LINK'                                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$H_LINK;                                                            
INSERT INTO temp_size_table                                                     
SELECT 'XDB$NLOCKS'                                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$NLOCKS;                                                            
INSERT INTO temp_size_table                                                     
SELECT 'XDB$NONCEKEY'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$NONCEKEY;                                                          
INSERT INTO temp_size_table                                                     
SELECT 'XDB$PATH_INDEX_PARAMS'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$PATH_INDEX_PARAMS;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'XDB$RESCONFIG'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$RESCONFIG;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'XDB$RESOURCE'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$RESOURCE;                                                          
INSERT INTO temp_size_table                                                     
SELECT 'XDB$ROOT_INFO'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$ROOT_INFO;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'XDB$SCHEMA'                                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$SCHEMA;                                                            
INSERT INTO temp_size_table                                                     
SELECT 'XDB$SEQUENCE_MODEL'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$SEQUENCE_MODEL;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'XDB$SIMPLE_TYPE'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$SIMPLE_TYPE;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'XDB$STATS'                                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$STATS;                                                             
INSERT INTO temp_size_table                                                     
SELECT 'XDB$TTSET'                                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$TTSET;                                                             
INSERT INTO temp_size_table                                                     
SELECT 'XDB$WORKSPACE'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$WORKSPACE;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'XDB$XDB_READY'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDB$XDB_READY;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'XDBACL_PATH_TAB'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XDBACL_PATH_TAB;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'XS$CACHE_ACTIONS'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XS$CACHE_ACTIONS;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'XS$CACHE_DELETE'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XS$CACHE_DELETE;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'XS$DATA_SECURITY'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XS$DATA_SECURITY;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'XS$PRINCIPALS'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XS$PRINCIPALS;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'XS$ROLESETS'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XS$ROLESETS;                                                           
INSERT INTO temp_size_table                                                     
SELECT 'XS$SECURITYCLASS'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.XS$SECURITYCLASS;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'aggregatePrivilege174_TAB'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.aggregatePrivilege174_TAB;                                             
INSERT INTO temp_size_table                                                     
SELECT 'fallback42_TAB'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.fallback42_TAB;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'fallback43_TAB'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.fallback43_TAB;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'fallback61_TAB'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.fallback61_TAB;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'fallback62_TAB'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.fallback62_TAB;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'ftp-log21_TAB'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB."ftp-log21_TAB";                                                         
INSERT INTO temp_size_table                                                     
SELECT 'http-log30_TAB'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB."http-log30_TAB";                                                        
INSERT INTO temp_size_table                                                     
SELECT 'include47_TAB'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.include47_TAB;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'include66_TAB'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.include66_TAB;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'privilege173_TAB'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB.privilege173_TAB;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'xdb-log13_TAB'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM XDB."xdb-log13_TAB";                                                         
INSERT INTO temp_size_table                                                     
SELECT 'SRS$'                                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM TSMSYS.SRS$;                                                               
INSERT INTO temp_size_table                                                     
SELECT 'TEMP_SIZE_TABLE'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.TEMP_SIZE_TABLE;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'TEST_LOBTABLE'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.TEST_LOBTABLE;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'CATEGORIES_TAB'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OE.CATEGORIES_TAB;                                                         
INSERT INTO temp_size_table                                                     
SELECT 'PURCHASEORDER'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OE.PURCHASEORDER;                                                          
INSERT INTO temp_size_table                                                     
SELECT 'BONUS'                                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SCOTT.BONUS;                                                               
INSERT INTO temp_size_table                                                     
SELECT 'DEPT'                                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SCOTT.DEPT;                                                                
INSERT INTO temp_size_table                                                     
SELECT 'EMP'                                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SCOTT.EMP;                                                                 
INSERT INTO temp_size_table                                                     
SELECT 'SALGRADE'                                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SCOTT.SALGRADE;                                                            
INSERT INTO temp_size_table                                                     
SELECT 'ONLINE_MEDIA'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PM.ONLINE_MEDIA;                                                           
INSERT INTO temp_size_table                                                     
SELECT 'PRINT_MEDIA'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PM.PRINT_MEDIA;                                                            
INSERT INTO temp_size_table                                                     
SELECT 'CAL_MONTH_SALES_MV'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SH.CAL_MONTH_SALES_MV;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'CHANNELS'                                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SH.CHANNELS;                                                               
INSERT INTO temp_size_table                                                     
SELECT 'SUPPLEMENTARY_DEMOGRAPHICS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SH.SUPPLEMENTARY_DEMOGRAPHICS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'TIMES'                                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SH.TIMES;                                                                  
INSERT INTO temp_size_table                                                     
SELECT 'COUNTRIES'                                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SH.COUNTRIES;                                                              
INSERT INTO temp_size_table                                                     
SELECT 'CUSTOMERS'                                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SH.CUSTOMERS;                                                              
INSERT INTO temp_size_table                                                     
SELECT 'DIMENSION_EXCEPTIONS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SH.DIMENSION_EXCEPTIONS;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'DR$SUP_TEXT_IDX$I'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SH.DR$SUP_TEXT_IDX$I;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'DR$SUP_TEXT_IDX$R'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SH.DR$SUP_TEXT_IDX$R;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'FWEEK_PSCAT_SALES_MV'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SH.FWEEK_PSCAT_SALES_MV;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'PRODUCTS'                                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SH.PRODUCTS;                                                               
INSERT INTO temp_size_table                                                     
SELECT 'PROMOTIONS'                                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM SH.PROMOTIONS;                                                             
INSERT INTO temp_size_table                                                     
SELECT 'STREAMS_QUEUE_TABLE'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM IX.STREAMS_QUEUE_TABLE;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_70403'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM IX.SYS_IOT_OVER_70403;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'SYS_IOT_OVER_70420'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM IX.SYS_IOT_OVER_70420;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'AQ$_ORDERS_QUEUETABLE_S'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM IX.AQ$_ORDERS_QUEUETABLE_S;                                                
INSERT INTO temp_size_table                                                     
SELECT 'AQ$_STREAMS_QUEUE_TABLE_S'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM IX.AQ$_STREAMS_QUEUE_TABLE_S;                                              
INSERT INTO temp_size_table                                                     
SELECT 'ORDERS_QUEUETABLE'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM IX.ORDERS_QUEUETABLE;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'CUSTOMERS'                                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OE.CUSTOMERS;                                                              
INSERT INTO temp_size_table                                                     
SELECT 'INVENTORIES'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OE.INVENTORIES;                                                            
INSERT INTO temp_size_table                                                     
SELECT 'ORDERS'                                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OE.ORDERS;                                                                 
INSERT INTO temp_size_table                                                     
SELECT 'ORDER_ITEMS'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OE.ORDER_ITEMS;                                                            
INSERT INTO temp_size_table                                                     
SELECT 'PRODUCT_DESCRIPTIONS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OE.PRODUCT_DESCRIPTIONS;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'PRODUCT_INFORMATION'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OE.PRODUCT_INFORMATION;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'PROMOTIONS'                                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OE.PROMOTIONS;                                                             
INSERT INTO temp_size_table                                                     
SELECT 'WAREHOUSES'                                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM OE.WAREHOUSES;                                                             
INSERT INTO temp_size_table                                                     
SELECT 'DEPARTMENTS'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM HR.DEPARTMENTS;                                                            
INSERT INTO temp_size_table                                                     
SELECT 'EMPLOYEES'                                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM HR.EMPLOYEES;                                                              
INSERT INTO temp_size_table                                                     
SELECT 'JOBS'                                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM HR.JOBS;                                                                   
INSERT INTO temp_size_table                                                     
SELECT 'JOB_HISTORY'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM HR.JOB_HISTORY;                                                            
INSERT INTO temp_size_table                                                     
SELECT 'LOCATIONS'                                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM HR.LOCATIONS;                                                              
INSERT INTO temp_size_table                                                     
SELECT 'REGIONS'                                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM HR.REGIONS;                                                                
INSERT INTO temp_size_table                                                     
SELECT 'ANAL_TEST'                                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.ANAL_TEST;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'CHAINED'                                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.CHAINED;                                                          
INSERT INTO temp_size_table                                                     
SELECT 'DBA_RUNNING_STATS'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.DBA_RUNNING_STATS;                                                
INSERT INTO temp_size_table                                                     
SELECT 'PLAN_TABLE'                                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.PLAN_TABLE;                                                       
INSERT INTO temp_size_table                                                     
SELECT 'SQLTEMP'                                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.SQLTEMP;                                                          
INSERT INTO temp_size_table                                                     
SELECT 'STATS$BUFFERED_QUEUES'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$BUFFERED_QUEUES;                                            
INSERT INTO temp_size_table                                                     
SELECT 'STATS$BUFFERED_SUBSCRIBERS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$BUFFERED_SUBSCRIBERS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'STATS$BUFFER_POOL_STATISTICS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$BUFFER_POOL_STATISTICS;                                     
INSERT INTO temp_size_table                                                     
SELECT 'STATS$CR_BLOCK_SERVER'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$CR_BLOCK_SERVER;                                            
INSERT INTO temp_size_table                                                     
SELECT 'STATS$CURRENT_BLOCK_SERVER'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$CURRENT_BLOCK_SERVER;                                       
INSERT INTO temp_size_table                                                     
SELECT 'STATS$DATABASE_INSTANCE'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$DATABASE_INSTANCE;                                          
INSERT INTO temp_size_table                                                     
SELECT 'STATS$DB_CACHE_ADVICE'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$DB_CACHE_ADVICE;                                            
INSERT INTO temp_size_table                                                     
SELECT 'STATS$DLM_MISC'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$DLM_MISC;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'STATS$DYNAMIC_REMASTER_STATS'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$DYNAMIC_REMASTER_STATS;                                     
INSERT INTO temp_size_table                                                     
SELECT 'STATS$ENQUEUE_STATISTICS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$ENQUEUE_STATISTICS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'STATS$EVENT_HISTOGRAM'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$EVENT_HISTOGRAM;                                            
INSERT INTO temp_size_table                                                     
SELECT 'STATS$FILESTATXS'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$FILESTATXS;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'STATS$FILE_HISTOGRAM'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$FILE_HISTOGRAM;                                             
INSERT INTO temp_size_table                                                     
SELECT 'STATS$IDLE_EVENT'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$IDLE_EVENT;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'STATS$INSTANCE_CACHE_TRANSFER'                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$INSTANCE_CACHE_TRANSFER;                                    
INSERT INTO temp_size_table                                                     
SELECT 'STATS$INSTANCE_RECOVERY'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$INSTANCE_RECOVERY;                                          
INSERT INTO temp_size_table                                                     
SELECT 'STATS$INTERCONNECT_PINGS'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$INTERCONNECT_PINGS;                                         
INSERT INTO temp_size_table                                                     
SELECT 'STATS$IOSTAT_FUNCTION'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$IOSTAT_FUNCTION;                                            
INSERT INTO temp_size_table                                                     
SELECT 'STATS$IOSTAT_FUNCTION_NAME'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$IOSTAT_FUNCTION_NAME;                                       
INSERT INTO temp_size_table                                                     
SELECT 'STATS$JAVA_POOL_ADVICE'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$JAVA_POOL_ADVICE;                                           
INSERT INTO temp_size_table                                                     
SELECT 'STATS$LATCH'                                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$LATCH;                                                      
INSERT INTO temp_size_table                                                     
SELECT 'STATS$LATCH_CHILDREN'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$LATCH_CHILDREN;                                             
INSERT INTO temp_size_table                                                     
SELECT 'STATS$LATCH_MISSES_SUMMARY'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$LATCH_MISSES_SUMMARY;                                       
INSERT INTO temp_size_table                                                     
SELECT 'STATS$LATCH_PARENT'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$LATCH_PARENT;                                               
INSERT INTO temp_size_table                                                     
SELECT 'STATS$LEVEL_DESCRIPTION'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$LEVEL_DESCRIPTION;                                          
INSERT INTO temp_size_table                                                     
SELECT 'STATS$LIBRARYCACHE'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$LIBRARYCACHE;                                               
INSERT INTO temp_size_table                                                     
SELECT 'STATS$MEMORY_DYNAMIC_COMPS'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$MEMORY_DYNAMIC_COMPS;                                       
INSERT INTO temp_size_table                                                     
SELECT 'STATS$MEMORY_RESIZE_OPS'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$MEMORY_RESIZE_OPS;                                          
INSERT INTO temp_size_table                                                     
SELECT 'STATS$MEMORY_TARGET_ADVICE'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$MEMORY_TARGET_ADVICE;                                       
INSERT INTO temp_size_table                                                     
SELECT 'STATS$MUTEX_SLEEP'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$MUTEX_SLEEP;                                                
INSERT INTO temp_size_table                                                     
SELECT 'STATS$OSSTAT'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$OSSTAT;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'STATS$OSSTATNAME'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$OSSTATNAME;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'STATS$PARAMETER'                                                        
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$PARAMETER;                                                  
INSERT INTO temp_size_table                                                     
SELECT 'STATS$PGASTAT'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$PGASTAT;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'STATS$PGA_TARGET_ADVICE'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$PGA_TARGET_ADVICE;                                          
INSERT INTO temp_size_table                                                     
SELECT 'STATS$PROCESS_MEMORY_ROLLUP'                                            
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$PROCESS_MEMORY_ROLLUP;                                      
INSERT INTO temp_size_table                                                     
SELECT 'STATS$PROCESS_ROLLUP'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$PROCESS_ROLLUP;                                             
INSERT INTO temp_size_table                                                     
SELECT 'STATS$PROPAGATION_RECEIVER'                                             
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$PROPAGATION_RECEIVER;                                       
INSERT INTO temp_size_table                                                     
SELECT 'STATS$PROPAGATION_SENDER'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$PROPAGATION_SENDER;                                         
INSERT INTO temp_size_table                                                     
SELECT 'STATS$RESOURCE_LIMIT'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$RESOURCE_LIMIT;                                             
INSERT INTO temp_size_table                                                     
SELECT 'STATS$ROLLSTAT'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$ROLLSTAT;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'STATS$ROWCACHE_SUMMARY'                                                 
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$ROWCACHE_SUMMARY;                                           
INSERT INTO temp_size_table                                                     
SELECT 'STATS$RULE_SET'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$RULE_SET;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'STATS$SEG_STAT'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$SEG_STAT;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'STATS$SEG_STAT_OBJ'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$SEG_STAT_OBJ;                                               
INSERT INTO temp_size_table                                                     
SELECT 'STATS$SESSION_EVENT'                                                    
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$SESSION_EVENT;                                              
INSERT INTO temp_size_table                                                     
SELECT 'STATS$SESSTAT'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$SESSTAT;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'STATS$SESS_TIME_MODEL'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$SESS_TIME_MODEL;                                            
INSERT INTO temp_size_table                                                     
SELECT 'STATS$SGA'                                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$SGA;                                                        
INSERT INTO temp_size_table                                                     
SELECT 'STATS$SGASTAT'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$SGASTAT;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'STATS$SGA_TARGET_ADVICE'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$SGA_TARGET_ADVICE;                                          
INSERT INTO temp_size_table                                                     
SELECT 'STATS$SHARED_POOL_ADVICE'                                               
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$SHARED_POOL_ADVICE;                                         
INSERT INTO temp_size_table                                                     
SELECT 'STATS$SNAPSHOT'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$SNAPSHOT;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'STATS$SQLTEXT'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$SQLTEXT;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'STATS$SQL_PLAN'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$SQL_PLAN;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'STATS$SQL_PLAN_USAGE'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$SQL_PLAN_USAGE;                                             
INSERT INTO temp_size_table                                                     
SELECT 'STATS$SQL_STATISTICS'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$SQL_STATISTICS;                                             
INSERT INTO temp_size_table                                                     
SELECT 'STATS$SQL_SUMMARY'                                                      
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$SQL_SUMMARY;                                                
INSERT INTO temp_size_table                                                     
SELECT 'STATS$SQL_WORKAREA_HISTOGRAM'                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$SQL_WORKAREA_HISTOGRAM;                                     
INSERT INTO temp_size_table                                                     
SELECT 'STATS$STATSPACK_PARAMETER'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$STATSPACK_PARAMETER;                                        
INSERT INTO temp_size_table                                                     
SELECT 'STATS$STREAMS_APPLY_SUM'                                                
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$STREAMS_APPLY_SUM;                                          
INSERT INTO temp_size_table                                                     
SELECT 'STATS$STREAMS_CAPTURE'                                                  
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$STREAMS_CAPTURE;                                            
INSERT INTO temp_size_table                                                     
SELECT 'STATS$STREAMS_POOL_ADVICE'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$STREAMS_POOL_ADVICE;                                        
INSERT INTO temp_size_table                                                     
SELECT 'STATS$SYSSTAT'                                                          
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$SYSSTAT;                                                    
INSERT INTO temp_size_table                                                     
SELECT 'STATS$SYSTEM_EVENT'                                                     
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$SYSTEM_EVENT;                                               
INSERT INTO temp_size_table                                                     
SELECT 'STATS$SYS_TIME_MODEL'                                                   
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$SYS_TIME_MODEL;                                             
INSERT INTO temp_size_table                                                     
SELECT 'STATS$TEMPSTATXS'                                                       
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$TEMPSTATXS;                                                 
INSERT INTO temp_size_table                                                     
SELECT 'STATS$THREAD'                                                           
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$THREAD;                                                     
INSERT INTO temp_size_table                                                     
SELECT 'STATS$TIME_MODEL_STATNAME'                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$TIME_MODEL_STATNAME;                                        
INSERT INTO temp_size_table                                                     
SELECT 'STATS$UNDOSTAT'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$UNDOSTAT;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'STATS$WAITSTAT'                                                         
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STATS$WAITSTAT;                                                   
INSERT INTO temp_size_table                                                     
SELECT 'STAT_TEMP'                                                              
,COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks 
FROM PERFSTAT.STAT_TEMP;                                                        
