/*
===============================================================================
SCRIPT: chk_priv.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/chk_priv.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar função booleana de busca textual de privilégio em USER_TAB_PRIVS.

FUNCIONAMENTO DETALHADO
  Cursor filtra nome da tabela/privilégio em maiúsculas e retorna existência de linha.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/execução e SELECT DIRETO conforme LIMITAÇÕES; roles
  podem não atender compilação de objetos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  USER_TAB_PRIVS; função CHK_PRIV

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE e grants diretos. Não filtra owner/grantee ou roles, portanto não calcula privilégio efetivo. Nome de tabela de 32 caracteres e UPPER são limites legados.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @chk_priv.sql; chamar em PL/SQL em versões sem BOOLEAN SQL.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  TRUE/FALSE; função criada.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cria/modifica objetos, dados, credenciais ou sessão
  conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Cursor fechado antes do retorno; sem redesenhar a semântica de privilégio efetivo. 
  Revisão estática somente; implantação depende de laboratório e aprovação do PR.
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
create or replace function chk_priv(tab_name varchar2, priv varchar2)
return boolean is
	tab_nam varchar2(32);
	privil varchar2(30);
	priv_there boolean;
	cursor get_stat (tab varchar2, priv varchar2) is
		select table_name 
		from user_tab_privs 
		where table_name=upper(tab_name) and privilege=upper(priv);
begin
	open get_stat(tab_name,priv);
	fetch get_stat into tab_nam;
	if get_stat%rowcount<1
	then
		priv_there:=FALSE;
	else
		priv_there:=TRUE;
	end if;
	close get_stat;
	return priv_there;
end;
/
