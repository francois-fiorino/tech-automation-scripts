/*
===============================================================================
SCRIPT: i_o_per_sec.sql
CATEGORIA: Oracle / performance
ORIGEM: Oracle Script Collection 2015 / _i_o_scripts/i_o_per_sec.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Calcular média acumulada de operações de I/O de datafiles e tempfiles.

FUNCIONAMENTO DETALHADO
  Agrega PHYRDS+PHYWRTS separadamente em V_$FILESTAT e V_$TEMPSTAT; soma os totais e divide pelos segundos decorridos desde STARTUP_TIME. Imprime DBMS_OUTPUT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$FILESTAT, SYS.V_$TEMPSTAT, V$INSTANCE, DUAL, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Oracle com essas views e colunas; média desde startup, não IOPS do último segundo. Contadores de arquivos podem ter ciclos próprios. Operações não equivalem a blocos/bytes nem a IOPS de storage.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @i_o_per_sec.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Elapsed Sec, Fixed IO/SEC, Temp IO/SEC e Total IO/SEC; NULL se intervalo zero.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Agregações independentes eliminam multiplicação por produto cartesiano e perda de dados se uma view está vazia; NULLIF protege intervalo zero; cursor fechado explicitamente. 
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

-- comment:  I/O per second report

set serveroutput on;

declare
cursor get_io is
select f.sum_io1, t.sum_io2, f.sum_io1+t.sum_io2 tot_io
from (select nvl(sum(phyrds+phywrts),0) sum_io1 from sys.v_$filestat) f
cross join (select nvl(sum(phyrds+phywrts),0) sum_io2 from sys.v_$tempstat) t;
now date;
elapsed_seconds number;
sum_io1 number;
sum_io2 number;
tot_io number;
tot_io_per_sec number;
fixed_io_per_sec number;
temp_io_per_sec number;
begin
open get_io;
fetch get_io into sum_io1, sum_io2, tot_io;
close get_io;
select sysdate into now from dual;
select ceil((now-startup_time)*(60*60*24)) into elapsed_seconds from v$instance;
fixed_io_per_sec:=sum_io1/nullif(elapsed_seconds,0);
temp_io_per_sec:=sum_io2/nullif(elapsed_seconds,0);
tot_io_per_sec:=tot_io/nullif(elapsed_seconds,0);
dbms_output.put_line('Elapsed Sec:'||to_char(elapsed_seconds));
dbms_output.put_line('Fixed IO/SEC:'||to_char(fixed_io_per_sec));
dbms_output.put_line('Temp IO/SEC:'||to_char(Temp_io_per_sec));
dbms_output.put_line('Total IO/SEC:'||to_char(Tot_IO_Per_Sec));
end;
/
