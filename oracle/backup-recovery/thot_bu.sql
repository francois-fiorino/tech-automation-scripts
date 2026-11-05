/*
===============================================================================
SCRIPT: thot_bu.sql
CATEGORIA: Oracle / backup-recovery
ORIGEM: Oracle Script Collection 2015 / misc_scripts/thot_bu.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Preservar backup online OpenVMS gerado para instância ORCNETP1 histórica.

FUNCIONAMENTO DETALHADO
  BEGIN/END BACKUP de tablespaces fixos, HOST BACKUP para fita MUA0, cópia de redo, switch/archive, archives /DELETE e controlfile.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas/SO conforme limitações; ler todos
  os nomes e caminhos antes de qualquer teste em ambiente descartável.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  Tablespaces/arquivos ORCNETP1 literais, OpenVMS BACKUP, fita MUA0, comandos SQL administrativos

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Paths Unix misturados a sintaxe VMS precisam validação; backup mode exige ARCHIVELOG/recovery testado. RAWDAT01 é copiado após END BACKUP de RAW_DATA, fora da janela de proteção; /DELETE pode apagar archives indispensáveis a recovery. Control file syntax/path e cópia redo online não garantem consistência.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Análise somente; não executar em qualquer ambiente de produção.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Cópias/arquivamentos e possíveis remoções de arquivos de archive quando executado.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cópia/restauração, DDL, estatísticas ou DML massivo
  conforme acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Exemplo completo com todos os paths/ordem/avisos preservados; falha de ordenação não corrigida sem validar plano integral de backup. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 044 — 04/11/2026
  Correções e melhorias: EXIT incondicional antes do backup OpenVMS gerado; ordem e todos caminhos históricos preservados.
  Limitações e pendências: RAWDAT01 fora da janela RAW_DATA; mistura pathsUnix/sintaxeVMS, BACKUP/IGNORE, cópiaredo e /DELETE archives podem comprometer recuperação. Sem inventar fita/diretório/plano homologado.
  Homologação necessária: Inspecionar BEGIN/END e cada cópia; testar restauração em ambiente isolado somente após redesenhar plano. Nenhum HOST ou archive removido.
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
PROMPT BLOQUEADO: operacao legada critica; somente revisao.
EXIT FAILURE ROLLBACK


/*  */
REM Online Backup Script for ORCNETP1 instance                                                                                      
REM Script uses OpenVMS format backup commands                                                                                      
REM created on 24-jun-2011 14:19 by user SYSTEM                                                                                     
REM developed for TVA by Mike Ault - DMR Consulting Group 23-Jun-2011                                                               
REM Script expects to be fed backup directory location on execution.                                                                
REM Script should be re-run anytime physical structure of database altered.                                                         
REM                                                                                                                                 
REM                                                                                                                                 
REM Backup for tablespace SYSTEM                                                                                                    
REM                                                                                                                                 
alter tablespace SYSTEM begin backup;                                                                                               
host backup/ignore=(noback, interlock,label)/log /oracle00/ORCNETP1/data/system01.dbf -                                             
 mua0:ora_SYSTEM1.bck/sav                                                                                                           
                                                                                                                                    
alter tablespace SYSTEM end backup;                                                                                                 
                                                                                                                                    
REM                                                                                                                                 
REM Backup for tablespace RBS                                                                                                       
REM                                                                                                                                 
alter tablespace RBS begin backup;                                                                                                  
host backup/ignore=(noback, interlock,label)/log /oracle04/ORCNETP1/data/rbs02.dbf -                                                
 mua0:ora_RBS24.bck/sav                                                                                                             
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle04/ORCNETP1/data/rbs01.dbf -                                                
 mua0:ora_RBS2.bck/sav                                                                                                              
                                                                                                                                    
alter tablespace RBS end backup;                                                                                                    
                                                                                                                                    
