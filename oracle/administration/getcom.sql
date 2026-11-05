/*
===============================================================================
SCRIPT: getcom.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/GETCOM.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar e executar chamadas TABLE_HELP para tabelas com comentários de colunas.

FUNCIONAMENTO DETALHADO
  Spool DO_TABHP.SQL com EXECUTE TABLE_HELP; abre COMMENTS.LIS, START executa e HOST DEL remove intermediário.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/execução e SELECT DIRETO conforme LIMITAÇÕES; roles
  podem não atender compilação de objetos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_COL_COMMENTS, TABLE_HELP, SQL*Plus HOST/START

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE não ocorre aqui, mas há execução de procedimento customizado e comando de SO. Nomes não escapados, conteúdo/efeitos de TABLE_HELP e caminho local exigem revisão. Só tabelas com comentário de coluna entram.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório Windows com TABLE_HELP revisado: DEFINE OWNER = HR
  @getcom.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Relatório de comentários e arquivo temporário gerado/deletado.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cria/modifica objetos, dados, credenciais ou sessão
  conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código preservado, incluindo execução/remoção; não rotulado como somente leitura garantida. 
  Revisão estática somente; implantação depende de laboratório e aprovação do PR.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 041 — 04/11/2026
  Correções e melhorias: Apóstrofos de owner/tabela escapados nas chamadas geradas; DEFINE OFF no arquivo antes do START.
  Limitações e pendências: Macro OWNER da consulta original continua aceitando somente entrada confiável. TABLE_HELP usa UPPER e não resolve quoted mixed case; DBMS_OUTPUT4000 e paths/DEL Windows limitam saída.
  Homologação necessária: Nomes com apóstrofo/ampersand, duas tabelas e comentários longos; revisar helper e arquivo antes de START.
  Parâmetros e execução: contratos acima e no corpo; só ambiente controlado.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e comparação estática; sem compilação/execução
  Oracle, Windows, alteração de privilégio ou gravação de arquivo no servidor.

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
rem
rem FUNCTION: Get all of a tables comments
rem
set heading off pages 0 verify off feedback off termout off
spool do_tabhp.sql
select 'set define off' from dual; 
select
 unique 'execute table_help('||''''||replace(owner,chr(39),chr(39)||chr(39))||''''||','||''''||replace(table_name,chr(39),chr(39)||chr(39))||''''||');'
 from dba_col_comments where owner='&OWNER' and length(comments)>0;
spool off
set echo off lines 132
set serveroutput on size 4000
spool comments.lis 
start do_tabhp.sql
spool off
host del do_tabhp.sql
set heading on pages 22 verify on feedback on termout on lines 80


