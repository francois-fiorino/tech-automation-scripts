/*
===============================================================================
SCRIPT: create_block_views.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/create_block_views.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Recriar views históricas de estado de buffers e conceder leitura.

FUNCIONAMENTO DETALHADO
  DROP/CREATE BLOCK_STATUS e BUFFER_STATUS sobre X$BH; GRANT a DBAUTIL.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants diretos nas estruturas internas e privilégios de criação apropriados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  X$BH, views BLOCK_STATUS/BUFFER_STATUS, usuário DBAUTIL

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  DDL substitui objetos e confirma transação. SELECT direto interno/CREATE VIEW e GRANT necessários; flags e LRBA_SEQ/DIRTY_QUEUE são dependentes de versão. Varredura posterior pode ser cara. DBAUTIL precisa avaliação de acesso.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório com catálogo compatível: revisar @create_block_views.sql.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Views com contagens por estado/classe e flags dirty.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados ou sessão descritos
  acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Estrutura e grants preservados, sem afirmar compatibilidade moderna dos flags. 
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
drop view block_status;
CREATE VIEW BLOCK_STATUS AS
     SELECT DECODE(state, 0, 'FREE',
            1, DECODE(lrba_seq,0, 'AVAILABLE', 'BEING USED'),
            3, 'BEING USED', state) "BLOCK STATUS", 
            COUNT(*) "COUNT" 
      FROM x$bh
      GROUP BY  
      decode(state,0,'FREE',1,decode(lrba_seq,0,'AVAILABLE',     
          'BEING USED'),3,'BEING USED',state)
/
grant select on block_status to dbautil;
drop view buffer_status;
create view buffer_status as 
select decode(greatest(class,10),10,decode(class,1,'Data',2,'Sort',4,'Header',
   to_char(class)),'Rollback') "Class",
   sum(decode(bitand(flag,1),1,0,1)) "Not Dirty",
   sum(decode(bitand(flag,1),1,1,0)) "Dirty",
   sum(dirty_queue) "On Dirty",count(*) "Total"
  from x$bh
  group by decode(greatest(class,10),10,decode(class,1,'Data',
                                          2,'Sort',
                                          4,'Header',
                                          to_char(class)),'Rollback')
/
grant select on buffer_status to dbautil;