REM                                                                                                                                 
REM Backup for tablespace TEMP                                                                                                      
REM                                                                                                                                 
alter tablespace TEMP begin backup;                                                                                                 
host backup/ignore=(noback, interlock,label)/log /oracle01/ORCNETP1/data/temp06.dbf -                                               
 mua0:ora_TEMP37.bck/sav                                                                                                            
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle01/ORCNETP1/data/temp05.dbf -                                               
 mua0:ora_TEMP36.bck/sav                                                                                                            
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle01/ORCNETP1/data/temp04.dbf -                                               
 mua0:ora_TEMP35.bck/sav                                                                                                            
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle01/ORCNETP1/data/temp03.dbf -                                               
 mua0:ora_TEMP34.bck/sav                                                                                                            
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle01/ORCNETP1/data/temp02.dbf -                                               
 mua0:ora_TEMP33.bck/sav                                                                                                            
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle01/ORCNETP1/data/temp01.dbf -                                               
 mua0:ora_TEMP3.bck/sav                                                                                                             
                                                                                                                                    
alter tablespace TEMP end backup;                                                                                                   
                                                                                                                                    
REM                                                                                                                                 
REM Backup for tablespace TOOLS                                                                                                     
REM                                                                                                                                 
alter tablespace TOOLS begin backup;                                                                                                
host backup/ignore=(noback, interlock,label)/log /oracle02/ORCNETP1/data/tools01.dbf -                                              
 mua0:ora_TOOLS4.bck/sav                                                                                                            
                                                                                                                                    
alter tablespace TOOLS end backup;                                                                                                  
                                                                                                                                    
REM                                                                                                                                 
REM Backup for tablespace USERS                                                                                                     
REM                                                                                                                                 
alter tablespace USERS begin backup;                                                                                                
host backup/ignore=(noback, interlock,label)/log /oracle03/ORCNETP1/data/user01.dbf -                                               
 mua0:ora_USERS5.bck/sav                                                                                                            
                                                                                                                                    
alter tablespace USERS end backup;                                                                                                  
                                                                                                                                    
REM                                                                                                                                 
REM Backup for tablespace SCOPUS_DATA                                                                                               
REM                                                                                                                                 
alter tablespace SCOPUS_DATA begin backup;                                                                                          
host backup/ignore=(noback, interlock,label)/log /oracle05/ORCNETP1/data/SCPDAT14_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_DATA42.bck/sav                                                                                                     
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle05/ORCNETP1/data/SCPDAT13_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_DATA18.bck/sav                                                                                                     
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle05/ORCNETP1/data/SCPDAT12_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_DATA17.bck/sav                                                                                                     
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle05/ORCNETP1/data/SCPDAT11_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_DATA16.bck/sav                                                                                                     
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle05/ORCNETP1/data/SCPDAT10_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_DATA15.bck/sav                                                                                                     
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle05/ORCNETP1/data/SCPDAT09_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_DATA14.bck/sav                                                                                                     
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle05/ORCNETP1/data/SCPDAT08_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_DATA13.bck/sav                                                                                                     
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle05/ORCNETP1/data/SCPDAT07_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_DATA12.bck/sav                                                                                                     
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle05/ORCNETP1/data/SCPDAT06_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_DATA11.bck/sav                                                                                                     
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle05/ORCNETP1/data/SCPDAT05_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_DATA10.bck/sav                                                                                                     
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle05/ORCNETP1/data/SCPDAT04_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_DATA9.bck/sav                                                                                                      
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle05/ORCNETP1/data/SCPDAT03_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_DATA8.bck/sav                                                                                                      
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle05/ORCNETP1/data/SCPDAT02_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_DATA7.bck/sav                                                                                                      
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle05/ORCNETP1/data/SCPDAT01_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_DATA6.bck/sav                                                                                                      
                                                                                                                                    
alter tablespace SCOPUS_DATA end backup;                                                                                            
                                                                                                                                    
