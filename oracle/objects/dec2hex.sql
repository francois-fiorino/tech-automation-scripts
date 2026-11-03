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
  CREATE PROCEDURE. Sem validação completa: entrada negativa/fracionária em DEC2HEX pode falhar; HEXTOINTEGER não valida dígitos/case e pode overflow PLS_INTEGER. INTEGERTOHEX retorna NULL para zero/negativos pelo contrato legado. Não usar para converter SPID decimal indiscriminadamente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

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
  RETURN NULL inválido em procedimento trocado por OUT=NULL e RETURN; demais algoritmos/crédito Jonas Nordstrom preservados. 
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
BEGIN
   IF NVL (LENGTH (h), 1) = 1
   THEN
      RETURN INSTR ('0123456789ABCDEF', h) - 1;
   ELSE
      RETURN 16 * hextointeger (SUBSTR (h, 1, LENGTH (h) - 1)) +
             INSTR ('0123456789ABCDEF', SUBSTR (h, -1)) -
             1;
   END IF;
END hextointeger;
/

CREATE OR REPLACE FUNCTION integertohex (n pls_integer)
   RETURN VARCHAR2
IS
BEGIN
   IF n > 0
   THEN
      RETURN integertohex (TRUNC (n / 16)) ||
             SUBSTR ('0123456789ABCDEF', MOD (n, 16) + 1, 1);
   ELSE
      RETURN NULL;
   END IF;
END integertohex;
/





