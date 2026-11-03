/*
===============================================================================
SCRIPT: upsert.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/upsert.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Demonstrar atualização/inserção separadas e MERGE entre tabelas de inventário.

FUNCIONAMENTO DETALHADO
  UPDATE por subconsulta, INSERT de nomes ausentes e MERGE com update/insert de sete campos; todos permanecem em sequência.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  OTHER_SCRIPTS, SQL_SCRIPTS (customizadas)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Os três exemplos continuam em sequência; não executar como alternativas independentes. Duplicatas na fonte podem causar ORA-01427/30926; UPDATE sem match continua atribuindo NULL por comportamento original. Chave NULL e concorrência não resolvidas; sem COMMIT explícito. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Somente tabelas descartáveis: revisar cada exemplo antes de executar arquivo inteiro.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Dados alterados sem COMMIT explícito.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 036 (2026-11-03): INSERT e origem MERGE usam a lista explícita dos sete campos já existentes no contrato MERGE; eliminada dependência de ordem/colunas extras de SELECT *. Demais filtros e sequência preservados. Casos de homologação: Colunas em ordem diferente e coluna extra; SCRIPT_NAME duplicado/NULL; target sem match; fonte vazia; reexecução e concorrência. Comentários/créditos históricos preservados. Não aprovado para implantação.

REFERÊNCIAS TÉCNICAS DA REVISÃO 036
 https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/INSERT.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/MERGE.html

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
UPDATE other_scripts a
SET a.date_edited = (SELECT distinct b.date_edited FROM sql_scripts b
WHERE a.script_name = b.script_name);

INSERT INTO other_scripts
 (permissions,filetype,owner,group_name,size_in_bytes,date_edited,script_name)
SELECT b.permissions,b.filetype,b.owner,b.group_name,b.size_in_bytes,b.date_edited,b.script_name FROM sql_scripts b
WHERE not exists (select 1 from other_scripts c where c.script_name=b.script_name);

MERGE INTO other_scripts a
USING (SELECT permissions,filetype,owner,group_name,size_in_bytes,date_edited,script_name FROM sql_scripts) b
ON (a.script_name = b.script_name)
WHEN MATCHED THEN
UPDATE SET a.date_edited = b.date_edited
WHEN NOT MATCHED THEN
INSERT (a.permissions, a.filetype, a.owner, a.group_name,
a.size_in_bytes, a.date_edited,a.script_name )
VALUES (b.permissions, b.filetype, b.owner, b.group_name,
b.size_in_bytes, b.date_edited, b.script_name );
