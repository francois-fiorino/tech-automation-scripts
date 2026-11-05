/*
===============================================================================
SCRIPT: keep_them.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/keep_them.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Executar KEEP para lista fixa de objetos históricos de componentes Oracle.

FUNCIONAMENTO DETALHADO
  Trinta e três chamadas DBMS_SHARED_POOL.KEEP com nomes/flags literais, incluindo SYS, XDB, MDSYS e WKSYS.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBMS_SHARED_POOL; objetos literais no corpo

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Lista fixa de objetos Oracle antigos, com tipos mistos e flags vazios; pode falhar parcialmente e pressionar shared pool. Duplicata de WRI$_ADV_HDM_T preservada como parte do exemplo histórico. Não é recomendação de pinning geral. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Revisão somente; não executar lista inteira em produção.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Objetos marcados para retenção ou erros individuais de objeto/flag/acesso.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  conforme descritos. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 038 (2026-11-04): Chamadas/ordem mantidas; não escolhidos flags de KEEP sem confrontar tipo/versão dos objetos. Casos de homologação: Confrontar DBA_OBJECTS/flags da API para cada um dos33 comandos; objeto ausente; impacto de memória; efeito parcial; nenhum KEEP foi executado. Comentários/créditos históricos preservados. Não aprovado para implantação.

AVISO DE RESPONSABILIDADE
AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de
qualquer utilização em produção. Sua execução é de responsabilidade do
profissional responsável pelo ambiente. Os mantenedores deste repositório não
se responsabilizam por indisponibilidade, perda de dados, alterações indevidas
ou outros impactos decorrentes de sua utilização.

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
execute dbms_shared_pool.keep('DBSNMP.BSLN','P')                                                                                    
execute dbms_shared_pool.keep('MDSYS.SDO_GEOR_DEF','P')                                                                             
execute dbms_shared_pool.keep('ORACLE_OCM.MGMT_CONFIG','P')                                                                         
execute dbms_shared_pool.keep('PERFSTAT.DO_EXPLAIN','P')                                                                            
execute dbms_shared_pool.keep('SYS.WRI$_ADV_HDM_T','')                                                                              
execute dbms_shared_pool.keep('SYS.WRI$_ADV_ABSTRACT_T','')                                                                         
execute dbms_shared_pool.keep('SYS.DICTIONARY_OBJ_TYPE','P')                                                                        
execute dbms_shared_pool.keep('SYS.DICTIONARY_OBJ_OWNER','P')                                                                       
execute dbms_shared_pool.keep('SYS.DICTIONARY_OBJ_NAME','P')                                                                        
execute dbms_shared_pool.keep('SYS.SYSEVENT','P')                                                                                   
execute dbms_shared_pool.keep('SYS.LOGIN_USER','P')                                                                                 
execute dbms_shared_pool.keep('SYS.IS_VPD_ENABLED','P')                                                                             
execute dbms_shared_pool.keep('SYS.IS_DROP_COLUMN','P')                                                                             
execute dbms_shared_pool.keep('SYS.SQL_TXT','P')                                                                                    
execute dbms_shared_pool.keep('SYS.DBMS_ROWID','P')                                                                                 
execute dbms_shared_pool.keep('SYS.PRVT_ADVISOR','P')                                                                               
execute dbms_shared_pool.keep('SYS.DBMS_ADVISOR','P')                                                                               
execute dbms_shared_pool.keep('SYS.DBMS_SPACE_ADMIN','P')                                                                           
execute dbms_shared_pool.keep('SYS.DBMS_AUTO_TASK','P')                                                                             
execute dbms_shared_pool.keep('SYS.DBMS_SCHEDULER','P')                                                                             
execute dbms_shared_pool.keep('SYS.AW_DROP_PROC','P')                                                                               
execute dbms_shared_pool.keep('SYS.DO_EXPLAIN','P')                                                                                 
execute dbms_shared_pool.keep('SYS.AW_TRUNC_PROC','P')                                                                              
execute dbms_shared_pool.keep('SYS.WRI$_ADV_HDM_T','')                                                                              
execute dbms_shared_pool.keep('SYS.XMLTYPE','')                                                                                     
execute dbms_shared_pool.keep('SYS.XMLSEQ_IMP_T','')                                                                                
execute dbms_shared_pool.keep('SYS.WRI$_ADV_OBJSPACE_TREND_T','')                                                                   
execute dbms_shared_pool.keep('WKSYS.WK$USER','P')                                                                                  
execute dbms_shared_pool.keep('WKSYS.WK$USERID','P')                                                                                
execute dbms_shared_pool.keep('WKSYS.WK$IS_ADMIN','P')                                                                              
execute dbms_shared_pool.keep('WKSYS.WK_JOB','P')                                                                                   
execute dbms_shared_pool.keep('WKSYS.WK$UPD_INST','P')                                                                              
execute dbms_shared_pool.keep('XDB.DBMS_CSX_ADMIN','P')                                                                             
