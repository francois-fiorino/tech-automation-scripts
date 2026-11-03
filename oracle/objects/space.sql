/*
===============================================================================
SCRIPT: space.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/SPACE.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar procedimento de relatório de espaço livre por datafile.

FUNCIONAMENTO DETALHADO
  Cursores agrupam FREE_SPACE por arquivo e consultam DATAFILE; imprime bytes totais/livres/máximo e percentual.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_FREE_SPACE, V$DATAFILE, V$DATABASE, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE e SELECT diretos. Arquivos sem linha livre são omitidos, logo não mostra datafiles totalmente ocupados. Não considera autoextend potencial nem tempfiles.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @space.sql; executar rotina depois de grants diretos.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Procedimento criado; chamada imprime relatório de KiB/percentual.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF protege tamanho de arquivo zero; nome de banco ampliado para 128 em buffer. 
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
create or replace procedure space as
 CURSOR datafile1 IS
  SELECT tablespace_name, file_id, max(bytes) largeextent,
    sum(bytes) totalfreespace
    FROM sys.dba_free_space
    GROUP BY tablespace_name, file_id
    ORDER BY tablespace_name, file_id;
 CURSOR datafile2 (fileid INTEGER) IS
  SELECT name, bytes
    FROM v$datafile
    WHERE file# = fileid;
dbname VARCHAR2(128);
BEGIN
SELECT name INTO dbname
  FROM v$database;
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Space Report for Database '||dbname);
DBMS_OUTPUT.PUT_LINE('-----------------------------------');
DBMS_OUTPUT.PUT_LINE('');
FOR file IN datafile1 LOOP
  DBMS_OUTPUT.PUT_LINE('Tablespace Name:           '
  ||file.tablespace_name);
--DBMS output...Name:'|file...         < commented out.  didn't pass syntax check.
  DBMS_OUTPUT.PUT_LINE('');
  FOR filedata IN datafile2 (file.file_id) LOOP
    DBMS_OUTPUT.PUT_LINE('Data File Name:              '
      ||filedata.name);
    DBMS_OUTPUT.PUT_LINE('Total File Size (KB):        '
      ||ROUND(filedata.bytes/1024,0));
    DBMS_OUTPUT.PUT_LINE('Free Space in File (KB):     '
      ||ROUND(file.totalfreespace/1024,0));
    DBMS_OUTPUT.PUT_LINE('% Free Space in File:        '
      ||ROUND(((file.totalfreespace/nullif(filedata.bytes,0))*100),0)||'%');
    DBMS_OUTPUT.PUT_LINE('Largest Extent (KB):      '
      ||ROUND(file.largeextent/1024,0));
    DBMS_OUTPUT.PUT_LINE('');
  END LOOP;
END LOOP;
END;
/
