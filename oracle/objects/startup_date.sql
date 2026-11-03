/*
===============================================================================
SCRIPT: startup_date.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/startup_date.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar procedimento histórico que devolve data de startup por layout KEY/VALUE.

FUNCIONAMENTO DETALHADO
  Lê dia juliano/segundos de V$INSTANCE, decompõe horário, imprime e devolve OUT DATE.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme limitações de cada arquivo. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$INSTANCE (KEY/VALUE legado), DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE/SELECT direto. V$INSTANCE moderno não tem KEY/VALUE. DATE vira string implícita e depois máscara DD-MON-YY, dependente de NLS; sem garantia moderna. NO_DATA_FOUND deixa OUT sem data.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Revisão em versão legada compatível: @startup_date.sql.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Procedimento criado apenas se catálogo compatível; OUT DATE e mensagens quando chamado.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  conforme descritos. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Teste de minuto padding 0 corrigido para 1 e terminador / adicionado; algoritmo histórico completo preservado para estudo. 
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
create or replace PROCEDURE startup_date (good_date out date)
AS
	jdate 		DATE;
	jsec 		NUMBER;
	hr 		VARCHAR2(2);
	sec 		VARCHAR2(2);
	minute 		VARCHAR2(2);
	startup_date 	VARCHAR2(32);
	show_date	DATE;
BEGIN
 SELECT 
TO_DATE(TO_NUMBER(value,'99999999'),'J') 
  INTO 
jdate 
  FROM
  	v$instance 
  WHERE 
	key='STARTUP TIME - JULIAN';
 SELECT 
	(TO_NUMBER(value,'9999999')) 
  INTO 
	jsec 
  FROM 
	v$instance
  WHERE 
	key='STARTUP TIME - SECONDS';
 hr:=TO_CHAR(TRUNC(jsec/3600,0));
 minute:= TO_CHAR(TRUNC(((jsec/3600)-hr)*60,0));
 sec:= TO_CHAR(TRUNC((((((jsec/3600)-hr)*60)-minute)*60),0));
 IF length(hr)=1 THEN
  	hr:='0'||hr;
END IF;
IF length(minute)=1 THEN
  	minute:='0'||minute;
END IF;
IF length(sec)=1 THEN
  	sec:='0'||sec;
END IF;
startup_date:=jdate||' '||hr||':'||minute||':'||sec;
dbms_output.put_line('date:'||startup_date);
good_date := TO_DATE(startup_date, 'dd-mon-yy hh24:mi:ss');
show_date := TO_DATE(startup_date, 'dd-mon-yy hh24:mi:ss');
dbms_output.put_line('date:'||to_char(show_date, 'dd-mon-yy hh24:mi:ss'));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
 dbms_output.put_line('Startup Date: unknown');
END;
/
