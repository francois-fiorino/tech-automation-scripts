/*
===============================================================================
SCRIPT: trig_rct.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/TRIG_RCT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar recriação de triggers fora de SYS/SYSTEM usando staging.

FUNCIONAMENTO DETALHADO
  CREATE TRIG_TEMP em TOOLS, cursores TRIGGERS/TRIGGER_COLS, INSERT/COMMIT, spool de cabeçalhos/body LONG e DROP staging.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS de criação/execução/consulta e permissões administrativas
  conforme limitações; não instalar variantes sobre objetos de trabalho.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TRIGGERS, DBA_TRIGGER_COLS, DUAL, TRIG_TEMP, tablespace TOOLS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DDL confirma transações e nomes/buffers 30/400/2000/LONG4000 limitam triggers atuais. Não cobre compound/database/schema/instead-of genericamente, estado ENABLE/DISABLE ou toda sintaxe WHEN. Saída começa com / e exige revisão do buffer ao executar.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema descartável; não executar saída contra aplicação real.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Arquivo CRT_TRGS.SQL e staging temporariamente persistente.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: DDL/DML, staging, autenticação ou efeitos da saída
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Separador final / acrescentado à saída para terminar último trigger; algoritmo/lista/créditos preservados. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 039 — 04/11/2026
  Correções e melhorias: Falhas SQL interrompem antes de reutilizar TRIG_TEMP.
  Limitações e pendências: LONG 4000 pode truncar body, prefixo ON cabe em variável de owner limitada, WHEN sem parênteses pode ser inválido. Separador inicial / pode repetir buffer; tipos modernos não cobertos. Não usar saída como backup.
  Homologação necessária: Staging existente, body maior que 4000, WHEN, multi-event, UPDATE OF e estado DISABLED; inspecionar cada DDL sem executá-lo automaticamente.
  Parâmetros/execução: manter contrato descrito acima e no corpo histórico.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação realizada: leitura integral e comparação estática; sem compilação
  ou execução Oracle, sem execução de comandos administrativos.

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
REM  trig_rct.sql
REM
REM    FUNCTION: SCRIPT FOR RE-CREATING DATABASE TRIGGERS 
REM              This script can be run by anyone with access to dba_ triggers
REM              This script is intended to run with Oracle7.
REM              Running this script will in turn create a script to 
REM              build all the triggers in the database.  This created 
REM              script is called 'create_triggers.sql'.
REM              Only preliminary testing of this script was performed.  
REM              Be sure to test it completely before relying on it.  
set verify off feedback off termout off echo off pagesize 0 long 4000
set termout on arraysize 1
select 'Creating trigger build script...' from dual;
rem set termout off
set echo on
whenever sqlerror exit failure rollback
create table trig_temp (owner varchar2(30),
			trigger_name varchar2(30),
			trigger_type varchar2(16),
			triggering_event varchar2(26),
			table_owner varchar2(30),
			table_name varchar2(30),
			referencing_names varchar2(87),
			when_clause varchar2(2000),
			trigger_body long,
			trigger_columns varchar2(400)) 
storage (initial 100k next 100k)
tablespace tools;
 
DECLARE
   CURSOR trig_cursor IS select owner,
				trigger_name, 
				trigger_type , 
				triggering_event, 
				'on '||table_owner,
				table_name,
				referencing_names,
				'when '||when_clause,
				trigger_body
			from dba_triggers 
			where owner not in ('SYS','SYSTEM')
			order by owner; 
	cursor trig_col ( owner varchar2, name varchar2 ) is 
			select trigger_owner,
				trigger_name,
				column_name
			from dba_trigger_cols 
			where trigger_owner = owner and
				trigger_name = name;

	trig_owner      dba_triggers.owner%TYPE;
	trig_name       dba_triggers.trigger_name%TYPE;
	trig_type       dba_triggers.trigger_type%TYPE;
	trig_event      dba_triggers.triggering_event%TYPE;
	trig_towner     dba_triggers.table_owner%TYPE;
	trig_tname      dba_triggers.table_name%TYPE;
	trig_rnames     dba_triggers.referencing_names%TYPE;
	trig_wclause    dba_triggers.when_clause%TYPE;
	trig_body       dba_triggers.trigger_body%TYPE;   
	trig_col_own    dba_trigger_cols.trigger_owner%TYPE;
	trig_col_nam    dba_trigger_cols.trigger_name%TYPE;
	trig_column     dba_trigger_cols.column_name%TYPE;   
	all_columns     varchar2(400);
	counter         integer:=0;

BEGIN
   OPEN trig_cursor;
   LOOP
      FETCH trig_cursor INTO    trig_owner,
				trig_name,
				trig_type,
				trig_event,
				trig_towner,
				trig_tname,
				trig_rnames,
				trig_wclause,
				trig_body;
      EXIT WHEN trig_cursor%NOTFOUND;
	all_columns :='';       
	counter := 0;
	open trig_col(trig_owner,trig_name);
	loop
		fetch trig_col into
				     	trig_col_own,
					trig_col_nam,
					trig_column;
		exit when trig_col%NOTFOUND; 
			counter := counter+1;
			if counter = 1 then
			all_columns := ' of '||all_columns||trig_column;
			else
			all_columns := all_columns||', '||trig_column;
		end if;
	end loop;
	close trig_col;
	if trig_rnames = 'REFERENCING NEW AS NEW OLD AS OLD' then
		trig_rnames := '';
	end if;
	if trig_wclause = 'when ' then
		trig_wclause := '';
	end if;
	insert into trig_temp values (trig_owner,
				trig_name,
				trig_type,
				trig_event,
				trig_towner,
				trig_tname,
				trig_rnames,
				trig_wclause,
				trig_body,
				all_columns);
   END LOOP;
   CLOSE trig_cursor;
   commit;
END;
/
define cr='chr(10)'
spool rep_out\crt_trgs.sql
set heading off
set recsep off pages 0

select '/'||&&cr||&&cr||'create or replace trigger '||owner||'.'||trigger_name||&&cr||
decode(trigger_type,'BEFORE EACH ROW','BEFORE ',
		'AFTER EACH ROW','AFTER ',trigger_type)||triggering_event||&&cr||
trigger_columns||&&cr||
table_owner||'.'||table_name||' '||referencing_names||&&cr||
decode(trigger_type,'BEFORE EACH ROW','FOR EACH ROW',
		'AFTER EACH ROW','FOR EACH ROW','')||&&cr||
when_clause,
trigger_body
from trig_temp 
order by owner;
select '/' from dual;
spool off
drop table trig_temp;   
set verify on feedback on termout on echo on pagesize 22
set heading on recsep on
clear columns
