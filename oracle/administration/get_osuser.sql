/*
===============================================================================
SCRIPT: get_osuser.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _os_scripts/get_osuser.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar função que obtém um OSUSER dentre sessões do usuário Oracle corrente.

FUNCIONAMENTO DETALHADO
  Cursor DISTINCT une V$SESSION/V$PROCESS e filtra USER=USERNAME; fetch de uma linha, fecha e retorna.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/alteração/execução e SELECT DIRETO conforme LIMITAÇÕES.
  Grants por role podem não valer para views/procedimentos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$SESSION, V$PROCESS; função GET_OSUSER

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Retorna primeira OSUSER distinta dentre sessões do usuário, sem ordem; não identifica necessariamente a sessão chamadora. JOIN V$PROCESS é local e pode omitir sessões. Exige CREATE PROCEDURE e SELECT diretos. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @get_osuser.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Função criada; retorno de um OSUSER ou NULL quando sem linha.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PROPOSTA DE REVISÃO: o código pode modificar objetos, dados, jobs,
  arquivos ou sessão, conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 036 (2026-11-03): Corpo preservado; registrada a ambiguidade funcional em vez de trocar por OS_USER de sessão sem evidência do contrato. Casos de homologação: Mesmo usuário em duas sessões com OSUSER diferente; nenhuma sessão correspondente; shared server; chamadas em RAC; decidir contrato antes de mudar consulta. Comentários/créditos históricos preservados. Não aprovado para implantação.

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
create or replace function get_osuser 
return varchar2 as
cursor get_user is
select 
	distinct decode(s.osuser,null,'Internal',s.osuser) 
from 
	v$session s, 
	v$process p
where 
        p.addr=s.paddr
	and user=s.username;
username varchar2(255);
begin
open get_user;
fetch get_user into username;
close get_user;
return username;
end;
/
