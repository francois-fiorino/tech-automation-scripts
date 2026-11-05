/*
===============================================================================
SCRIPT: exp_ext_tab.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _index_scripts/exp_ext_tab.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar tabela externa por unload Data Pump de tabela interna.

FUNCIONAMENTO DETALHADO
  CTAS de tabela externa ORACLE_DATAPUMP descarrega sete colunas tipadas explicitamente em três arquivos de SQL_DIR.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/alteração/execução e SELECT DIRETO conforme LIMITAÇÕES.
  Grants por role podem não valer para views/procedimentos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SQL_SCRIPTS_INT, DIRECTORY SQL_DIR; nova SQL_SCRIPTS_EXT; ORACLE_DATAPUMP

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CTAS grava binário Data Pump no servidor, apesar da extensão .txt; não é CSV. Requer DIRECTORY SQL_DIR autorizado, READ/WRITE, espaço, quota, SELECT origem e tipos/conversões válidos. CASTs podem rejeitar/truncar conforme tipo; arquivos existentes e falha de unload exigem plano de limpeza. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório com diretório dedicado vazio: @exp_ext_tab.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tabela externa e arquivos de unload, se driver, esquema e diretório forem compatíveis.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PROPOSTA DE REVISÃO: o código pode modificar objetos, dados, jobs,
  arquivos ou sessão, conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 038 (2026-11-04): DEFAULT DIRECTORY substitui token DEFAULT_DIRECTORY inválido; CTAS deixa de declarar tipos no cabeçalho e os mantém por CAST explícito nas sete expressões, sem SELECT *. Driver Data Pump e três nomes de arquivo originais preservados. Casos de homologação: Origem com colunas em outra ordem/extras; tamanhos acima20/64; conversão de data/número; falta de grant/DIRECTORY; arquivo existente; roundtrip em clone; parallel e custo. Comentários/créditos históricos preservados. Não aprovado para implantação.

REFERÊNCIAS DA REVISÃO038
 https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/CREATE-TABLE.html
 https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/oracle_datapump-access-driver.html

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
CREATE TABLE sql_scripts_ext
 ORGANIZATION EXTERNAL
 (TYPE ORACLE_DATAPUMP
  DEFAULT DIRECTORY sql_dir
  LOCATION ('scripts1.txt','scripts2.txt','scripts3.txt'))
 PARALLEL
 AS SELECT CAST(permissions AS VARCHAR2(20)) permissions,
           CAST(filetype AS NUMBER(3)) filetype,
           CAST(owner AS VARCHAR2(20)) owner,
           CAST(group_name AS VARCHAR2(20)) group_name,
           CAST(size_in_bytes AS NUMBER) size_in_bytes,
           CAST(date_edited AS DATE) date_edited,
           CAST(script_name AS VARCHAR2(64)) script_name
 FROM sql_scripts_int;
