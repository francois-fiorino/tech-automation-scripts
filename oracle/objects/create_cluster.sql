/*
===============================================================================
SCRIPT: create_cluster.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/create_cluster.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exemplificar cluster de tabelas DEPT/EMP com chave DEPTNO.

FUNCIONAMENTO DETALHADO
  CREATE CLUSTER com placeholders e storage histórico, seguido de duas tabelas com PK/FK.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme LIMITAÇÕES; roles não
  bastam para compilar dependências de rotinas armazenadas.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  Cluster e tabelas DEPT/EMP, tablespace USERS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Permanece template com marcadores <...> que precisam de edição consciente; não compila sem configurar. Tablespace USERS e storage são exemplos. CREATE CLUSTER/TABLE/INDEX confirma transações e pode falhar parcialmente; não instala DEMO sobre dados existentes. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Somente editar cópia de laboratório substituindo todos os <placeholders>; então revisar DDL.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Modelo de DDL, não script executável sem edição.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados ou sessão descritos
  acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 037 (2026-11-03): Exemplo inclui CREATE INDEX ON CLUSTER; cláusulas CLUSTER das tabelas mapeiam a coluna local DEPTNO à chave do cluster, em vez de usar indevidamente o nome da chave de cluster como coluna local. Casos de homologação: Nomes configurados; chave de cluster com nome diferente de DEPTNO; INSERT de departamentos/empregados; índice de cluster; FK/PK; ASSM/LMT; objetos existentes. Comentários/créditos históricos preservados. Não aprovado para implantação.

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
REM Replace the <> placeholders with the proper values
REM for cluster name, cluster column and cluster index name as required.

CREATE CLUSTER <cluster_name> (<cluster_column> NUMBER(2))
PCTUSED 80
PCTFREE 5
SIZE 600
TABLESPACE users
STORAGE(
INITIAL 200k
NEXT 300K
MINEXTENTS 2
MAXEXTENTS 20
PCTINCREASE 0);

CREATE INDEX <cluster_index_name> ON CLUSTER <cluster_name>;

CREATE TABLE dept(
DEPTNO NUMBER(2) CONSTRAINT PK_DEPT PRIMARY KEY,
DNAME  VARCHAR2(14),
LOC    VARCHAR2(13))
CLUSTER <cluster_name> (DEPTNO);

CREATE TABLE emp(
EMPNO NUMBER(4) CONSTRAINT PK_EMP PRIMARY KEY, 
ENAME VARCHAR2(10) NOT NULL,
JOB VARCHAR2(9),
MGR NUMBER(4),
HIREDATE DATE,
SAL NUMBER(7,2),
COMM NUMBER(7,2),
DEPTNO NUMBER(2) REFERENCES dept)
CLUSTER <cluster_name> (DEPTNO);
