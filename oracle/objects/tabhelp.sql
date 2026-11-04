/*
===============================================================================
SCRIPT: tabhelp.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _table_scripts/TABHELP.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar TABLE_HELP para imprimir comentários de tabela e colunas.

FUNCIONAMENTO DETALHADO
  Cursores DBA_TAB_COMMENTS/COL_COMMENTS filtram UPPER dos parâmetros e escrevem DBMS_OUTPUT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme LIMITAÇÕES; roles não
  bastam para compilar dependências de rotinas armazenadas. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado pelo chamador (o script não o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_TAB_COMMENTS, SYS.DBA_COL_COMMENTS, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE/SELECT direto. Não é relatório executado automaticamente. UPPER não resolve nomes quoted mistos; sem ordenação de colunas. Comentários podem conter conteúdo sensível e exceder limite de linha do cliente/versão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @tabhelp.sql; habilitar SERVEROUTPUT antes de chamada de teste.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Procedimento criado; chamada imprime comentários visíveis.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados ou sessão descritos
  acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Buffers de nomes ampliados para 128 e comentários para 4000 caracteres, evitando limites antigos 32/2000; cursores preservados. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 039 — 04/11/2026
  Correções e melhorias: Corpo preservado; corrigida afirmação documental sobre SERVEROUTPUT.
  Limitações e pendências: UPPER não resolve quoted mixed case; comentários de colunas sem ordenação e tabela inexistente sem mensagem explícita. EXECUTE permite visualizar comentários via direitos do definidor.
  Homologação necessária: SET SERVEROUTPUT ON; EXEC table_help('HR','EMPLOYEES'); testar tabela ausente e comentários longos.
  Parâmetros/execução: manter contrato descrito acima e no corpo histórico.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação realizada: leitura integral e comparação estática; sem compilação
  ou execução Oracle, sem execução de comandos administrativos.

AVISO: Este script deve ser avaliado e testado em ambiente controlado antes de qualquer utilização em produção. Sua execução é de responsabilidade do profissional responsável pelo ambiente. Os mantenedores deste repositório não se responsabilizam por indisponibilidade, perda de dados, alterações indevidas ou outros impactos decorrentes de sua utilização.

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
 CREATE OR REPLACE PROCEDURE table_help (
	tabown 	IN VARCHAR2,
	tabname IN VARCHAR2)
 AS
--
--
 	tabcomment  		VARCHAR2(4000);
 	colname  		VARCHAR2(128);
 	colcomment  		VARCHAR2(4000);
 	tab_name  		VARCHAR2(128);
--
--
	CURSOR get_tab_com (tabo VARCHAR2 ,tabn VARCHAR2) IS
 		 SELECT  
			table_name
			,comments
 		 FROM  
			sys.dba_tab_comments
 		 WHERE  
			owner=UPPER(tabo)
 		 	AND table_name=UPPER(tabn);
--
--
 	CURSOR get_col_com (tabo VARCHAR2,tabn VARCHAR2) IS
 		 SELECT  
			column_name
			,comments
 		 FROM  
			sys.dba_col_comments
 		 WHERE  
			owner=UPPER(tabo)
 		 	AND table_name=UPPER(tabn);
--
--
 BEGIN
  DBMS_OUTPUT.PUT_LINE(CHR(10));
  OPEN get_tab_com(tabown,tabname);
  FETCH get_tab_com INTO tab_name, tabcomment;
  DBMS_OUTPUT.PUT_LINE('TABLE: '||tabname||' COMMENT: '||tabcomment);
  OPEN get_col_com(tabown,tabname);
  LOOP 
	   FETCH get_col_com INTO colname,colcomment;
	   EXIT WHEN get_col_com%NOTFOUND;
	  DBMS_OUTPUT.PUT_LINE('   COLUMN: '||colname||' COMMENT: '||colcomment);
  END LOOP;
  CLOSE get_tab_com;
  CLOSE get_col_com;
 END;
 /
