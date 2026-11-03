/*
===============================================================================
SCRIPT: chained.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _table_scripts/chained.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar e popular tabela de laboratório para explorar encadeamento/migração de linhas.

FUNCIONAMENTO DETALHADO
  DROP/CREATE CHAINED com sete colunas, PCTFREE/PCTUSED; insere mil linhas em COL1 com COMMIT por linha e EXIT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/execução e SELECT DIRETO conforme LIMITAÇÕES; roles
  podem não atender compilação de objetos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  Tabela CHAINED, DUAL implícita de conversão; SQL*Plus EXIT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DROP destrutivo, muitos commits e DDL persistente. Só preencher COL1 não comprova migração; PCTUSED não governa ASSM. EXIT pode confirmar transação. Não rodar em produção.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema descartável sem dados homônimos: @chained.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tabela e mil linhas confirmadas; sessão encerrada.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cria/modifica objetos, dados, credenciais ou sessão
  conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código integral preservado; não executado. 
  Revisão estática somente; implantação depende de laboratório e aprovação do PR.
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
drop table chained;

create table chained
(col1 varchar2(255),
 col2 varchar2(255),
 col3 varchar2(255),
 col4 varchar2(255),
 col5 varchar2(255),
 col6 varchar2(255),
 col7 varchar2(255)
 )
 PCTFREE 80,
 PCTUSED 20;
 declare ctr int := 0;
 begin
 while ctr < 1000
 loop
        insert into chained (col1) values (to_char(ctr));
        commit;
        ctr := ctr + 1;
 end loop;
 end;
/
exit

