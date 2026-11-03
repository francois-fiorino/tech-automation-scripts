/*
===============================================================================
SCRIPT: new_fprc.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/NEW_FPRC.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Preservar variante TDMS que tenta inserir apenas valores ausentes.

FUNCIONAMENTO DETALHADO
  Três INSERT VALUES seguidos de WHERE NOT IN consultam OFFICE/TRUNK_GROUP/MEASUREMENT, COMMIT e handler ERROR_LOG.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas conforme limitações individuais.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  OFFICE, TRUNK_GROUP, MEASUREMENT, ERROR_LOG

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  INSERT VALUES WHERE é sintaxe inválida; transformação em INSERT SELECT e chaves adequadas exigem testes para não mudar regra por escritório/trunk/time. NOT IN tem efeitos NULL e concorrência não resolvida. Handler pode ocultar falhas e confirmar dados parcialmente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente inspeção; não compila sem corrigir INSERT VALUES WHERE e revisar chaves de negócio.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Proposta de procedimento, sem garantia de compilação Oracle.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos de criação, staging, autenticação, sessão
  ou código gerado descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Fonte integral preservada com três erros de sintaxe e limitações de deduplicação explícitos; não substituída por MERGE simplificado. 
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
	INSERT INTO office                                                              
		( office_nm, responsibility_cd )                                                
	VALUES
		( psOfficeNm, NULL )
	WHERE
		psOfficeNm NOT IN (select office_nm FROM office);
	INSERT INTO trunk_group                                                         
		( office_nm, trunk_group_nm, trunk_group_no )                                   
	VALUES 
		( psOfficeNm, psTrunkGroupNm, pnTrunkGroupNo )
	WHERE 
		psTrunkGroupNm not in (select trunk_group_nm from trunk_group);                          
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
	WHERE 
		TO_DATE(lsDateTime, 'MM/DD/YY HH24:MI') not in 
		(SELECT report_dttm 
		FROM measurement                                                                
		WHERE  office_nm = psOfficeNm                                                      
		AND trunk_group_nm = psTrunkGroupNm);                                                                            
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
