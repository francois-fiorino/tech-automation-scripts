/*
===============================================================================
SCRIPT: max_hourly_log_switches.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/max_hourly_log_switches.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Estimar máximo de entradas de redo por hora no histórico retido por instância atual.

FUNCIONAMENTO DETALHADO
  Agrupa LOG_HISTORY por thread associado ao GV$INSTANCE e hora; cursor calcula máximo por instância e imprime nomes.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$LOG_HISTORY, GV$INSTANCE, V$DATABASE, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Retenção limitada e hora FIRST_TIME representam início do log; não medem throughput. Só threads mapeados a instâncias atualmente visíveis; mapping histórico pode ter mudado. Não executa switches.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @max_hourly_log_switches.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Instance e Max Hourly Switches sobre histórico da incarnation atual retido no control file.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  GV$LOG atual substituído por V$LOG_HISTORY sem duplicação global, usando THREAD# e RESETLOGS_CHANGE# atual; cursor fechado e saída vazia tratada. Referências: docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-LOG_HISTORY.html e V-INSTANCE.html. 
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

set serveroutput on

declare
   cursor c1 is
   select i.inst_id,count(*)
   from v$log_history h join gv$instance i on i.thread#=h.thread#
   where h.resetlogs_change#=(select resetlogs_change# from v$database)
   group by i.inst_id,to_char(h.first_time,'YYYY-MM-DD HH24')
   order by i.inst_id;

   v_inst number;
   v_curr number;
   v_cnt  number;
   v_max  number;
   v_name varchar2(16);

begin

   open c1;
   v_curr:=0;
 
   loop
      fetch c1 into v_inst,v_cnt;
      exit when c1%notfound;
      if (v_curr<>v_inst) then
          if (v_curr<>0) then
             select 
                instance_name into v_name 
             from 
                gv$instance 
             where 
                inst_id=v_curr;
             dbms_output.put_line('Instance: '||v_name||
                         '   Max Hourly Switches: '||v_max);
         end if;
         v_max := -1;
         v_curr := v_inst;
     end if;
     if (v_max < v_cnt) then
         v_max := v_cnt;
     end if;

    end loop;
    close c1;
    if v_curr=0 then
      dbms_output.put_line('Sem historico para threads/instancias atuais.');
      return;
    end if;
    select 
       instance_name into v_name 
    from 
       gv$instance 
    where 
       inst_id=v_curr;
    dbms_output.put_line('Instance: '||v_name||
                '   Max Hourly Switches: '||v_max);
 
end;
/
