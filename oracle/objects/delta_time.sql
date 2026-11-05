/*
===============================================================================
SCRIPT: delta_time.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/delta_time.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar função histórica TIME_DELTA com retorno textual de diferença de horários.

FUNCIONAMENTO DETALHADO
  Subtrai DATEs, converte valor absoluto para segundos e formata horas totais, minutos e segundos, sem usar uma data intermediária.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DUAL, DBMS_OUTPUT; função TIME_DELTA

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Contrato corrigido é duração absoluta H+:MI:SS, com pelo menos dois dígitos de hora. Para intervalos >=24h, saída pode ter mais de 8 caracteres e consumidores precisam adequação. DATE não contém fuso; não calcula DST ou precisão de TIMESTAMP. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

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
  Revisão complementar 036 (2026-11-03): Diferença absoluta usa todas as componentes DATE, inclusive dias. Mantidos retorno textual e DBMS_OUTPUT; horas totais não fazem wrap em 24h. NULL retorna NULL. Casos de homologação: Datas iguais; virada de meia-noite; 25h; vários dias; argumentos invertidos; NULL; NLS distintos. Comentários/créditos históricos preservados. Não aprovado para implantação.

REFERÊNCIAS TÉCNICAS DA REVISÃO 036
 https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/Data-Types.html

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
create or replace function time_delta(date1 IN DATE,date2 IN DATE)
return varchar2 as
 elapsed_seconds NUMBER;
 hours_text VARCHAR2(40);
 result_text VARCHAR2(80);
begin
 if date1 is null or date2 is null then return null; end if;
 elapsed_seconds:=ROUND(ABS(date1-date2)*86400);
 hours_text:=TO_CHAR(TRUNC(elapsed_seconds/3600),'FM999999999999990');
 result_text:=LPAD(hours_text,GREATEST(2,LENGTH(hours_text)),'0')||':'||
   TO_CHAR(TRUNC(MOD(elapsed_seconds,3600)/60),'FM00')||':'||
   TO_CHAR(MOD(elapsed_seconds,60),'FM00');
 DBMS_OUTPUT.PUT_LINE(result_text);
 return result_text;
end;
/
