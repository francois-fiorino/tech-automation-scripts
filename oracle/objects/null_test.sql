/*
===============================================================================
SCRIPT: null_test.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/null_test.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Testar três valores booleanos por rotina customizada PRICE_INCREASE.

FUNCIONAMENTO DETALHADO
  Quatro chamadas preenchem booleanos e classificam TRUE/FALSE/NULL como 1/2/3 para impressão.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  PRICE_INCREASE (não localizada no ZIP), DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Rotina externa pode ter efeitos não conhecidos; não executar sem defini-la e revisá-la. TRUE1 estava FALSE, invalidando teste null and true. BOOLEAN PL/SQL não é SQL BOOLEAN em versões antigas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório após revisar definição de PRICE_INCREASE: @null_test.sql.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Texto com quatro classificações, se dependência compatível estiver instalada.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  TRUE1 inicializado TRUE em coerência com caso declarado; demais casos e classificação preservados. Dependência continua pendente de fornecimento. 
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
declare
true1 boolean;
false1 boolean;
null1 boolean;
answer1 boolean;
answer2 boolean;
answer3 boolean;
answer4 boolean;
x integer;
y integer;
z integer;
a integer;
begin
true1:=TRUE;
false1:=FALSE;
null1:=NULL;
price_increase(null1,true1,answer1);
price_increase(null1,false1,answer2);
price_increase(null1,null1,answer3);
price_increase(false1,false1,answer4);
if answer1 then 
   x:=1;
elsif not answer1 then 
   x:=2;
elsif answer1 is null then 
   x:=3;
end if;
if answer2 then 
  y:=1;
elsif not answer2 then 
  y:=2;
elsif answer2 is null then 
  y:=3;
end if;
if answer3 then 
  z:=1;
elsif not answer3 then 
  z:=2;
elsif answer3 is null then 
  z:=3;
end if;
if answer4 then 
   a:=1;
elsif not answer4 then 
   a:=2;
elsif answer4 is null then 
   a:=3;
end if;
dbms_output.put_line('null and true:'||to_char(x)||' null and false:'||to_char(y)||chr(10)||
' null and null:'||to_char(z)||' false and false:'||to_char(a));
end;
/
