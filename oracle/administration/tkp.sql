/*
===============================================================================
SCRIPT: tkp.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/tkp.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Recriar tabela de exemplo TKP_EXAMPLE2 com metadados de objetos e segmentos.

FUNCIONAMENTO DETALHADO
  DROP TABLE seguido de CTAS relacionando DBA_OBJECTS/DBA_SEGMENTS por owner e nome.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/alteração/execução e SELECT DIRETO conforme LIMITAÇÕES.
  Grants por role podem não valer para views/procedimentos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_OBJECTS, DBA_SEGMENTS; TKP_EXAMPLE2

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Destrói tabela homônima e faz commits de DDL. Join por nome pode multiplicar linhas de partições; não é inventário único por objeto. Exige CREATE TABLE/quota e leitura direta.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema descartável: @tkp.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tabela criada e populada com owner/nome/tipo/tablespace.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PROPOSTA DE REVISÃO: o código pode modificar objetos, dados, jobs,
  arquivos ou sessão, conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  DDL original preservada sem execução; nome fixo destacado. 
  Revisão estática somente; implantação depende de testes e aprovação do PR.
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
drop table tkp_example2
/
create table tkp_example2 as
select a.owner, a.object_name, a.object_type, b.tablespace_name
from dba_objects a, dba_segments b
where
b.owner(+)=a.owner and
b.segment_name(+)=a.object_name
/
