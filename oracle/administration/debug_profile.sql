/*
===============================================================================
SCRIPT: debug_profile.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/debug_profile.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relatar níveis configurados de ONT_DEBUG_LEVEL no Oracle E-Business Suite.

FUNCIONAMENTO DETALHADO
  Une FND_PROFILE_OPTIONS/VALUES por aplicação e ID e LEFT JOINs condicionados ao LEVEL_ID para nomes de application/responsibility/user.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  FND_PROFILE_OPTION_VALUES, FND_PROFILE_OPTIONS, FND_APPLICATION, FND_RESPONSIBILITY_VL, FND_USER, FND_LOGINS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Específico de EBS e acesso autorizado às FND; não é Oracle Database PROFILE. Não altera debug e não lista todos os níveis modernos de profiles. Proteger nomes/configuração.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @debug_profile.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Nome de profile/valor, nível e nomes contextualizados por nível.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  APPLICATION_ID da opção incluído na chave; joins a nomes condicionados por LEVEL_ID evitam associar IDs iguais de contextos diferentes. Chamadas externas title80/title132 substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
set linesize 155;
set pagesize 200;
set verify off;

col Profile format a20;
col Level format a14;
col Value format a10;
col App format a3;
col Responsibility format a30;
col USER format a8;
col UPDATED_BY format a8;
ttitle 'Debug Profiles'
spool debug_profile.lst

select fpo.profile_option_name Profile,
       fpov.profile_option_value Value,
       decode(fpov.level_id,10001,
                'SITE',10002,
                'APPLICATION',10003,
                'RESPONSIBILITY',
                10004,'USER')"LEVEL",
       fa.application_short_name App,
       fr.responsibility_name Responsibility,
       fu.user_name "USER"
from fnd_profile_option_values fpov,
fnd_profile_options fpo, 
fnd_application fa, 
fnd_responsibility_vl fr,
fnd_user fu,
fnd_logins fl
where fpo.profile_option_id=fpov.profile_option_id
and fpo.application_id=fpov.application_id
and fa.application_id(+)=decode(fpov.level_id,10002,fpov.level_value)
and fr.application_id(+)=decode(fpov.level_id,10003,fpov.level_value_application_id)
and fr.responsibility_id(+)=decode(fpov.level_id,10003,fpov.level_value)
and fu.user_id(+)=decode(fpov.level_id,10004,fpov.level_value)
and fl.login_id(+) = fpov.LAST_UPDATE_LOGIN
and fpo.profile_option_name like 'ONT_DEBUG_LEVEL'
order by 1,3
/
spool off
set lines 80 pages 22 verify on
clear columns
ttitle off

