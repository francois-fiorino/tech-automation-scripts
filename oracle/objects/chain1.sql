/*
===============================================================================
SCRIPT: chain1.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/chain1.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Demonstrar expansão de linhas e investigação de chaining/migration em tabela teste.

FUNCIONAMENTO DETALHADO
  DROP/CREATE CHAIN1, mil INSERTs com COMMIT por linha, UPDATE de seis colunas para strings 240 e ANALYZE; recria view.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  CHAIN1, CHAIN1_VIEW, ANALYZE TABLE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DROP destrutivo e DDL confirma transações; commits parciais e I/O. PCTUSED não governa ASSM; resultado depende de bloco/PCTFREE, não prova migração em qualquer ambiente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema descartável sem homônimos: revisar @chain1.sql.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tabela/view persistentes e dados atualizados; estatísticas coletadas.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  conforme descritos. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Vírgula indevida entre PCTFREE/PCTUSED removida; todo experimento preservado. 
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
/*  Create a table that will show row chaining and/or row migration.
**  Analyze the table to determine the chaining of the table.
*/
drop table chain1;

create table chain1
(col1 varchar2(255),
 col2 varchar2(255),
 col3 varchar2(255),
 col4 varchar2(255),
 col5 varchar2(255),
 col6 varchar2(255),
 col7 varchar2(255)
 )
 PCTFREE 10
 PCTUSED 40;
 declare ctr int := 0;
 begin
 while ctr < 1000
 loop
        insert into chain1 (col1) values (to_char(ctr));
        commit;
        ctr := ctr + 1;
 end loop;
 end;
/
declare
t varchar2(250) := '123456789012345';
ctr int := 0;
begin
while ctr < 4
loop
   t := t || t;
   ctr := ctr + 1;
end loop;
ctr := 0;
update chain1 set col2 = t, col3 = t, col4 = t, col5 = t,
  col6 = t, col7 = t;

end;
/
analyze table chain1 compute statistics;
drop view chain1_view;
create view chain1_view as select col1 from chain1;