REM                                                                                                                                 
REM Backup for tablespace SCOPUS_INDEX                                                                                              
REM                                                                                                                                 
alter tablespace SCOPUS_INDEX begin backup;                                                                                         
host backup/ignore=(noback, interlock,label)/log /oracle06/ORCNETP1/data/SCPIND11_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_INDEX44.bck/sav                                                                                                    
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle06/ORCNETP1/data/SCPIND10_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_INDEX43.bck/sav                                                                                                    
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle06/ORCNETP1/data/SCPIND09_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_INDEX41.bck/sav                                                                                                    
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle06/ORCNETP1/data/SCPIND08_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_INDEX40.bck/sav                                                                                                    
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle06/ORCNETP1/data/SCPIND07_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_INDEX39.bck/sav                                                                                                    
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle06/ORCNETP1/data/SCPIND06_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_INDEX38.bck/sav                                                                                                    
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle06/ORCNETP1/data/SCPIND05_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_INDEX23.bck/sav                                                                                                    
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle06/ORCNETP1/data/SCPIND04_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_INDEX22.bck/sav                                                                                                    
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle06/ORCNETP1/data/SCPIND03_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_INDEX21.bck/sav                                                                                                    
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle06/ORCNETP1/data/SCPIND02_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_INDEX20.bck/sav                                                                                                    
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle06/ORCNETP1/data/SCPIND01_ORCNETP1.dbf -                                    
 mua0:ora_SCOPUS_INDEX19.bck/sav                                                                                                    
                                                                                                                                    
alter tablespace SCOPUS_INDEX end backup;                                                                                           
                                                                                                                                    
REM                                                                                                                                 
REM Backup for tablespace RAW_DATA                                                                                                  
REM                                                                                                                                 
alter tablespace RAW_DATA begin backup;                                                                                             
host backup/ignore=(noback, interlock,label)/log /oracle07/ORCNETP1/data/RAWDAT07_ORCNETP1.dbf -                                    
 mua0:ora_RAW_DATA32.bck/sav                                                                                                        
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle07/ORCNETP1/data/RAWDAT06_ORCNETP1.dbf -                                    
 mua0:ora_RAW_DATA31.bck/sav                                                                                                        
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle07/ORCNETP1/data/RAWDAT05_ORCNETP1.dbf -                                    
 mua0:ora_RAW_DATA30.bck/sav                                                                                                        
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle07/ORCNETP1/data/RAWDAT04_ORCNETP1.dbf -                                    
 mua0:ora_RAW_DATA29.bck/sav                                                                                                        
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle07/ORCNETP1/data/RAWDAT03_ORCNETP1.dbf -                                    
 mua0:ora_RAW_DATA28.bck/sav                                                                                                        
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle07/ORCNETP1/data/RAWDAT02_ORCNETP1.dbf -                                    
 mua0:ora_RAW_DATA27.bck/sav                                                                                                        
                                                                                                                                    
alter tablespace RAW_DATA end backup;                                                                                               
host backup/ignore=(noback, interlock,label)/log /oracle07/ORCNETP1/data/RAWDAT01_ORCNETP1.dbf -                                    
 mua0:ora_RAW_DATA26.bck/sav                                                                                                        
                                                                                                                                    
                                                                                                                                    
REM                                                                                                                                 
REM Backup for tablespace SNAPSHOT_LOGS                                                                                             
REM                                                                                                                                 
alter tablespace SNAPSHOT_LOGS begin backup;                                                                                        
host backup/ignore=(noback, interlock,label)/log /oracle06/ORCNETP1/data/SNPSHT02_ORCNETP1.dbf -                                    
 mua0:ora_SNAPSHOT_LOGS46.bck/sav                                                                                                   
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle06/ORCNETP1/data/SNPLOG01_ORCNETP1.dbf -                                    
 mua0:ora_SNAPSHOT_LOGS45.bck/sav                                                                                                   
                                                                                                                                    
alter tablespace SNAPSHOT_LOGS end backup;                                                                                          
                                                                                                                                    
REM                                                                                                                                 
REM Backup for tablespace CNET_ENINFO_INDX                                                                                          
REM                                                                                                                                 
alter tablespace CNET_ENINFO_INDX begin backup;                                                                                     
host backup/ignore=(noback, interlock,label)/log /oracle06/ORCNETP1/data/CNET_ENINFO_INDX03.dbf -                                   
 mua0:ora_CNET_ENINFO_INDX49.bck/sav                                                                                                
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle06/ORCNETP1/data/CNET_ENINFO_INDX02.dbf -                                   
 mua0:ora_CNET_ENINFO_INDX48.bck/sav                                                                                                
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle06/ORCNETP1/data/CNET_ENINFO_INDX01.dbf -                                   
 mua0:ora_CNET_ENINFO_INDX47.bck/sav                                                                                                
                                                                                                                                    
