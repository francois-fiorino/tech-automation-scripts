/*
===============================================================================
SCRIPT: remove_logfiles.sql
CATEGORIA: Oracle / backup-recovery
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/remove_logfiles.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar rotina que remove arquivos da lista de LogMiner, sem apagar redo no SO.

FUNCIONAMENTO DETALHADO
  Lê lista com UTL_FILE, constrói caminhos Windows e chama ADD_LOGFILE com REMOVEFILE via DBMS_SQL.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme LIMITAÇÕES; roles não
  bastam para compilar dependências de rotinas armazenadas. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  UTL_FILE, DBMS_LOGMNR, DBMS_SQL, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não exclui arquivo físico. Privilégios CREATE PROCEDURE/EXECUTE e acesso DIRECTORY ou UTL_FILE_DIR histórico; versão/contexto de LogMiner precisam validação. Concatena conteúdo sem escaping; WHEN OTHERS silencia falhas e pode vazar cursor.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente revisão em laboratório sem sessão LogMiner de trabalho.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Procedimento criado; chamada modifica lista da sessão LogMiner e imprime SQL.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados ou sessão descritos
  acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código mantido: tratamento de erros, separador de caminho e segurança de nome exigem homologação antes de implantação. 
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
CREATE  OR REPLACE PROCEDURE remove_logfiles(
                                        logfile_dir in  VARCHAR2, 
                                        logfile_lis in  VARCHAR2) 
AS
 cur        INTEGER;
 sql_com    VARCHAR2(2000);
 file_full_name VARCHAR2(255);
 file_proc  INTEGER;
 file_hand  utl_file.file_type;
 file_buff  VARCHAR2(1022);
 file_type  VARCHAR2(4);
 ctr NUMBER:=0;
BEGIN
 file_hand:=utl_file.fopen(logfile_dir,logfile_lis,'R');
 LOOP
   ctr:=ctr+1;
   BEGIN
   utl_file.get_line(file_hand,file_buff);
   cur:=dbms_sql.open_cursor;
   file_full_name:=logfile_dir||'\'||file_buff;
   sql_com:='begin dbms_logmnr.add_logfile(LogFileName => '||chr(39)||file_full_name||chr(39)|| 
   ',Options => dbms_logmnr.removefile); end;';
   dbms_output.put_line(sql_com);
   dbms_sql.parse(cur,sql_com,dbms_sql.v7);
   file_proc:=dbms_sql.execute(cur);
   dbms_sql.close_cursor(cur);
   EXCEPTION
    WHEN no_data_found THEN
   EXIT;
    WHEN others THEN
   EXIT;
   END;
 END LOOP;
 utl_file.fclose(file_hand);
END;
/
