/*
===============================================================================
SCRIPT: garbage_view.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _sql_scripts/garbage_view.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar view histórica que classifica memória SQL pelo número de execuções.

FUNCIONAMENTO DETALHADO
  UNION de agrupamentos por parsing user: EXECUTIONS<=1 em GARBAGE e >1 em GOOD, somando SHARABLE_MEM+PERSISTENT_MEM.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/execução e SELECT DIRETO conforme LIMITAÇÕES; roles
  podem não atender compilação de objetos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.V_$SQLAREA, DBA_USERS; view SQL_GARBAGE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE VIEW e SELECT direto. Poucas execuções não tornam SQL descartável; memória persistente pode sobrepor total compartilhável. Não mede memória física recuperável.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @garbage_view.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Duas classes de linhas por usuário com campos NULL complementares.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cria/modifica objetos, dados, credenciais ou sessão
  conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Definição integral preservada; não promove heurística a recomendação de purge. 
  Revisão estática somente; implantação depende de laboratório e aprovação do PR.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 039 — 04/11/2026
  Correções e melhorias: Heurística histórica preservada; não recomenda purge.
  Limitações e pendências: SHARABLE_MEM e PERSISTENT_MEM podem se sobrepor; UNION produz linhas separadas GOOD/GARBAGE. Execução única não prova desperdício.
  Homologação necessária: Usuário com ambas classes, SQL sem execução e snapshot variável; não interpretar soma como memória recuperável.
  Parâmetros/execução: manter contrato descrito acima e no corpo histórico.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação realizada: leitura integral e comparação estática; sem compilação
  ou execução Oracle, sem execução de comandos administrativos.

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
create or replace view sql_garbage as
select 
  b.username users, 
  sum(a.sharable_mem+a.persistent_mem) Garbage,
  to_number(null) good
from 
   sys.v_$sqlarea a, 
   dba_users b
where 
  (a.parsing_user_id = b.user_id and a.executions<=1)
group by b.username
union
select distinct
  b.username users, 
  to_number(null) garbage,
  sum(c.sharable_mem+c.persistent_mem) Good
from 
   dba_users b, 
   sys.v_$sqlarea c
where 
  (b.user_id=c.parsing_user_id and c.executions>1)
group by b.username;
--
