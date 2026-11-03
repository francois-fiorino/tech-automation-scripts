/*
===============================================================================
SCRIPT: seq_rct.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/SEQ_RCT.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar DROP/CREATE de sequências com storage de valores em staging.

FUNCIONAMENTO DETALHADO
  CREATE SEQ_TEMP, cursor DBA_SEQUENCES, compõe atributos/cache/ordem/increment/min/max/start, spool e DROP staging.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e privilégios administrativos conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_SEQUENCES, V$DATABASE, SEQ_TEMP

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DDL confirma transações e saída pode causar perda de sequência/privilégios. LAST_NUMBER com cache não é próximo exato; uso em ambiente vivo pode gerar repetição/gaps. Buffers 255 e nomes sem quoting limitam fidelidade.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema descartável; nunca aplicar saída sobre sequência ativa sem projeto de migração.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Arquivo CRT_SEQS.SQL com DROP/CREATE sequências.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: pode gerar ou executar DDL/DML, expor hashes/segredos
  do banco consultado ou alterar sessão conforme descrito acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  $$cr corrigido para &&cr; FETCH cycle/order alinhado ao cursor e spool usa variável DB com separador correto. Fluxo completo preservado. 
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
REM
REM    FUNCTION: SCRIPT FOR RE-CREATING DATABASE SEQUENCES
REM
REM              This script must be run by 'SYS'.  
REM 
REM
REM              Running this script will in turn create a script to 
REM              build all the sequences in the database.  This created 
REm              script is called 'create_sequences.sql'.
REM 
REM              This script will start the sequence (start with value) 
REM              at the last value of the sequence at the time the 
REM              script is run (LAST_NUMBER).
REM
REM
REM Only preliminary testing of this script was performed.  Be sure to test 
REM it completely before relying on it.  
REM
 
set verify off
set feedback off
rem set termout off
set echo off
set pagesize 0
define cr='chr(10)'
 
set termout on
select 'Creating sequence build script...' from dual;
rem set termout off
 
create table seq_temp (grantor_owner varchar2(30),
text VARCHAR2(255))
/ 
DECLARE
   CURSOR seq_cursor IS select   sequence_owner,
				  sequence_name, 
				  min_value, 
				  max_value, 
				 increment_by,
				decode(cycle_flag,'Y','CYCLE','NOCYCLE'),
				decode(order_flag,'Y','ORDER','NOORDER'),
	decode(to_char(cache_size),'0','NOCACHE','CACHE '||to_char(cache_size)),
				last_number
			  from dba_sequences 
			where sequence_owner not in ('SYS','SYSTEM')
			 order by sequence_owner; 
	seq_owner       dba_sequences.sequence_owner%TYPE;
	seq_name        dba_sequences.sequence_name%TYPE;
	seq_min         dba_sequences.min_value%TYPE;
	seq_max         dba_sequences.max_value%TYPE;
	seq_inc         dba_sequences.increment_by%TYPE;
	seq_order       VARCHAR2(7);
	seq_cycle       VARCHAR2(7);
	seq_cache       VARCHAR2(15);
	seq_lnum        dba_sequences.last_number%TYPE;   
	seq_string     VARCHAR2(255);
   procedure write_out(p_string VARCHAR2) is
   begin
      insert into seq_temp (grantor_owner,text) 
			values (seq_owner,p_string);
   end;
 
BEGIN
   OPEN seq_cursor;
   LOOP
      FETCH seq_cursor INTO     seq_owner,
				seq_name,
				seq_min,
				seq_max,
				seq_inc,
				seq_cycle,
				seq_order,
				seq_cache,
				seq_lnum;
      EXIT WHEN seq_cursor%NOTFOUND;
	seq_string:=('DROP SEQUENCE '||seq_owner||'.'||seq_name||';'||&&cr||
			'CREATE SEQUENCE '||seq_owner||'.'||seq_name||&&cr||
				'INCREMENT BY '||seq_inc||&&cr||
				'START WITH '||seq_lnum||&&cr||
				'MAXVALUE '||seq_max||&&cr||
				'MINVALUE '||seq_min||&&cr||
				seq_cycle||&&cr|| 
				seq_cache||&&cr||
				seq_order||';');   
write_out(seq_string);
   END LOOP;
   CLOSE seq_cursor;
END;
/
 col dbname new_value db noprint
select name dbname from v$database;
spool &&db._crt_seqs.sql
break on downer skip 1
col text format a60 word_wrap
col downer noprint 
select    grantor_owner downer,text
from     seq_temp 
order by downer 
/
spool off
 
drop table seq_temp;
 set termout on verify on feedback on
clear columns
clear breaks
prompt Finished build
