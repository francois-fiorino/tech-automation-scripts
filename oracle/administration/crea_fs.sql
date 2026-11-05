/*
===============================================================================
SCRIPT: crea_fs.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/crea_fs.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar ou substituir FREE_SPACE incluindo índice heurístico FSFI.

FUNCIONAMENTO DETALHADO
  Agrega DBA_FREE_SPACE por arquivo e calcula FSFI com maior extent, soma de blocos e número de peças.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/execução e SELECT DIRETO conforme LIMITAÇÕES; roles
  podem não atender compilação de objetos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_FREE_SPACE; view FREE_SPACE de oito colunas

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE VIEW e SELECT direto. Substitui variante VIEW.SQL de sete colunas e pode invalidar dependências. FSFI não demonstra custo de performance em LMT; não inclui tablespaces/arquivos sem extents livres.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @crea_fs.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  View com estatísticas livres e FSFI.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cria/modifica objetos, dados, credenciais ou sessão
  conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Fórmula e estrutura completas preservadas. 
  Revisão estática somente; implantação depende de laboratório e aprovação do PR.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 042 — 04/11/2026
  Correções e melhorias: View oito colunas e FSFI preservados.
  Limitações e pendências: Substitui FREE_SPACE de sete colunas e pode invalidar dependências. Sem extents livres, arquivo não aparece; FSFI não demonstra ganho operacional nem mede adjacência física.
  Homologação necessária: Um/vários extents e arquivo cheio; comparar fórmula e contratos em schemas separados.
  Parâmetros e execução: contratos descritos acima e no corpo histórico.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  backup/recovery, comandos Windows/Unix ou uso de credenciais reais.

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
REM  You must have direct select grants on the undelying tables
REM  for these views to be generated.

create or replace  view free_space (
	tablespace, 
	file_id, 
	pieces, 
	free_bytes, 
	free_blocks, 
	largest_bytes,
	largest_blks,
	fsfi) 
as
select 
	tablespace_name, 
	file_id, 
	count(*),
	sum(bytes), 
	sum(blocks),
	max(bytes), 
	max(blocks),
	sqrt(max(blocks)/sum(blocks))*(100/sqrt(sqrt(count(blocks)))) 
from 
	sys.dba_free_space
group by 
	tablespace_name, 
	file_id;

