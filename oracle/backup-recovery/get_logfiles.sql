/*
===============================================================================
SCRIPT: get_logfiles.sql
CATEGORIA: Oracle / backup-recovery
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/get_logfiles.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar carregador de lista de arquivos redo no contexto de LogMiner.

FUNCIONAMENTO DETALHADO
  Lê lista por UTL_FILE; resolve base física via ALL_DIRECTORIES ou parâmetro; chama DBMS_LOGMNR.ADD_LOGFILE diretamente e propaga erros com cleanup.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme limitações de cada arquivo. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  UTL_FILE, ALL_DIRECTORIES, DBMS_LOGMNR; sem DBMS_SQL ou SQL concatenado.

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Alvo modernizado usa DIRECTORY Oracle e READ no objeto, acesso SO, SELECT em ALL_DIRECTORIES e EXECUTE/autorizações LogMiner do invocador. Nome de DIRECTORY é normalizado para uppercase. Caminhos absolutos na lista são respeitados; relativos usam base física. Linhas vazias são ignoradas. Primeiro arquivo não vazio usa NEW e substitui lista LogMiner anterior; seguintes usam ADDFILE. Falha após várias chamadas deixa alterações parciais na lista; não existe rollback automático. Não inicia mining. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Somente revisão e lista fictícia em laboratório.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Procedimento criado; chamada define/substitui lista de redo da sessão LogMiner.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  conforme descritos. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 036 (2026-11-03): Chamadas diretas ADD_LOGFILE substituem PL/SQL concatenado; AUTHID CURRENT_USER; EOF tratado só no GET_LINE; erros propagados com fechamento do arquivo. DIRECTORY lógico separado de caminho físico; terceiro parâmetro opcional de base preserva chamadas com dois argumentos. Casos de homologação: Lista vazia; linha em branco; caminho Unix, Windows e UNC; base com/sem separador; apóstrofo no nome; erro no segundo arquivo; DIRECTORY sem READ; EOF versus erro LogMiner. Comentários/créditos históricos preservados. Não aprovado para implantação.

REFERÊNCIAS TÉCNICAS DA REVISÃO 036
 https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_LOGMNR.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/UTL_FILE.html

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
CREATE OR REPLACE PROCEDURE get_logfiles(
 logfile_dir IN VARCHAR2,logfile_lis IN VARCHAR2,redo_base_path IN VARCHAR2 DEFAULT NULL)
AUTHID CURRENT_USER
AS
 file_hand UTL_FILE.FILE_TYPE;
 file_buff VARCHAR2(32767);
 file_full_name VARCHAR2(32767);
 base_path VARCHAR2(32767);
 separator VARCHAR2(1);
 l_directory_name ALL_DIRECTORIES.DIRECTORY_NAME%TYPE;
 ctr PLS_INTEGER:=0;
BEGIN
 l_directory_name:=UPPER(logfile_dir);
 IF redo_base_path IS NULL THEN
  SELECT directory_path INTO base_path FROM all_directories WHERE directory_name=l_directory_name;
 ELSE
  base_path:=redo_base_path;
 END IF;
 IF base_path IS NULL THEN RAISE_APPLICATION_ERROR(-20015,'Diretorio base ausente.'); END IF;
 separator:=CASE WHEN INSTR(base_path,CHR(92))>0 AND INSTR(base_path,'/')=0 THEN CHR(92) ELSE '/' END;
 file_hand:=UTL_FILE.FOPEN(l_directory_name,logfile_lis,'R',32767);
 LOOP
  BEGIN
   UTL_FILE.GET_LINE(file_hand,file_buff);
  EXCEPTION WHEN NO_DATA_FOUND THEN EXIT;
  END;
  IF TRIM(file_buff) IS NOT NULL THEN
   IF INSTR(file_buff,CHR(0))>0 OR INSTR(file_buff,CHR(13))>0 THEN
    RAISE_APPLICATION_ERROR(-20016,'Nome de arquivo contem caractere de controle.');
   END IF;
   IF SUBSTR(file_buff,1,1)='/' OR SUBSTR(file_buff,1,2)=CHR(92)||CHR(92)
      OR (LENGTH(file_buff)>=3 AND SUBSTR(file_buff,2,1)=':' AND SUBSTR(file_buff,3,1) IN ('/',CHR(92))) THEN
    file_full_name:=file_buff;
   ELSE
    file_full_name:=base_path||CASE WHEN SUBSTR(base_path,-1) IN ('/',CHR(92)) THEN NULL ELSE separator END||file_buff;
   END IF;
   DBMS_LOGMNR.ADD_LOGFILE(LogFileName=>file_full_name,Options=>CASE WHEN ctr=0 THEN DBMS_LOGMNR.NEW ELSE DBMS_LOGMNR.ADDFILE END);
   ctr:=ctr+1;
   DBMS_OUTPUT.PUT_LINE('ADDED: '||file_full_name);
  END IF;
 END LOOP;
 UTL_FILE.FCLOSE(file_hand);
EXCEPTION WHEN OTHERS THEN
 BEGIN
  IF UTL_FILE.IS_OPEN(file_hand) THEN UTL_FILE.FCLOSE(file_hand); END IF;
 EXCEPTION WHEN OTHERS THEN NULL;
 END;
 RAISE;
END;
/
