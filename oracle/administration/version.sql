/*
===============================================================================
SCRIPT: version.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/version.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar função que extrai a versão numérica do banner Oracle.

FUNCIONAMENTO DETALHADO
  Cursor lê banner Oracle de V$VERSION; REGEXP_SUBSTR extrai cadeia numérica de versão, cursor é fechado e valor retornado.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/execução e SELECT DIRETO conforme LIMITAÇÕES; roles
  podem não atender compilação de objetos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$VERSION, REGEXP_SUBSTR; função RETURN_VERSION

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Versão modernizada requer REGEXP_SUBSTR (Oracle 10g+), CREATE PROCEDURE e SELECT direto. Banner não garante nível completo de RU/patch; consultar inventário apropriado para isso.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @version.sql; testar RETURN_VERSION em ambiente-alvo.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  String como 19.0.0.0.0 ou NULL sem correspondência.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cria/modifica objetos, dados, credenciais ou sessão
  conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Filtro apenas 7/8 e offset fixo substituídos por extração de versão; buffers ampliados e cursor fechado. Não executado em Oracle. 
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
create or replace function return_version
return varchar2 as
cursor get_version is
select banner from v$version 
where banner like 'Oracle%';

version varchar2(4000);
short_version varchar2(64);

begin
open get_version;
fetch get_version into version;
close get_version;
short_version:=regexp_substr(version,'[0-9]+(\.[0-9]+){2,4}');
return short_version;
end;
/
