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
  Não são alternativas isoladas automaticamente: execução aplica três exemplos. Duplicações por SCRIPT_NAME podem gerar ORA-01427/30926; SELECT * exige colunas na mesma ordem. UPDATE sem match põe data NULL. Não homogenizar duplicatas arbitrariamente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

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
  Terminador ausente do UPDATE adicionado e NOT IN trocado por NOT EXISTS correlacionado para tratar NULL sem suprimir toda inserção. 
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
UPDATE other_scripts a
SET a.date_edited = (SELECT distinct b.date_edited FROM sql_scripts b
WHERE a.script_name = b.script_name);

INSERT INTO other_scripts a
SELECT * FROM sql_scripts b
WHERE not exists (select 1 from other_scripts c where c.script_name=b.script_name);

MERGE INTO other_scripts a
USING (SELECT * FROM sql_scripts) b
ON (a.script_name = b.script_name)
WHEN MATCHED THEN
UPDATE SET a.date_edited = b.date_edited
WHEN NOT MATCHED THEN
INSERT (a.permissions, a.filetype, a.owner, a.group_name,
a.size_in_bytes, a.date_edited,a.script_name )
VALUES (b.permissions, b.filetype, b.owner, b.group_name,
b.size_in_bytes, b.date_edited, b.script_name );
