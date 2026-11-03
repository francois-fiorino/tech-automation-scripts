/*
===============================================================================
SCRIPT: default_dop.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/default_dop.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Calcular estimativa histórica de DOP a partir de CPU e quantidade de instâncias.

FUNCIONAMENTO DETALHADO
  PL/SQL lê CPU_COUNT/PARALLEL_THREADS_PER_CPU locais, conta GV$INSTANCE e multiplica, imprimindo DBMS_OUTPUT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$PARAMETER, GV$INSTANCE, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  É heurística para configuração homogênea; não é grau efetivo garantido sob Auto DOP, serviços, force_local, recursos e configurações diferentes entre nós. Não altera paralelismo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @default_dop.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Default DOP como produto de três valores.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Cálculo original preservado. 
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
   cpu_cnt   number;
   t_per_cpu number;
   inst_cnt  number;
begin
   select
      value into t_per_cpu
   from 
      v$parameter
   where 
      name='parallel_threads_per_cpu';

   select
      value into cpu_cnt
   from
      v$parameter
   where
      name='cpu_count';

   select
      count(*) into inst_cnt
   from
      gv$instance;

   dbms_output.put_line('Default DOP: ' || cpu_cnt * t_per_cpu * inst_cnt);

end;
/