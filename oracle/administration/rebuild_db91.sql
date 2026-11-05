/*
===============================================================================
SCRIPT: rebuild_db91.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/rebuild_db91.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Preservar exemplo histórico de CREATE DATABASE Oracle9i com arquivos Windows.

FUNCIONAMENTO DETALHADO
  CREATE DATABASE AULTDB1 com CONTROLFILE/DATAFILE REUSE, redo/undo/temp, charset/timezone e NOARCHIVELOG.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS e privilégios administrativos conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  Arquivos D:\ORACLE\ORADATA\AULTDB1, instância NOMOUNT e configuração externa

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Exige SYSDBA, startup apropriado e arquivos exclusivos. REUSE pode sobrescrever dados/controlfiles. AUTOEXTEND ON NEXT sem valor é sintaxe inválida cujo incremento não pode ser inferido; DEFAULT STORAGE legado e semântica undo/temp precisam revisão. NOARCHIVELOG limita recuperação.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Análise de código somente; nunca executar sobre diretório com dados existentes.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Modelo de criação de banco, não script homologado de recuperação.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: pode gerar ou executar DDL/DML, expor hashes/segredos
  do banco consultado ou alterar sessão conforme descrito acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  LOCAL LOCAL SIZE corrigido para LOCAL UNIFORM SIZE; incremento NEXT desconhecido preservado como pendência, sem escolher valor arbitrário. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 043 — 04/11/2026
  Correções e melhorias: EXIT incondicional antes de CREATE DATABASE inválido/perigoso.
  Limitações e pendências: AUTOEXTEND NEXT sem valor é inválido; não inferir incremento ou descartar funcionalidades. REUSE, pathsWindows, NOARCHIVELOG e layout9i não são estratégia moderna de restore.
  Homologação necessária: Confirmar barreira antes de CREATE DATABASE; definir parâmetros/arquivos exclusivos e revisar gramática do modelo em ambiente descartável.
  Parâmetros/execução: contratos acima e corpo histórico; somente laboratório.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral/análise estática; sem compilação ou execução Oracle,
  Windows, escrita de arquivo no servidor, backup/recovery ou alteração de contas.

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
PROMPT BLOQUEADO: CREATE DATABASE legado incompleto; somente revisao.
EXIT FAILURE ROLLBACK


/*  */
CREATE DATABASE AULTDB1
CONTROLFILE REUSE
MAXINSTANCES 1
MAXLOGFILES 50
MAXDATAFILES 100
MAXLOGHISTORY 113
DATAFILE 'D:\ORACLE\ORADATA\AULTDB1\SYSTEM01.DBF' SIZE 372244480 REUSE
 AUTOEXTEND ON NEXT  MAXSIZE 17179860992
 DEFAULT STORAGE (INITIAL 12288 NEXT 12288
 MINEXTENTS 1 MAXEXTENTS 249
 PCTINCREASE 50)
LOGFILE 
 GROUP 1 (
'D:\ORACLE\ORADATA\AULTDB1\REDO01.LOG'
 ) SIZE 104857600,
 GROUP 2 (
'D:\ORACLE\ORADATA\AULTDB1\REDO02.LOG'
 ) SIZE 104857600,
 GROUP 3 (
'D:\ORACLE\ORADATA\AULTDB1\REDO03.LOG'
 ) SIZE 104857600
UNDO TABLESPACE UNDOTBS DATAFILE 'D:\ORACLE\ORADATA\AULTDB1\UNDOTBS01.DBF' SIZE 209715200 REUSE
 AUTOEXTEND ON NEXT 5242880 MAXSIZE 17179860992
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
DEFAULT TEMPORARY TABLESPACE TEMP TEMPFILE 'D:\ORACLE\ORADATA\AULTDB1\TEMP01.DBF' SIZE 41943040 REUSE
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1048576
CHARACTER SET WE8MSWIN1252
NATIONAL CHARACTER SET AL16UTF16
SET TIME_ZONE ='-05:00'
NOARCHIVELOG
;
