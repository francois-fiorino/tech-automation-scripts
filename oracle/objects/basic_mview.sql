/*
===============================================================================
SCRIPT: basic_mview.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/basic_mview.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar rascunho histórico de CREATE de materialized views do catálogo.

FUNCIONAMENTO DETALHADO
  DBMS_METADATA retorna DDL CLOB de cada materialized view visível no catálogo; o cliente grava basic_mviews_generated.sql sem executar seu conteúdo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_MVIEWS, DBMS_METADATA.GET_DDL e SET_TRANSFORM_PARAM.

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  GET_DDL exige EXECUTE DBMS_METADATA e visibilidade de metadados (próprios ou SELECT_CATALOG_ROLE autorizado). Não inclui dependentes/grants completos nem dados; não é backup. Limite LONG de saída é 1000000; conferir truncamento. Transformação de sessão é restaurada ao default, não ao valor customizado anterior; usar cliente dedicado. Saída não é executada. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Somente revisão do gerador; não executar a saída como recuperação.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  DDL de criação por materialized view, sujeito ao limite LONG de exibição do cliente e aos privilégios de metadados.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  conforme descritos. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 036 (2026-11-03): Gerador substitui concatenação inválida de LONG por CLOB de DBMS_METADATA.GET_DDL; SQLTERMINATOR habilitado; spool local e ordenado. Não emite CREATE OR REPLACE MATERIALIZED VIEW. Casos de homologação: MView com QUERY >10k; refresh/storage/quoted; usuário sem acesso a outro schema; saída >1MB; spool indisponível; comparar DDL com catálogo. Comentários/créditos históricos preservados. Não aprovado para implantação.

REFERÊNCIAS TÉCNICAS DA REVISÃO 036
 https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_METADATA.html

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
-- comment: generate mview create syntax

set define off
set long 1000000
set longchunksize 32767
set linesize 32767
set heading off pagesize 0 feedback off verify off
begin
 DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',TRUE);
end;
/
spool basic_mviews_generated.sql
select DBMS_METADATA.GET_DDL('MATERIALIZED_VIEW',mview_name,owner)
from dba_mviews
order by owner,mview_name;
spool off
begin
 DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'DEFAULT');
end;
/
set heading on feedback on
