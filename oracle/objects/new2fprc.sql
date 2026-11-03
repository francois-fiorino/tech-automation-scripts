/*
===============================================================================
SCRIPT: new2fprc.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/NEW2FPRC.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar variante TDMS de carga de medições de telecom com tratamento de duplicatas.

FUNCIONAMENTO DETALHADO
  INSERT OFFICE/TRUNK_GROUP/MEASUREMENT em blocos separados ignora DUP_VAL_ON_INDEX, COMMIT; handler grava ERROR_LOG.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas conforme limitações individuais.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  OFFICE, TRUNK_GROUP, MEASUREMENT, ERROR_LOG

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE/DML diretos. CHAR(14) acomoda exatamente MM/DD/YY + espaço + HH24:MI; formatos maiores falham e a entrada precisa validar. Duplicatas são descartadas sem auditoria e handler não relança nem confirma error_log. Alternativa incompatível com NEW_FPRC homônimo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema de aplicação de laboratório com contratos/chaves equivalentes.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Procedimento TDMS criado; chamadas inserem/confirmam medições e podem logar erros.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos de criação, staging, autenticação, sessão
  ou código gerado descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código completo preservado; não inventadas regras de deduplicação, cardinalidade ou commit. 
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
create or replace procedure tdms(                                               
	psSwitchTypeNm	IN	VARCHAR2,                                             
	psOfficeNm 		IN	VARCHAR2,                                             
	psDate 			IN	VARCHAR2,                                             
	psTime 			IN	VARCHAR2,                                             
	psTrunkGroupNm 	IN         VARCHAR2,                                             
	psRoutingCd 		IN	VARCHAR2,                                             
	pnIncomingPegQty 	IN	NUMBER,                                               
	pnOutgoingPegQty 	IN 	NUMBER,                                               
	pnOverflowPegQty 	IN 	NUMBER,                                               
	pnOverflowPct 		IN	NUMBER,                                               
	pnCircuitsInServiceQty 	IN	NUMBER,                                               
	pnTrunkGroupNo 	IN	NUMBER,                                               
	pnCallDurationSecQty 	IN	NUMBER,                                               
	pnUsage		IN	NUMBER,                                               
	pnBusyCircuitQty	IN	NUMBER,                                               
	pnRecordNo		IN	NUMBER)                                               
AS                                                                              
lsDateTime      		CHAR(14);                                                       
lsCurrentRecord 	VARCHAR2(1700);                                                 
lnSqlErrorCd    		NUMBER;                                                         
lsSqlErrorMsg   		VARCHAR2(500);                                                  
lnRecordCnt     		NUMBER;                                                         

BEGIN                                
	lsDateTime := psDate || ' '  || psTime;
BEGIN
	INSERT INTO office                                                              
		( office_nm, responsibility_cd )                                                
	VALUES
		( psOfficeNm, NULL )
	;
EXCEPTION             
	WHEN dup_val_on_index THEN
	null;                                                          
END;
BEGIN
	INSERT INTO trunk_group                                                         
		( office_nm, trunk_group_nm, trunk_group_no )                                   
	VALUES 
		( psOfficeNm, psTrunkGroupNm, pnTrunkGroupNo )
	;                          
EXCEPTION             
	WHEN dup_val_on_index THEN
	null;                                                          
END;
BEGIN
	INSERT INTO    measurement                                                      
		(office_nm, trunk_group_nm, report_dttm, routing_cd, incoming_peg_qty,          
		outgoing_peg_qty, overflow_peg_qty, overflow_pct,                               
		circuits_in_service_qty, call_duration_sec_qty, usage,                          
		busy_circuit_qty, switch_type_nm, record_no)                                    
	VALUES
		(psOfficeNm, psTrunkGroupNm, TO_DATE(lsDateTime, 'MM/DD/YY HH24:MI'),     
		NVL(psRoutingCd, NULL), NVL(pnIncomingPegQty, NULL),                            
		NVL(pnOutgoingPegQty, NULL), NVL(pnOverflowPegQty, NULL),                       
		NVL(pnOverflowPct, NULL), NVL(pnCircuitsInServiceQty, NULL),                    
		NVL(pnCallDurationSecQty, NULL), NVL(pnUsage, NULL),                            
		NVL(pnBusyCircuitQty, NULL), NVL(psSwitchTypeNm, NULL), pnRecordNo)
	;
EXCEPTION             
	WHEN dup_val_on_index THEN
	/*BEGIN
	lsCurrentRecord := 'TDMS=' || psSwitchTypeNm || ' ENTITY=' || psOfficeNm ||
 	' DATE=' || psDate || ' TIME=' || psTime || ' GROUP=' || psTrunkGroupNm || ' RC=' || 
	psRoutingCd ||' IPC=' || pnIncomingPegQty || ' OPC=' || pnOutgoingPegQty || 
	' OFL=' || pnOverflowPegQty || ' %OFL=' ||pnOverflowPct || ' NCI=' ||
	pnCircuitsInServiceQty || ' TRK_GRP_NO=' || pnTrunkGroupNo || ' HT=' ||
	pnCallDurationSecQty || ' USG=' || pnUsage || ' NMB=' || pnBusyCircuitQty;
	lnSqlErrorCd := SQLCODE;                                                        
	lsSqlErrorMsg := SQLERRM(lnSqlErrorCd);                                         
	INSERT INTO error_log                                                           
		(error_dttm, error_cd, error_message_txt, line_item_txt)                        
	VALUES 
		(sysdate, lnSqlErrorCd, lsSqlErrorMsg, lsCurrentRecord);
	END;*/
null;                                                   
END;                                                                            
COMMIT;
EXCEPTION                                                                         
	WHEN others THEN              
	lsCurrentRecord := 'TDMS=' || psSwitchTypeNm || ' ENTITY=' || psOfficeNm ||
 	' DATE=' || psDate || ' TIME=' || psTime || ' GROUP=' || psTrunkGroupNm || ' RC=' || 
	psRoutingCd ||' IPC=' || pnIncomingPegQty || ' OPC=' || pnOutgoingPegQty || 
	' OFL=' || pnOverflowPegQty || ' %OFL=' ||pnOverflowPct || ' NCI=' ||
	pnCircuitsInServiceQty || ' TRK_GRP_NO=' || pnTrunkGroupNo || ' HT=' ||
	pnCallDurationSecQty || ' USG=' || pnUsage || ' NMB=' || pnBusyCircuitQty;
	lnSqlErrorCd := SQLCODE;                                                        
	lsSqlErrorMsg := SQLERRM(lnSqlErrorCd);                                         
	INSERT INTO error_log                                                           
		(error_dttm, error_cd, error_message_txt, line_item_txt)                        
	VALUES 
		(sysdate, lnSqlErrorCd, lsSqlErrorMsg, lsCurrentRecord);                 
END;                                                                            
/                                                                               
