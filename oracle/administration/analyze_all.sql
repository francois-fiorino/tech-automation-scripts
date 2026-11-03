/*
===============================================================================
SCRIPT: analyze_all.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/analyze_all.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar e executar ANALYZE_SCHEMA para owners com tabelas fora SYS/SYSTEM.

FUNCIONAMENTO DETALHADO
  Spool de EXECUTE DBMS_UTILITY.ANALYZE_SCHEMA com método/amostra; START executa gerado e captura log.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_TABLES, DBMS_UTILITY.ANALYZE_SCHEMA

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Privilégios administrativos/EXECUTE conforme versão. ANALYZE legado para optimizer stats não substitui DBMS_STATS moderno, mas não foi reescrito removendo semântica. Sem filtro fino de aplicação; pode consumir I/O/CPU e mudar planos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schemas descartáveis: revisar variáveis METHOD/NUM_OF_ROWS/PERCENT_TO_USE.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Arquivo ANALZ_SCH.SQL e log; estatísticas dos schemas podem ser alteradas.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  conforme descritos. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Gerador e execução automática preservados com riscos e necessidade de revisão prévia explícitos. 
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
set heading off verify off pages 0 feedback off
ttitle off
spool analz_sch.sql
select distinct 'execute dbms_utility.analyze_schema('||chr(39)||
owner||chr(39)||','||chr(39)||'&METHOD'||chr(39)||','||&NUM_OF_ROWS||',&PERCENT_TO_USE);'
from dba_tables where owner not in ('SYS','SYSTEM')
/
spool off
spool analz_sch.log
set echo on
start analz_sch.sql
set echo off
spool off
