/*
===============================================================================
SCRIPT: extract_data_subset.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/extract_data_subset.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar SUBSETDATA para gerar CTAS de subconjunto seguindo dependências de FK.

FUNCIONAMENTO DETALHADO
  Recursão processa tabelas raiz e filhas, mantém lista done e emite CTAS ROWNUM percentual ou joins ao subset de pais; exemplo XGO ao final.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e permissões administrativas conforme limitações individuais. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES, DBA_CONSTRAINTS, DBA_CONS_COLUMNS, DBMS_OUTPUT; pacote SUBSETDATA

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não é amostragem aleatória nem anonimização. CTAS perde índices/constraints/grants e expõe dados se saída executada. Ciclos/self-FK/caminhos múltiplos/nullable FKs podem omitir ou repetir tabelas e recursão não garante término. Strings256 limitam SQL e nomes não são validados.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório com dados fictícios e schemas MOVIES/BERT do exemplo revisados.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  DDL textual CTAS em DBMS_OUTPUT; pacote é criado e XGO é chamado, mas CTAS não é executada.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos de criação, staging, autenticação, sessão
  ou código gerado descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Lista done reinicializada a cada XGO, evitando estado de chamada anterior; linhas ### de instrução convertidas em PROMPT. Recursão e geração completas preservadas. 
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

set linesize 200

set serveroutput on size 100000

 

create or replace package subsetdata

as

   procedure xgo (xsource varchar2, xtarget varchar2, xpercent integer);

end;

/

show error

create or replace package body subsetdata

as

  type tnames is table of varchar2(32);

   done_arr tnames := tnames();

   done_cnt integer := 0;

 

   procedure xsample (xsource varchar2, xtarget varchar2, current_table varchar2, xpercent integer)

  is

    s1    varchar2(256) := 'create table ' || xtarget || '.' || current_table || '

as

select * from ' || xsource || '.' ||current_table;

    s2    varchar2(256) := 'where rownum <= (select ceil(' || to_char(xpercent/100) || ' * count(*))

from ' || xsource || '.' || current_table || ');';

    s3    varchar2(256) := 'create table ' || xtarget || '.' || current_table || ' as

select T0.* from   ' || xsource || '.' || current_table || '  T0,';

    s4    varchar2(256) := 'where';

    cnt1 integer       := 0;

    cnt2 integer       := 0;

    i     integer       := 0;

    j    integer       := 0;

    es3  varchar2(1)   := '';

    es4  varchar2(4)   := '';

   begin

    i := 0;

    es3 := ',';

    select count(*)

    into cnt1

    from dba_constraints fk,

         dba_constraints pk

    where fk.constraint_type = 'R'

      and fk.owner = xsource

      and fk.R_owner = xsource

      and fk.table_name = current_table

      and pk.constraint_type in ('P','U')

      and pk.owner = xsource

      and pk.table_name != current_table

      and fk.r_constraint_name = pk.constraint_name;

    if (cnt1 = 0) then

      dbms_output.put_line(s1);

      dbms_output.put_line(s2);

    else

      for c1 in (select pk.table_name,

                        fk.constraint_name fk_name,

                        pk.constraint_name pk_name

                   from dba_constraints fk,

                        dba_constraints pk

                   where fk.constraint_type = 'R'

                     and fk.owner = xsource

                     and fk.R_owner = xsource

                     and fk.table_name = current_table

                     and pk.constraint_type in ('P','U')

                     and pk.owner = xsource

                     and pk.table_name != current_table

                     and fk.r_constraint_name = pk.constraint_name

                ) loop

          i := i + 1;

          if (i = cnt1) then

            es3 := '';

          end if;

          s3 := s3 || '

 ' || xtarget || '.' || c1.table_name || '  T' || to_char(i) || es3;

          j := 0;

          es4 := ' and';

          select count(*)

          into cnt2

          from dba_cons_columns fk,

               dba_cons_columns pk

          where fk.constraint_name = c1.fk_name

            and fk.owner = xsource

            and fk.table_name = current_table

            and pk.constraint_name = c1.pk_name

            and pk.owner = xsource

            and pk.table_name != current_table

            and fk.position = pk.position;

          for c2 in (select fk.column_name fk_col,

                            pk.column_name pk_col

                     from dba_cons_columns fk,

                          dba_cons_columns pk

                     where fk.constraint_name = c1.fk_name

                       and fk.owner = xsource

                       and fk.table_name = current_table

                       and pk.constraint_name = c1.pk_name

                       and pk.owner = xsource

                       and pk.table_name != current_table

                       and fk.position = pk.position

                       order by fk.position

                    ) loop

            j := j + 1;

            if (i = cnt1) and (j = cnt2) then

              es4 := ';';

            end if;

            s4 := s4 || '

 ' || 'T0.' || c2.fk_col || ' = T' || to_char(i) || '.' || c2.pk_col || es4;

          end loop;

        end loop;

      dbms_output.put_line(s3);

      dbms_output.put_line(s4);

    end if;

    done_arr.extend(1);

    done_cnt := done_cnt+1;

    done_arr(done_cnt) := current_table;

  end;

procedure xprocess (xsource varchar2, xtarget varchar2, current_table varchar2, xpercent integer)

  is

    i     integer := 1;

    flg  integer := 1;

    cnt1 integer := 0;

    cnt2 integer := 0;

   begin

    xsample (xsource, xtarget, current_table, xpercent);

    for c1 in (select fk.table_name

               from dba_constraints fk,

                    dba_constraints pk

               where fk.constraint_type = 'R'

                 and fk.owner = xsource

                 and fk.R_owner = xsource

                 and fk.table_name != current_table

                 and pk.constraint_type in ('P','U')

                 and pk.owner = xsource

                 and pk.table_name = current_table

                 and fk.r_constraint_name = pk.constraint_name

              ) loop

      select count(*)

      into cnt1

      from dba_constraints fk,

           dba_constraints pk

      where fk.constraint_type = 'R'

        and fk.owner = xsource

        and fk.R_owner = xsource

        and fk.table_name = c1.table_name

        and pk.constraint_type in ('P','U')

        and pk.owner = xsource

        and pk.table_name != current_table

        and fk.r_constraint_name = pk.constraint_name;

      if (cnt1 > 0) then

        cnt2 := 0;

        flg  := 0;

        for c2 in (select pk.table_name

                   from dba_constraints fk,

                        dba_constraints pk

                   where fk.constraint_type = 'R'

                     and fk.owner = xsource

                     and fk.R_owner = xsource

                     and fk.table_name = c1.table_name

                     and pk.constraint_type in ('P','U')

                     and pk.owner = xsource

                     and pk.table_name != current_table

                     and fk.r_constraint_name = pk.constraint_name

                  ) loop

          i := 1;

          while (i <= done_cnt) loop

            if (c2.table_name = done_arr(i)) then

              cnt2 := cnt2 + 1;

            end if;

            i := i + 1;

          end loop;

        end loop;

        if (cnt1 = cnt2) then

          flg := 1;

        end if;

      end if;

      if (flg = 1) then

        xprocess (xsource, xtarget, c1.table_name, xpercent);

      end if;

    end loop;

  end;

 

   procedure xgo (xsource varchar2, xtarget varchar2, xpercent integer)

  is

   begin
    done_arr:=tnames(); done_cnt:=0;

    for c1 in (select table_name

               from dba_tables tab

               where tab.owner = xsource

                 and NOT EXISTS (select 1

                                 from dba_constraints fk

                                 where fk.constraint_type = 'R'

                                   and fk.owner = xsource

                                   and fk.R_owner = xsource

                                   and fk.table_name = tab.table_name

                                )

              ) loop

      xprocess (xsource, xtarget, c1.table_name, xpercent);

    end loop;

  end;

end;

/

show error

 

prompt

prompt 

prompt    subsetdata.xgo(SOURCE_SCHEMA,TARGET_SCHEMA,PERCENTAGE)

prompt 

exec subsetdata.xgo('MOVIES','BERT',10)
