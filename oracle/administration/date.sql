/*
===============================================================================
SCRIPT: date.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/DATE.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Reproduzir cálculo legado da data de inicialização por dia juliano e segundos.

FUNCIONAMENTO DETALHADO
  Bloco anônimo lê V$INSTANCE em formato KEY/VALUE, decompõe segundos e imprime data concatenada.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$INSTANCE (layout legado KEY/VALUE), DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Layout KEY/VALUE não existe em V$INSTANCE moderno; não homologado e não deve ser usado como fonte atual. Versões modernas expõem STARTUP_TIME, mas algoritmo original foi preservado para estudo. Conversão implícita DATE depende de NLS.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @date.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Startup Date montada pelo algoritmo histórico, ou erro de colunas incompatíveis.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  SERVEROUTPUT e terminador / adicionados; cálculo histórico completo preservado, sem substituir por consulta simplificada. 
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
/*  */
declare
jdate date;
jsec number;
hr number;
minute number;
sec1 number;
sec2 number;
sec number;
startup_date varchar2(25);
begin
select to_date(to_number(value,'99999999'),'J') into jdate from
v$instance where key='STARTUP TIME - JULIAN';
select (to_number(value,'9999999')) into jsec from v$instance
where key='STARTUP TIME - SECONDS';
hr:=trunc(jsec/3600,0);
minute:= trunc(((jsec/3600)-hr)*60,0);
/*sec1 := (jsec/3600)-hr;
sec2 := (sec1 * 60)-minute;
sec := trunc(sec2*60,0);*/
sec:= trunc((((((jsec/3600)-hr)*60)-minute)*60),0);
startup_date:=jdate||' '||to_char(hr)||':'||to_char(minute)||':'||
to_char(sec);
dbms_output.put_line('Startup Date: '||startup_date);
end;
/
