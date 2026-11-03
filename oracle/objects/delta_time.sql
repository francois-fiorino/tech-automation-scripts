/*
===============================================================================
SCRIPT: delta_time.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/delta_time.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar função histórica TIME_DELTA com retorno textual de diferença de horários.

FUNCIONAMENTO DETALHADO
  Decompõe horas/minutos/segundos de duas DATEs, calcula diferença de segundos do dia e formata sobre TRUNC(SYSDATE).

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DUAL, DBMS_OUTPUT; função TIME_DELTA

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE. Ignora número de dias e pode produzir resultado errado na virada de dia ou entre datas distintas; contrato HH24 também limita duração. Mantido para revisão antes de definir semântica de duração absoluta/sinal/dias.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @delta_time.sql; testar datas iguais, virada de dia e intervalos longos.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  VARCHAR2 HH24:MI:SS e impressão DBMS_OUTPUT.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código integral preservado; limitação temporal explicitada, sem alterar contrato sem testes. 
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
create or replace function time_delta (date1 IN DATE, date2 IN DATE)
return varchar2 as
 date3 date;
 hr1  number;
 min1  number;
 sec1  number;
 hr2  number;
 min2 number;
 sec2  number;
 secs1 number;
 secs2 number;
 delta number;
begin
 hr1:=to_number(to_char(date1, 'hh24'));
 min1:=to_number(to_char(date1, 'mi'));
 sec1:=to_number(to_char(date1, 'ss'));
 secs1:=(hr1*3600)+(min1*60)+sec1;
 hr2:=to_number(to_char(date2, 'hh24'));
 min2:=to_number(to_char(date2, 'mi'));
 sec2:=to_number(to_char(date2, 'ss'));
 secs2:=(hr2*3600)+(min2*60)+sec2;
 if date1>date2 then
   delta:=secs1-secs2;
 else
   delta:=secs2-secs1;
 end if;
 select trunc(sysdate)+(delta/86400) into date3 from dual;
 dbms_output.put_line(to_char((date3), 'hh24:mi:ss'));
 return to_char((date3), 'hh24:mi:ss');
end;
/
