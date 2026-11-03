/*
===============================================================================
SCRIPT: good_percent.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / misc_scripts/good_percent.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Calcular média não ponderada de razões de memória classificada como good/garbage.

FUNCIONAMENTO DETALHADO
  Self join de SQL_GARBAGE por USERS, cruza linha com GARBAGE não NULL e GOOD não NULL e calcula AVG(GOOD/(GOOD+GARBAGE))*100.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SQL_GARBAGE (view customizada da coleção)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não representa uso físico do shared pool nem média ponderada por bytes. Depende da definição da view e unicidade por usuário; classificação por execuções não prova SQL descartável.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @good_percent.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  GOOD_PERCENT como média das razões por usuário.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  NULLIF protege GOOD+GARBAGE igual a zero; metodologia original mantida e ressalvada. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
column good_percent format 999.99 heading 'Percent Shared'
set feedback off 
ttitle 'Shared Pool Utilization'
ttitle off
spool good_percent.lst
select avg(b.good/nullif(b.good+a.garbage,0))*100 good_percent
from sql_garbage a, sql_garbage b
where a.users=b.users
and a.garbage is not null and b.good is not null
/
spool off
