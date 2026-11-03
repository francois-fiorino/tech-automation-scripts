/*
===============================================================================
SCRIPT: pword_gen.sql
CATEGORIA: Oracle / security
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/pword_gen.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Preservar exemplo histórico de gerador pseudoaleatório de seis letras.

FUNCIONAMENTO DETALHADO
  Usa HSECS/constante pi e potências fracionárias para produzir caracteres A..Z; cria GEN_PWORD.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme LIMITAÇÕES; roles não
  bastam para compilar dependências de rotinas armazenadas. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$TIMER, DBMS_OUTPUT; função GEN_PWORD

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE e SELECT direto. Previsível, curto e sem fonte criptográfica; não atende geração segura de senhas. HSECS wrap e tempo fornecem pouca entropia; não configurar contas com esta saída.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente análise educacional em schema descartável; não gerar credenciais de uso real.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  String de seis letras maiúsculas.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados ou sessão descritos
  acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Algoritmo integral preservado para estudo; não descrito como mecanismo de segurança adequado. 
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
create or replace function gen_pword return varchar2 as
   pi        number := 3.141592653589793238462643 ;
   seed      number ;
   pwd       varchar2(6);
   pwd_len   number := 6;          /* length of password */
begin
   dbms_output.enable(1000000);
   select to_number(to_char(hsecs)) / 8640000 into seed from v$timer ;      /*     0<= seed  < 1 */
   pwd := null ;
       FOR  j  in 1..pwd_len LOOP
          seed := power(pi + seed,5)  - trunc (power(pi + seed,5) );
          pwd := pwd || chr( 64 + 1 + trunc (seed * 26)) ;
       END LOOP;
--       dbms_output.put_line (pwd);
return pwd;
end;
/
