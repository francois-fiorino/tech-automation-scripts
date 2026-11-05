/*
===============================================================================
SCRIPT: count_blocks.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/count_blocks.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Gerar e executar INSERTs de contagem de blocos estimada para tabelas de schemas selecionados.

FUNCIONAMENTO DETALHADO
  Gera INSERT SELECT COUNT DISTINCT por tabela heap da lista de segmentos, com identidade ROWID completa, e executa o arquivo gerado como no fluxo original.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/alteração/execução e SELECT DIRETO conforme LIMITAÇÕES.
  Grants por role podem não valer para views/procedimentos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_SEGMENTS, DBMS_ROWID, tabelas selecionadas, TEMP_SIZE_TABLE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Continua full scan/DML automático ao executar o script. Contabiliza blocos com linhas, não HWM ou blocos alocados. Sem owner no staging, homônimos são indistinguíveis; reexecução duplica dados. TABLE não cobre partições/IOT/UROWID; contexto de BIGFILE exige laboratório. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Não executar em produção; laboratório com cópia dos dados e staging validado.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Linhas inseridas na tabela customizada; arquivo SQL gerado no cliente.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PROPOSTA DE REVISÃO: o código pode modificar objetos, dados, jobs,
  arquivos ou sessão, conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 038 (2026-11-04): Contagem gerada usa OBJECT/RELATIVE_FNO/BLOCK_NUMBER com delimitadores em vez do prefixo de ROWID restrito; owners/nomes citados e literal do staging escapado. Saída ordenada e arquivo dedicado count_blocks_generated.sql, executado conforme fluxo original. Casos de homologação: Nomes com apóstrofo/aspas; mesmo número de bloco em arquivos/objetos distintos; tabela vazia; staging e permissões; custo com clone representativo; script gerado íntegro. Comentários/créditos históricos preservados. Não aprovado para implantação.

REFERÊNCIAS DA REVISÃO038
 https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_ROWID.html

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
set define on
set sqlcase mixed
define qt=chr(39)
define cr=chr(10)
set echo off verify off feedback off heading off linesize 32767 pagesize 0
spool count_blocks_generated.sql
select 'INSERT INTO temp_size_table'||&&cr||
       'SELECT '||&&qt||REPLACE(segment_name,CHR(39),CHR(39)||CHR(39))||&&qt||&&cr||
       ',COUNT(DISTINCT DBMS_ROWID.ROWID_OBJECT(ROWID)||'':''||'||
       'DBMS_ROWID.ROWID_RELATIVE_FNO(ROWID)||'':''||'||
       'DBMS_ROWID.ROWID_BLOCK_NUMBER(ROWID)) blocks'||&&cr||
       'FROM "'||REPLACE(owner,'"','""')||'"."'||REPLACE(segment_name,'"','""')||'";'
from dba_segments
where segment_type='TABLE'
 and owner not in ('SYS','SYSTEM','MDSYS','CTXSYS','OUTLN','Burleson Consulting')
order by owner,segment_name;
spool off
set define off
start count_blocks_generated.sql
