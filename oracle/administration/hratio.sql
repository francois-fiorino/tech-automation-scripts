/*
===============================================================================
SCRIPT: hratio.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/hratio.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar coletor de hit ratio acumulado e deltas horários customizados.

FUNCIONAMENTO DETALHADO
  Lê três SYSSTAT e sessões, INSERT HIT_RATIOS, calcula diferenças entre horas adjacentes e faz três COMMITs.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SYSSTAT, V$SESSION, DUAL, HIT_RATIOS, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE/grants diretos/DML. Horários duplicados podem causar ORA-01427; restart invalida deltas. Tratamento ZERO_DIVIDE insere nova linha e pode duplicar coleta; não homologado. Hit ratio não diagnostica I/O sozinho.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente revisão com HIT_RATIOS descartável e contrato de nove colunas.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Procedimento criado; chamada grava e atualiza histórico.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  C_DATE usa TRUNC(SYSDATE), eliminando roundtrip textual/NLS; divisor acumulado protegido. Deltas e handler originais preservados com pendências explícitas. 
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
CREATE OR REPLACE PROCEDURE HITRATIO IS
    C_DATE DATE;
    C_HOUR NUMBER := 0;
    H_RATIO NUMBER(5,2) := 0;
    CON_GETS NUMBER := 0;
    DB_GETS NUMBER := 0;
    P_READS NUMBER := 0;
    STAT_NAME VARCHAR(64);
    temp_NAME VARCHAR(64);
    STAT_VAL NUMBER := 0;
    USERS  NUMBER := 0;
 CURSOR get_stat(p_name varchar2) IS
select
		name,
		value
	from
		v$sysstat
    	where
		name = p_name;
BEGIN
  select trunc(sysdate) into c_date from dual;
  select to_char(sysdate,'HH24') into c_hour from dual;
  STAT_NAME := 'db block gets';
  OPEN get_stat(stat_name);
  FETCH get_stat INTO temp_name,db_gets;
  CLOSE get_stat;
dbms_output.put_line(temp_name||':'||to_char(db_gets));
   STAT_NAME := 'consistent gets';
  OPEN get_stat(stat_name);
  FETCH get_stat INTO temp_name,con_gets;
  CLOSE get_stat;
dbms_output.put_line(temp_name||':'||to_char(con_gets));
  STAT_NAME := 'physical reads';
  OPEN get_stat(stat_name);
  FETCH get_stat INTO temp_name,p_reads;
  CLOSE get_stat;
dbms_output.put_line(temp_name||':'||to_char(p_reads));
    select count(*) into users from v$session where username is not null;
      H_RATIO := (((DB_GETS+CON_GETS-p_reads)/nullif(DB_GETS+CON_GETS,0))*100);
dbms_output.put_line('hit_ratio:'||to_char(h_ratio));
    INSERT INTO  hit_ratios
      VALUES (c_date,c_hour,db_gets,con_gets,p_reads,h_ratio,0,0,users);
commit;
update hit_ratios set period_hit_ratio =
    (select round((((h2.consistent-h1.consistent)+(h2.db_block_gets-h1.db_block_gets)-
    (h2.phy_reads-h1.phy_reads))/((h2.consistent-h1.consistent)+
        (h2.db_block_gets-h1.db_block_gets)))*100,2) from hit_ratios h1, hit_ratios h2
    where h2.check_date = hit_ratios.check_date and h2.check_hour = hit_ratios.check_hour
    and ((h1.check_date = h2.check_date and h1.check_hour+1 = h2.check_hour) or
    (h1.check_date+1 = h2.check_date and h1.check_hour = '23' and h2.check_hour='0')))
where period_hit_ratio = 0;
  COMMIT;
update hit_ratios set period_USAGE =
    (select ((h2.consistent-h1.consistent)+(h2.db_block_gets-h1.db_block_gets))
    from hit_ratios h1, hit_ratios h2 where h2.check_date = hit_ratios.check_date
    and h2.check_hour = hit_ratios.check_hour  and ((h1.check_date = h2.check_date
    and h1.check_hour+1 = h2.check_hour) or (h1.check_date+1 = h2.check_date and
    h1.check_hour = '23' and h2.check_hour='0'))) where period_USAGE = 0;
  COMMIT;
EXCEPTION
    WHEN ZERO_DIVIDE THEN
    INSERT INTO  hit_ratios  VALUES (c_date,c_hour,db_gets,con_gets,p_reads,0,0,0,users);
    COMMIT;
END;
/
