/*
===============================================================================
SCRIPT: ext_file.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _table_scripts/ext_file.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar tabela externa para ler listagem de arquivo em posições fixas.

FUNCIONAMENTO DETALHADO
  CREATE TABLE SQL_SCRIPTS com ORACLE_LOADER, DIRECTORY EXT_FILE_DIR e campos posicionais de FILE.LIS; desabilita log/bad/discard files.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/execução e SELECT DIRETO conforme LIMITAÇÕES; roles
  podem não atender compilação de objetos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DIRECTORY EXT_FILE_DIR, arquivo FILE.LIS; tabela SQL_SCRIPTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE TABLE e READ no DIRECTORY; formato da data e posições dependem do arquivo. Não é uma tabela de dados internos e não valida que caminhos/permissões do SO existam. DDL persistente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório com arquivo de exemplo compatível: @ext_file.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tabela externa criada; leitura posterior converte data/tamanho/nome conforme posições.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cria/modifica objetos, dados, credenciais ou sessão
  conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Definição original preservada; precisa homologar máscara/data e acesso ao arquivo. 
  Revisão estática somente; implantação depende de laboratório e aprovação do PR.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 040 — 04/11/2026
  Correções e melhorias: Definição externa preservada.
  Limitações e pendências: Sem DATE_FORMAT explícito, conversão de FILE_DATE depende do conteúdo/NLS. Campos posicionais e nome 32 limitam entrada; sem bad/log dificulta diagnosticar rejeição. DIRECTORY é no servidor.
  Homologação necessária: Arquivo sintético com datas/nomes/tamanhos inválidos; validar posições, charset, rejeições e READ no DIRECTORY.
  Parâmetros e execução: contrato detalhado acima e no corpo; somente laboratório.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  sem Windows, exportação, job ou comando administrativo executado.

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
CREATE TABLE sql_scripts (file_date date, 
                          file_length int, 
                          file_name varchar2(32))
   ORGANIZATION EXTERNAL
  (TYPE ORACLE_LOADER
  DEFAULT DIRECTORY ext_file_dir
  ACCESS PARAMETERS  
  (records delimited by newline nologfile nodiscardfile nobadfile FIELDS
   (file_date   POSITION (1:16)  char,
    file_length POSITION (30:37) unsigned integer external,
    file_name   POSITION (39:67) char))
  LOCATION ('file.lis'))
/
