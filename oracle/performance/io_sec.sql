/*
===============================================================================
SCRIPT: io_sec.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / _i_o_scripts/io_sec.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Apresentar médias acumuladas de I/O permanente, temporário e total.

FUNCIONAMENTO DETALHADO
  Lê duas linhas rotuladas FIXED/TEMP por UNION ALL; atribui contadores pelo rótulo, soma e divide pelo tempo desde startup. Formata a saída DBMS_OUTPUT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$FILESTAT, SYS.V_$TEMPSTAT, V$INSTANCE, DUAL, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Sem garantia de ordem de linhas em UNION: código corrigido independe dela. Média acumulada não mede throughput instantâneo nem largura de banda.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @io_sec.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Elapsed Sec, Fixed IO/SEC, Temp IO/SEC e Total IO/SEC formatados; máscaras podem mostrar # para números grandes.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  UNION substituído por UNION ALL com rótulos; atribuição por tipo substitui dependência da ordem de FETCH; NULLIF nas razões; cursor fechado. 
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
set serveroutput on
declare
cursor get_io is select
        'FIXED' io_type,
        nvl(sum(a.phyrds+a.phywrts),0) sum_io1,to_number(null) sum_io2
from sys.v_$filestat a
union all
select
        'TEMP' io_type, to_number(null) sum_io1, nvl(sum(b.phyrds+b.phywrts),0) sum_io2
from
        sys.v_$tempstat b;
io_type varchar2(5);
now date;
elapsed_seconds number;
sum_io1 number;
sum_io2 number;
sum_io12 number;
sum_io22 number;
tot_io number;
tot_io_per_sec number;
fixed_io_per_sec number;
temp_io_per_sec number;
begin
open get_io;
for i in 1..2 loop
fetch get_io into io_type, sum_io1, sum_io2;
if io_type = 'FIXED' then sum_io12:=sum_io1;
else
sum_io22:=sum_io2;
end if;
end loop;
close get_io;
select sum_io12+sum_io22 into tot_io from dual;
select sysdate into now from dual;
select ceil((now-startup_time)*(60*60*24)) into elapsed_seconds from v$instance;
fixed_io_per_sec:=sum_io12/nullif(elapsed_seconds,0);
temp_io_per_sec:=sum_io22/nullif(elapsed_seconds,0);
tot_io_per_sec:=tot_io/nullif(elapsed_seconds,0);
dbms_output.put_line('Elapsed Sec :'||to_char(elapsed_seconds, '9,999,999.99'));
dbms_output.put_line('Fixed IO/SEC:'||to_char(fixed_io_per_sec,'9,999,999.99'));
dbms_output.put_line('Temp IO/SEC :'||to_char(temp_io_per_sec, '9,999,999.99'));
dbms_output.put_line('Total IO/SEC:'||to_char(tot_io_Per_Sec,  '9,999,999.99'));
end;
/
