/*
===============================================================================
SCRIPT: db_df.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/db_df.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar view legada com defaults de storage e atributos de datafiles.

FUNCIONAMENTO DETALHADO
  Une TS$/FILE$/FILEXT$ e V$DBFILE, incluindo outer joins para extensões e nomes.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/execução e SELECT DIRETO conforme LIMITAÇÕES; roles
  podem não atender compilação de objetos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.TS$, SYS.FILE$, SYS.FILEXT$, V$DBFILE; view DBA_FILE_DATA

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE VIEW e SELECT direto interno. Estruturas antigas podem não existir/ter colunas compatíveis; unidades de extensão precisam de confirmação. Não é substituto homologado de DBA_DATA_FILES.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @db_df.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tablespace, defaults, datafile, tamanho em blocos e atributos internos de extensão.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cria/modifica objetos, dados, credenciais ou sessão
  conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Definição original preservada. 
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
create or replace view dba_file_data as
select
 a.name tablespace,a.dflminext min_extents, a.dflmaxext max_extents,
 a.dflinit init,a.dflincr next,a.dflextpct pct_increase, d.name 
 datafile,
 b.blocks datafile_size, c.maxextend max_extend, c.inc ext_incr
 from sys.ts$ a, sys.file$ b, sys.filext$ c, v$dbfile d
 where
 a.ts#=b.ts# and 
 b.file#=c.file#(+) and 
 b.file#=d.file#(+)
 /
