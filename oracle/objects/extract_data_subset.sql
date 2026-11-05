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
  Ainda não é amostragem aleatória/anonimização. Seleção de raízes pode omitir grafos sem raiz/ciclos e self-FKs; múltiplos pais, chaves NULL e preservação referencial exigem testes. CTAS gerado perde constraints/grants/índices e pode exceder32767 em schema amplo. Chamada exemplo MOVIES/BERT continua apenas gerando texto. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

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
  Revisão complementar 037 (2026-11-03): Retorno antecipado para tabela já emitida evita repetição/recursão cíclica no caminho alcançado; flag reiniciada por filho; nomes emitidos citados por ENQUOTE_NAME, buffers até32767 e percentual validado. Percentual emitido como inteiro/100, sem decimal NLS. Casos de homologação: Diamante; ciclo alcançável; grafo sem raiz; self-FK; múltiplas FKs; chaves compostas/NULL; nomes quoted; 0/100/fora da faixa; decimal NLS; texto longo; reexecução XGO. Comentários/créditos históricos preservados. Não aprovado para implantação.

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

  type tnames is table of varchar2(128);

   done_arr tnames := tnames();

   done_cnt integer := 0;

 

   procedure xsample (xsource varchar2, xtarget varchar2, current_table varchar2, xpercent integer)

  is

    s1    varchar2(32767) := 'create table ' || DBMS_ASSERT.ENQUOTE_NAME(xtarget,FALSE) || '.' || DBMS_ASSERT.ENQUOTE_NAME(current_table,FALSE) || '

as

select * from ' || DBMS_ASSERT.ENQUOTE_NAME(xsource,FALSE) || '.' || DBMS_ASSERT.ENQUOTE_NAME(current_table,FALSE);

    s2    varchar2(32767) := 'where rownum <= (select ceil(' || to_char(xpercent,'FM990')||'/100' || ' * count(*))

from ' || DBMS_ASSERT.ENQUOTE_NAME(xsource,FALSE) || '.' || DBMS_ASSERT.ENQUOTE_NAME(current_table,FALSE) || ');';

    s3    varchar2(32767) := 'create table ' || DBMS_ASSERT.ENQUOTE_NAME(xtarget,FALSE) || '.' || DBMS_ASSERT.ENQUOTE_NAME(current_table,FALSE) || ' as

select T0.* from   ' || DBMS_ASSERT.ENQUOTE_NAME(xsource,FALSE) || '.' || DBMS_ASSERT.ENQUOTE_NAME(current_table,FALSE) || '  T0,';

    s4    varchar2(32767) := 'where';

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

 ' || DBMS_ASSERT.ENQUOTE_NAME(xtarget,FALSE) || '.' || DBMS_ASSERT.ENQUOTE_NAME(c1.table_name,FALSE) || '  T' || to_char(i) || es3;

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

 ' || 'T0.' || DBMS_ASSERT.ENQUOTE_NAME(c2.fk_col,FALSE) || ' = T' || to_char(i) || '.' || DBMS_ASSERT.ENQUOTE_NAME(c2.pk_col,FALSE) || es4;

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
    for visited_idx in 1..done_cnt loop
     if done_arr(visited_idx)=current_table then return; end if;
    end loop;
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

      flg:=1;
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
    IF xpercent IS NULL OR xpercent<0 OR xpercent>100 OR xpercent<>TRUNC(xpercent) THEN RAISE_APPLICATION_ERROR(-20019,'Percentual inteiro deve estar entre 0 e 100.'); END IF;
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