alter tablespace CNET_ENINFO_INDX end backup;                                                                                       
                                                                                                                                    
REM                                                                                                                                 
REM Backup for tablespace CNET_ENINFO                                                                                               
REM                                                                                                                                 
alter tablespace CNET_ENINFO begin backup;                                                                                          
host backup/ignore=(noback, interlock,label)/log /oracle05/ORCNETP1/data/CNET_ENINFO_DATA04.dbf -                                   
 mua0:ora_CNET_ENINFO53.bck/sav                                                                                                     
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle05/ORCNETP1/data/CNET_ENINFO_DATA03.dbf -                                   
 mua0:ora_CNET_ENINFO52.bck/sav                                                                                                     
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle05/ORCNETP1/data/CNET_ENINFO_DATA02.dbf -                                   
 mua0:ora_CNET_ENINFO51.bck/sav                                                                                                     
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle05/ORCNETP1/data/CNET_ENINFO_DATA01.dbf -                                   
 mua0:ora_CNET_ENINFO50.bck/sav                                                                                                     
                                                                                                                                    
alter tablespace CNET_ENINFO end backup;                                                                                            
                                                                                                                                    
REM                                                                                                                                 
REM Backup for redo logs                                                                                                            
REM Normally you will not recover redo logs                                                                                         
REM                                                                                                                                 
host backup/ignore=(noback, interlock,label)/log /oracle00/ORCNETP1/redo/log1a.dbf -                                                
 mua0:ora_redo1a.bck/sav                                                                                                            
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle01/ORCNETP1/redo/log1b.dbf -                                                
 mua0:ora_redo1b.bck/sav                                                                                                            
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle02/ORCNETP1/redo/log2b.dbf -                                                
 mua0:ora_redo2b.bck/sav                                                                                                            
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle03/ORCNETP1/redo/log2a.dbf -                                                
 mua0:ora_redo2a.bck/sav                                                                                                            
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle04/ORCNETP1/redo/log3b.dbf -                                                
 mua0:ora_redo3b.bck/sav                                                                                                            
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle05/ORCNETP1/redo/log3a.dbf -                                                
 mua0:ora_redo3a.bck/sav                                                                                                            
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle06/ORCNETP1/redo/log4a.dbf -                                                
 mua0:ora_redo4a.bck/sav                                                                                                            
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle07/ORCNETP1/redo/log4b.dbf -                                                
 mua0:ora_redo4b.bck/sav                                                                                                            
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle08/ORCNETP1/redo/log5a.dbf -                                                
 mua0:ora_redo5a.bck/sav                                                                                                            
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle09/ORCNETP1/redo/log5b.dbf -                                                
 mua0:ora_redo5b.bck/sav                                                                                                            
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle10/ORCNETP1/redo/log6a.dbf -                                                
 mua0:ora_redo6a.bck/sav                                                                                                            
                                                                                                                                    
host backup/ignore=(noback, interlock,label)/log /oracle11/ORCNETP1/redo/log6b.dbf -                                                
 mua0:ora_redo6b.bck/sav                                                                                                            
                                                                                                                                    
REM                                                                                                                                 
REM Backup for archive logs                                                                                                         
REM                                                                                                                                 
alter system switch logfile;                                                                                                        
archive log all;                                                                                                                    
host backup/ignore=(noback, interlock,label)/log */DELETE -                                                                         
 mua0:ora_archive.bck/sav                                                                                                           
                                                                                                                                    
alter database backup control file to ora_backup:[backups.lims]ora_conbackup.bac;                                                   
host backup/ignore=(noback, interlock,label)/log ora_backup:[backups.lims]ora_conbackup.bac -                                       
 mua0:ora_control.bck/sav                                                                                                           
                                                                                                                                    
