/*
===============================================================================
SCRIPT: random.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/random.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar gerador pseudoaleatório histórico com estado de sessão.

FUNCIONAMENTO DETALHADO
  Pacote RANDOM usa congruência modular e seed HSECS; RNDFLT retorna fração e RNDINT escala por R.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$TIMER; pacote RANDOM

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE e SELECT direto. Não criptográfico, previsível e com estado por sessão; não usar para senhas/tokens. R deve ser inteiro positivo, sem garantia estatística/qualidade moderna.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @random.sql; testar faixas de RNDFLT e RNDINT com R inteiro positivo.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Pacote criado; chamadas avançam estado e retornam valores pseudoaleatórios.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Escala de RNDINT corrigida de TRUNC(A/M1)*R/M1, que quase sempre produzia zero, para TRUNC((A/M)*R); implementação modular completa preservada. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 043 — 04/11/2026
  Correções e melhorias: Algoritmo modular completo e escala deRNDINT preservados.
  Limitações e pendências: Não criptográfico; estado por sessão, seedtimer previsível e R sem validação. RNULL/zero/negativo/fracionário não têm contrato de inteiropositivo. Não usar para autenticação.
  Homologação necessária: Conferir aritmética modular com inteiros exatos, reprodução com seedfixa e faixa0<=x<R para Rpositivo; sem alegar qualidade estatística.
  Parâmetros/execução: contratos acima e corpo histórico; somente laboratório.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral/análise estática; sem compilação ou execução Oracle,
  Windows, escrita de arquivo no servidor, backup/recovery ou alteração de contas.

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
create or replace package random as
function rndint(r in number) return number;
function rndflt return number;
end;
/

create or replace package body random as
m constant number :=100000000000000;  
m1 constant number:=1000000000000;     
b constant number:=31415821;   
a number;                      
the_date date;                
days number;                   
secs number;                   
function mult(p in number, q in number) return number is
   p1 number;
   p0 number;
   q1 number;
   q0 number;
   x  number;
BEGIN
   p1:=trunc(p/m1);
   p0:=mod(p,m1);
   q1:=trunc(q/m1);
   q0:=mod(q,m1);
   x:=mod((mod(p0*q1+p1*q0,m1)*m1+p0*q0),m);
   return(x);
END;
function rndint (r in number) return number is
x number;
BEGIN
   a:=mod(mult(a,b)+1,m);
   x:=trunc((a/m)*r);
   return(x);
END;
function rndflt return number is
x number;
BEGIN
   a:=mod(mult(a,b)+1,m);
   x:=a/m;
   return(x);
END;
BEGIN
--   the_date:=sysdate;
--   days:=to_number(to_char(the_date, 'J'));
--   secs:=to_number(to_char(the_date, 'SSSSS'));
--   a:=days*24*3600+secs;
select hsecs into a from v$timer;
END;
/

