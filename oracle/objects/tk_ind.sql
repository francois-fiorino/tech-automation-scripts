/*
===============================================================================
SCRIPT: tk_ind.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/tk_ind.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar seis índices únicos ilustrativos com ordens distintas de colunas.

FUNCIONAMENTO DETALHADO
  CREATE UNIQUE INDEX em TKP_EXAMPLE e TKP_EXAMPLE2 no tablespace CNET_INDEXES.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  TKP_EXAMPLE, TKP_EXAMPLE2, CNET_INDEXES; seis índices literais

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE INDEX/quota; operações podem bloquear e consumir TEMP/I/O/CPU. Ordem de colunas afeta acesso; várias chaves semelhantes não são recomendação de indexação. Criação pode ter sucesso parcial.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente tabelas de laboratório sem índices homônimos: revisar arquivo.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Índices criados se dados satisfazem unicidade e há espaço.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  conforme descritos. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Todas as seis definições e ordens de colunas preservadas. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 044 — 04/11/2026
  Correções e melhorias: Seis índices únicos e ordem das colunas preservados.
  Limitações e pendências: Índices parecidos não são recomendação universal; duplicatas nas chaves podem falhar e criação é parcial. CNET_INDEXES e TKP_EXAMPLE faltantes dependem do laboratório.
  Homologação necessária: Tabelas fictícias, cardinalidade/NULL/unicidade e espaço de seis índices; não aplicar em aplicação.
  Parâmetros/execução: contratos descritos acima e no corpo; somente laboratório.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  submissão de jobs, backup/recovery, Shell/Windows/VMS ou coleta de credenciais.

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


create unique index tkp_exp_index
on tkp_example(
username,
default_tablespace,
temporary_tablespace) tablespace cnet_indexes;

create unique index tkp_exp_index2
on tkp_example(
temporary_tablespace,
username,
default_tablespace) tablespace cnet_indexes;

create unique index tkp_exp_index3
on tkp_example(
default_tablespace,
temporary_tablespace,
username) tablespace cnet_indexes;

create unique index tkp_exp2_index2 on
tkp_example2(
owner,
tablespace_name,
object_name,
object_type) tablespace cnet_indexes;


 create unique index tkp_exp2_index on
tkp_example2(
 owner,
object_name,
object_type) tablespace cnet_indexes;

create unique index tkp_exp2_index3 on
tkp_example2(
tablespace_name,
owner,
object_name,
object_type) tablespace cnet_indexes;
