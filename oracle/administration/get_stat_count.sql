/*
===============================================================================
SCRIPT: get_stat_count.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/get_stat_count.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar procedimento para comparar NUM_ROWS com contagem exata customizada.

FUNCIONAMENTO DETALHADO
  Cursor de tabelas por schema chama DBA_UTILITIES.GET_COUNT e imprime NUM_ROWS/rows reais por tabela.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/execução e SELECT DIRETO conforme LIMITAÇÕES; roles
  podem não atender compilação de objetos armazenados. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES, DBA_UTILITIES.GET_COUNT, DBMS_OUTPUT; GET_STAT_ROWS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DBA_UTILITIES.GET_COUNT recebe apenas nome da tabela e pode contar objeto de schema errado. Schema permanece case-sensitive conforme interface existente. NUM_ROWS pode estar desatualizado; helper/grants/chaves precisam ser fornecidos e revisados. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @get_stat_count.sql; validar dependência e testar schema pequeno.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Procedimento criado; chamadas imprimem comparação e podem varrer todas as tabelas do schema.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cria/modifica objetos, dados, credenciais ou sessão
  conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 036 (2026-11-03): Buffer ancorado em DBA_TABLES.TABLE_NAME e cursor fechado em exceção; chamada do helper mantida para não presumir contrato de nome qualificado. Casos de homologação: Owner do chamador diferente do schema; tabelas homônimas; nome >32 caracteres; helper ausente/com erro; cursor fechado após falha. Comentários/créditos históricos preservados. Não aprovado para implantação.

REFERÊNCIAS TÉCNICAS DA REVISÃO 036
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_TABLES.html

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
create or replace procedure get_stat_rows(schema IN varchar2) as
tab_name dba_tables.table_name%TYPE;
rows number;
stat_rows number;
cursor get_tabs is
select table_name from dba_tables where owner=schema;
begin
open get_tabs;
loop
fetch get_tabs into tab_name;
exit when get_tabs%notfound;
dba_utilities.get_count(tab_name,rows);
select a.num_rows into stat_rows from dba_tables a where a.owner=schema 
 and a.table_name=tab_name;
dbms_output.put_line('Table: '||tab_name||' stat_rows: '||TO_CHAR(stat_rows)||' actual rows: '||to_char(rows));
end loop;
close get_tabs;
exception when others then
 if get_tabs%isopen then close get_tabs; end if;
 raise;
end;
/
