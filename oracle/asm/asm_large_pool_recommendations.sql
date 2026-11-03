/*
===============================================================================
SCRIPT: asm_large_pool_recommendations.sql
CATEGORIA: Oracle / asm
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/asm_large_pool_recommendations.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Calcular estimativa histórica de acréscimo de large pool por tamanho lógico de arquivos.

FUNCIONAMENTO DETALHADO
  Soma DATAFILE/LOG/TEMPFILE, converte para GiB e aplica três fórmulas por redundância, imprimindo MB.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$DATAFILE, V$LOG, V$TEMPFILE, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Executar conectado ao banco, não à instância ASM sem essas views. Não mede discos ASM nem conta redo members/mirrors. Fórmula histórica não substitui orientação da versão ou dimensionamento real; não altera parâmetros.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @asm_large_pool_recommendations.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Total lógico em GiB e três estimativas de acréscimo em MB do exemplo.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NVL nas três somas evita total NULL quando não há tempfiles ou linhas; mensagens contextualizadas como estimativa histórica. 
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
   db_file_size   number;
   log_file_size  number;
   temp_file_size number;
   tot_file_size  number; 
   recommend_size number;
begin
   select 
      nvl(sum(bytes),0) into db_file_size
   from 
      v$datafile;

   select 
      nvl(sum(bytes),0) into log_file_size
   from 
      v$log;

   select 
      nvl(sum(bytes),0) into temp_file_size
   from 
      v$tempfile;

   tot_file_size := (db_file_size+log_file_size+temp_file_size)/1024/1024/1024;
   dbms_output.put_line('Total DB Size (GiB): '||round(tot_file_size,2)||chr(10));

   -- external redundancy
   recommend_size := round(2 + floor(tot_file_size/100),2);
   dbms_output.put_line('For External Redundancy historical estimated increment of Large Pool: '||recommend_size||' MB');

   -- normal redundancy
   recommend_size := round(4 + floor(tot_file_size/50),2);
   dbms_output.put_line('For Normal Redundancy historical estimated increment of Large Pool: '||recommend_size||' MB');

   -- high redundancy
   recommend_size := round(6 + floor(tot_file_size/33),2);
   dbms_output.put_line('For High Redundancy historical estimated increment of Large Pool: '||recommend_size||' MB');

end;
/