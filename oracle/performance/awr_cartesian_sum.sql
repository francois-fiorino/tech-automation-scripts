/*
===============================================================================
SCRIPT: awr_cartesian_sum.sql
CATEGORIA: Oracle / Performance / Estimativa de espaço
ORIGEM: Coleção Oracle 2015

OBJETIVO
  Estimar espaço utilizado e alocado para um índice hipotético sobre a coluna
  VALUE da tabela STATS$SYSSTAT no tablespace SYSAUX.

FUNCIONAMENTO
  O bloco PL/SQL chama DBMS_SPACE.CREATE_INDEX_COST com uma instrução
  CREATE INDEX fornecida como TEXTO para estimativa. O script NÃO executa
  diretamente a criação do índice. Mostra Used Bytes e Allocated Bytes.
  Apesar do nome do arquivo, não analisa joins cartesianos nem consulta AWR.

PRÉ-REQUISITOS
  Acesso ao pacote DBMS_SPACE, à tabela referenciada e às estatísticas
  necessárias. Habilitar DBMS_OUTPUT no cliente (SET SERVEROUTPUT ON).

EXECUÇÃO (SOMENTE APÓS TESTES)
  SQL> SET SERVEROUTPUT ON
  SQL> @awr_cartesian_sum.sql

SAÍDA ESPERADA
  Used Bytes      = <estimativa>
  Allocated Bytes = <estimativa>

RISCOS E LIMITAÇÕES
  Referências a STATS$SYSSTAT e SYSAUX estão fixas. O procedimento estima
  espaço e não cria o índice. Resultados dependem do objeto e das estatísticas.
  Compatibilidade com versões Oracle não foi homologada.

AVISO DE RESPONSABILIDADE
  Revise integralmente e teste em ambiente controlado antes do uso.
  Fornecido AS IS, sem garantias; uso por conta e risco do executor.
  Os mantenedores não se responsabilizam por danos decorrentes do uso,
  nos limites permitidos pela legislação aplicável.

STATUS: revisão estática; não executado em banco Oracle.
===============================================================================
*/

/*  */
declare
   u_bytes number;
   a_bytes number;
begin
   dbms_space.create_index_cost (
      ddl => 'create index stats$sysstat_idx on stats$sysstat '||
        '(value) tablespace sysaux',
      used_bytes => u_bytes,
      alloc_bytes => a_bytes
   );
   dbms_output.put_line ('Used Bytes      = '|| u_bytes);
   dbms_output.put_line ('Allocated Bytes = '|| a_bytes);
end;
/
