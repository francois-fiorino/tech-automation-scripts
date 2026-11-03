/*
===============================================================================
SCRIPT: ref_prac.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/ref_prac.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Demonstrar tipos objeto, tabelas objeto e referências REF/SCOPE/DEREF.

FUNCIONAMENTO DETALHADO
  Cria quatro tipos e tabelas DEPARTMENTS/LOCATIONS/EMPLOYEES, insere dados ilustrativos e consulta referências.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios e grants DIRETOS de criação/execução/consulta conforme limitações;
  não conceder acesso amplo para executar exemplos.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  Tipos LOCATION_T/ENAME_T/EMPLOYEE_T/DEPARTMENT_T; tabelas DEPARTMENTS/LOCATIONS/EMPLOYEES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE TYPE/TABLE/quota e DML; DDL confirma implicitamente inserts anteriores. Não contém cleanup e reexecução pode conflitar/duplicar. Dados são exemplos históricos, não diretório atual de pessoas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente schema descartável sem objetos homônimos: revisar @ref_prac.sql.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Objetos/dados persistentes e exemplos REF/DEREF.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código completo e dados ilustrativos preservados; não executado. 
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
set echo on
spool ref_prac.doc

create or replace type location_t AS OBJECT
(lname VARCHAR2(32),
address1 VARCHAR2(32),
address2 VARCHAR2(32),
city     VARCHAR2(16),
state    CHAR(2),
zipplus4 VARCHAR2(10),
phone    VARCHAR2(20));
/
show err

create or replace type ename_t AS OBJECT
(first_name VARCHAR2(32),
last_name   VARCHAR2(32),
middle_init VARCHAR2(3),
title       VARCHAR2(3));
/
show err

create or replace type employee_t AS OBJECT
(enumber number,
ename ename_t);
/
show err

create or replace type department_t AS OBJECT
(deptno number,
department_name varchar2(16));
/
show err

create table departments of department_t;

create table locations of location_t;

insert into locations values (location_t('Home','5055 Forest Run',null,'Alpharetta','GA','30022','770-555-1212'));

insert into locations values (location_t('Work','18000 Century Blvd','Suite 100','Norcross','GA','30123','770-555-1212'));

insert into departments values (department_t(1,'Executive'));

select * from departments;

select * from locations;

select REF(d) from departments d;
                                                                                                   
select REF(l) from locations l;
 
create table employees (
employee employee_t,
dept REF department_t SCOPE is departments,
eloc REF location_t SCOPE IS locations);

insert into employees 
select 
       employee_t(1,ename_t('Michael','Ault','R.','Mr.')), 
       REF(d) , 
       REF(l) 
FROM 
     departments d, 
     locations l 
where 
     d.deptno=1 and l.lname='Home';

select * from employees;

select e.employee.enumber, e.employee.ename.last_name, deref(e.dept), deref(e.eloc) 
from employees e;

spool off

