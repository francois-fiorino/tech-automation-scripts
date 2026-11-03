/*
===============================================================================
SCRIPT: dec2hex.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/dec2hex.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar conversores numéricos/hexadecimais históricos.

FUNCIONAMENTO DETALHADO
  DEC2HEX usa tabela de dígitos e MOD; HEXTOINTEGER e INTEGERTOHEX usam recursão base 16.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  Rotinas DEC2HEX, HEXTOINTEGER, INTEGERTOHEX

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Domínio agora explícito: DEC2HEX inteiro NUMBER não negativo; HEXTOINTEGER 0..7FFFFFFF sem sinal/prefixo; INTEGERTOHEX PLS_INTEGER não negativo. Isso muda retornos indevidos anteriores para erro e corrige zero. Não interpreta hexadecimal como signed/two-complement. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @dec2hex.sql; testar NULL/0/15/16/negativos/caracteres inválidos.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Três rotinas criadas; conversão conforme domínio de cada algoritmo.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 036 (2026-11-03): Preservado o algoritmo modular e crédito Jonas Nordstrom. Entradas inválidas rejeitadas; HEXTOINTEGER aceita lowercase, trata NULL e limita ao PLS_INTEGER positivo. INTEGERTOHEX(0) retorna 0, preservando recursão sem zeros extras. Casos de homologação: NULL,0,15,16,255,2147483647; lowercase; G, espaços, sinal, fração, -1 e 80000000; roundtrip no domínio comum. Comentários/créditos históricos preservados. Não aprovado para implantação.

REFERÊNCIAS TÉCNICAS DA REVISÃO 036
 https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/pls_integer-and-binary_integer-data-types.html

AVISO DE RESPONSABILIDADE
AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de
qualquer utilização em produção. Sua execução é de responsabilidade do
profissional responsável pelo ambiente. Os mantenedores deste repositório não
se responsabilizam por indisponibilidade, perda de dados, alterações indevidas
ou outros impactos decorrentes de sua utilização.

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
/* Formatted by PL/Formatter v.1.1.8 on 2011/11/25 12:56  (12:56 AM) */


CREATE OR REPLACE PROCEDURE dec2hex (in_num IN NUMBER, out_hex OUT VARCHAR2)
IS
   TYPE vc2tab_type IS TABLE OF VARCHAR2(1)
      INDEX BY BINARY_INTEGER;

   hextab                        vc2tab_type;
   v_num                         NUMBER;
   v_hex                         VARCHAR2(200);

/*
Author: Jonas Nordstrom 
*/
BEGIN
   IF in_num IS NULL THEN out_hex:=NULL; RETURN; END IF;
   IF in_num<0 OR in_num<>TRUNC(in_num) THEN
      RAISE_APPLICATION_ERROR(-20012,'DEC2HEX requer inteiro nao negativo.');
   END IF;   

   hextab  (0) := '0';
   hextab  (1) := '1';
   hextab  (2) := '2';
   hextab  (3) := '3';
   hextab  (4) := '4';
   hextab  (5) := '5';
   hextab  (6) := '6';
   hextab  (7) := '7';
   hextab  (8) := '8';
   hextab  (9) := '9';
   hextab  (10) := 'A';
   hextab  (11) := 'B';
   hextab  (12) := 'C';
   hextab  (13) := 'D';
   hextab  (14) := 'E';
   hextab  (15) := 'F';
   v_num := in_num;

   WHILE v_num >= 16
   LOOP
      v_hex := hextab (MOD (v_num, 16)) || v_hex;
      v_num := TRUNC (v_num / 16);
   END LOOP;

   v_hex := hextab (MOD (v_num, 16)) || v_hex;
   out_hex := v_hex;
END;   -- dec2hex
/

CREATE OR REPLACE FUNCTION hextointeger (h VARCHAR2)
   RETURN PLS_INTEGER
IS
   normalized VARCHAR2(8);
   value_number NUMBER;
BEGIN
   IF h IS NULL THEN RETURN NULL; END IF;
   IF LENGTH(h)>8 OR TRANSLATE(UPPER(h),'x0123456789ABCDEF','x') IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(-20013,'Hexadecimal invalido ou fora do dominio PLS_INTEGER.');
   END IF;
   normalized:=UPPER(h);
   IF LENGTH(normalized)=1 THEN
      value_number:=INSTR('0123456789ABCDEF',normalized)-1;
   ELSE
      value_number:=16*TO_NUMBER(hextointeger(SUBSTR(normalized,1,LENGTH(normalized)-1)))+
                    INSTR('0123456789ABCDEF',SUBSTR(normalized,-1))-1;
   END IF;
   IF value_number>2147483647 THEN
      RAISE_APPLICATION_ERROR(-20013,'Hexadecimal excede PLS_INTEGER positivo.');
   END IF;
   RETURN value_number;
END hextointeger;
/

CREATE OR REPLACE FUNCTION integertohex (n PLS_INTEGER)
   RETURN VARCHAR2
IS
BEGIN
   IF n IS NULL THEN RETURN NULL; END IF;
   IF n<0 THEN
      RAISE_APPLICATION_ERROR(-20014,'INTEGERTOHEX requer inteiro nao negativo.');
   ELSIF n<16 THEN
      RETURN SUBSTR('0123456789ABCDEF',n+1,1);
   ELSE
      RETURN integertohex(TRUNC(n/16))||SUBSTR('0123456789ABCDEF',MOD(n,16)+1,1);
   END IF;
END integertohex;
/
