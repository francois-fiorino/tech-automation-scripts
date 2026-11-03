/*
===============================================================================
SCRIPT: size_est.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / misc_scripts/size_est.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Estimar bytes para cardinalidade informada usando ocupação de blocos de tabela exemplo.

FUNCIONAMENTO DETALHADO
  Conta linhas e blocos distintos por identidade de ROWID, multiplica por DB_BLOCK_SIZE e escala pela cardinalidade estimada.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$PARAMETER, DBMS_ROWID, tabela exemplo

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Varre tabela e pode ser caro. Estima blocos com linhas, não todos os extents/overhead/índices/LOBs. Bloco padrão pode diferir do tablespace. ROWID físico não suporta IOT/UROWID genericamente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @size_est.sql
  -- Informar estimativa inteira positiva, owner e tabela heap de laboratório.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  BYTES estimado; NULL para exemplo sem linhas.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Prefixo de ROWID incorreto substituído por OBJECT/RELATIVE_FNO/BLOCK_NUMBER completos; NULLIF protege exemplo com zero linhas. 
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
column dbbs new_value db_block_size noprint
column row_count new_value rc noprint;
select value dbbs from v$parameter where name = 'db_block_size';
accept est_row_count prompt 'Enter estimated number of rows for table: '
accept owner prompt 'Enter table owner name: '
accept table prompt 'Enter example table_name: '
set verify off feedback off
select count(*) row_count from &&owner..&&table;
SELECT (COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||':'||DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||':'||DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID))*&&db_block_size)/nullif(&&rc,0)*&&est_row_count bytes
       FROM &&owner..&&table
/
undef owner
undef table
