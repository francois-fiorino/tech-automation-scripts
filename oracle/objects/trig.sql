/*
===============================================================================
SCRIPT: trig.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/trig.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Instalar triggers de integridade alternativa de SITE_ID em aplicação BBS.

FUNCIONAMENTO DETALHADO
  Oito triggers AFTER INSERT/UPDATE exigem ocorrência de site em BBS_NEW_CUSTOMER ou CUSTOMER_SITES; update de earnings chama CNET.UPDATE_TABLES.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants DIRETOS de criação/execução/consulta e permissões administrativas
  conforme limitações; não instalar variantes sobre objetos de trabalho.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  BBS_AE, USERS, BBS_INTERACTION_LOG, BBS_EARNINGS_INFO, BBS_NEW_CUSTOMER, CUSTOMER_SITES, CNET.UPDATE_TABLES

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE TRIGGER/grants diretos; contagens por linha custam I/O e lógica não substitui FK sob concorrência/DELETE dos pais. UPDATE_TABLES pode ter efeitos adicionais não conhecidos. Não instalar genericamente em outro schema.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente clone isolado da aplicação com contratos revisados.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Triggers criados; DML futuro pode falhar -20001 ou chamar atualização em cascata customizada.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: DDL/DML, staging, autenticação ou efeitos da saída
  descritos acima. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Mensagem de erro do update EARNINGS corrigida que mencionava INTERACTION_LOG; regras e chamada de cascata preservadas. Crédito M. Ault 1997 mantido. 
  Alterações de código revisadas estaticamente; testes Oracle ainda necessários.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 044 — 04/11/2026
  Correções e melhorias: Oito triggers e regras de integridade/cascata preservados.
  Limitações e pendências: COUNT porlinha não impõe integridade sob DELETEconcorrente dos pais; SITE_IDNULL falha por contagenszero. CNET.UPDATE_TABLES ausente pode alterar outras tabelas; não presumir FK equivalente.
  Homologação necessária: Pais0/1/2, SITE_IDNULL, mudança/desligamento de pais e cascata; clone com DDL completo, sem instalar em schema genérico.
  Parâmetros/execução: contratos descritos acima e no corpo; somente laboratório.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  submissão de jobs, backup/recovery, Shell/Windows/VMS ou coleta de credenciais.

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
--
-- Triggers to enforce either -- or relationship between
-- customer_sites, bbs_new_customer and their dependent tables.
-- Update trigger on bbs_earnings_info also enforces cascade update
-- to its dependent tables based on entries in the bbs_update_tables
-- table. Created by Mike Ault 1/24/97 rev 2.0
--
create trigger cnetI_BBS_AE after INSERT on BBS_AE for each row
declare
 numrows INTEGER;
 numrows2 INTEGER;
begin
 select 
      count(1) into numrows
 from 
      bbs_new_customer
 where
      :new.site_id = bbs_new_customer.site_id;
 select 
      count(1) into numrows2
 from 
      customer_sites
 where
      :new.site_id = customer_sites.site_id;
 if (numrows = 0 and numrows2 = 0)
 then
      raise_application_error(
        -20001,
        'INSERT into "BBS_AE" failed. site_id not in "BBS_NEW_CUSTOMER" or "CUSTOMER_SITES".'
      );
 end if;
end;
/
create trigger cnetU_BBS_AE after UPDATE on BBS_AE for each row
declare
 numrows INTEGER;
 numrows2 INTEGER;
begin
 select 
      count(1) into numrows
 from 
      bbs_new_customer
 where
      :new.site_id = bbs_new_customer.site_id;
 select 
      count(1) into numrows2
 from 
      customer_sites
 where
      :new.site_id = customer_sites.site_id;
 if (numrows = 0 and numrows2 = 0)
 then
      raise_application_error(
        -20001,
        'UPDATE of "BBS_AE" failed. site_id not in "BBS_NEW_CUSTOMER" or "CUSTOMER_SITES".'
      );
 end if;
end;
/
--
--
create trigger cnetI_USERS after INSERT on USERS for each row
declare
 numrows INTEGER;
 numrows2 INTEGER;
begin
 select 
      count(1) into numrows
 from 
      bbs_new_customer
 where
      :new.site_id = bbs_new_customer.site_id;
 select 
      count(1) into numrows2
 from 
      customer_sites
 where
      :new.site_id = customer_sites.site_id;
 if (numrows = 0 and numrows2 = 0)
 then
      raise_application_error(
        -20001,
        'INSERT into "USERS" failed. site_id not in "BBS_NEW_CUSTOMER" or "CUSTOMER_SITES".'
      );
 end if;
end;
/
create trigger cnetU_USERS after UPDATE on USERS for each row
declare
 numrows INTEGER;
 numrows2 INTEGER;
begin
 select 
      count(1) into numrows
 from 
      bbs_new_customer
 where
      :new.site_id = bbs_new_customer.site_id;
 select 
      count(1) into numrows2
 from 
      customer_sites
 where
      :new.site_id = customer_sites.site_id;
 if (numrows = 0 and numrows2 = 0)
 then
      raise_application_error(
        -20001,
        'UPDATE of "USERS" failed. site_id not in "BBS_NEW_CUSTOMER" or "CUSTOMER_SITES".'
      );
 end if;
end;
/
--
--
create trigger cnetI_BBS_INTERACTION_LOG after INSERT on BBS_INTERACTION_LOG for each row
declare
 numrows INTEGER;
 numrows2 INTEGER;
begin
 select 
      count(1) into numrows
 from 
      bbs_new_customer
 where
      :new.site_id = bbs_new_customer.site_id;
 select 
      count(1) into numrows2
 from 
      customer_sites
 where
      :new.site_id = customer_sites.site_id;
 if (numrows = 0 and numrows2 = 0)
 then
      raise_application_error(
        -20001,
        'INSERT into "BBS_INTERACTION_LOG" failed. site_id not in "BBS_NEW_CUSTOMER" or "CUSTOMER_SITES".'
      );
 end if;
end;
/
create trigger cnetU_BBS_INTERACTION_LOG after UPDATE on BBS_INTERACTION_LOG for each row
declare
 numrows INTEGER;
 numrows2 INTEGER;
begin
 select 
      count(1) into numrows
 from 
      bbs_new_customer
 where
      :new.site_id = bbs_new_customer.site_id;
 select 
      count(1) into numrows2
 from 
      customer_sites
 where
      :new.site_id = customer_sites.site_id;
 if (numrows = 0 and numrows2 = 0)
 then
      raise_application_error(
        -20001,
        'UPDATE of "BBS_INTERACTION_LOG" failed. site_id not in "BBS_NEW_CUSTOMER" or "CUSTOMER_SITES".'
      );
 end if;
end;
/
--
--
create trigger cnetI_BBS_EARNINGS_INFO after INSERT on BBS_EARNINGS_INFO for each row
declare
 numrows INTEGER;
 numrows2 INTEGER;
begin
 select 
      count(1) into numrows
 from 
      bbs_new_customer
 where
      :new.site_id = bbs_new_customer.site_id;
 select 
      count(1) into numrows2
 from 
      customer_sites
 where
      :new.site_id = customer_sites.site_id;
 if (numrows = 0 and numrows2 = 0)
 then
      raise_application_error(
        -20001,
        'INSERT into "BBS_EARNINGS_INFO" failed. site_id not in "BBS_NEW_CUSTOMER" or "CUSTOMER_SITES".'
      );
 end if;
end;
/
create trigger cnetU_BBS_EARNINGS_INFO after UPDATE on BBS_EARNINGS_INFO for each row
declare
 numrows INTEGER;
 numrows2 INTEGER;
begin
 select 
      count(1) into numrows
 from 
      bbs_new_customer
 where
      :new.site_id = bbs_new_customer.site_id;
 select 
      count(1) into numrows2
 from 
      customer_sites
 where
      :new.site_id = customer_sites.site_id;
 if (numrows = 0 and numrows2 = 0)
 then
      raise_application_error(
        -20001,
        'UPDATE of "BBS_EARNINGS_INFO" failed. site_id not in "BBS_NEW_CUSTOMER" or "CUSTOMER_SITES".'
      );
 else
      begin
	cnet.update_tables('BBS_EARNINGS_INFO',:old.site_id,:new.site_id);
      end;
 end if;
end;
/

