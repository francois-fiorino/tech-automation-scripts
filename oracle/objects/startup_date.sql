/*
===============================================================================
SCRIPT: startup_date.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/startup_date.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar procedimento histórico que devolve data de startup por layout KEY/VALUE.

FUNCIONAMENTO DETALHADO
  Consulta a coluna DATE STARTUP_TIME da instância local, preserva parâmetro OUT DATE e imprime diagnóstico sem depender de NLS.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme limitações de cada arquivo. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$INSTANCE (KEY/VALUE legado), DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Reimplementação da obtenção da mesma informação por coluna documentada. CREATE PROCEDURE e SELECT direto em SYS.V_$INSTANCE necessários. Data é da instância local, não uptime da PDB nem conjunto RAC. Alvo documental das APIs novas: Oracle 19c. Sem compilação ou execução Oracle; grants, versão e resultado ainda exigem laboratório.

EXEMPLO DE EXECUÇÃO
  Revisão em versão legada compatível: @startup_date.sql.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Procedimento criado; chamada retorna DATE de startup da instância e imprime YYYY-MM-DD HH24:MI:SS.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  conforme descritos. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Revisão complementar 036 (2026-11-03): Retorno DATE obtido diretamente de V$INSTANCE.STARTUP_TIME; eliminados KEY/VALUE obsoletos, montagem juliana e roundtrip NLS. Saída de diagnóstico em ISO; OUT inicializado NULL no caso sem linha. Casos de homologação: Comparar OUT a V$INSTANCE.STARTUP_TIME com NLS_DATE_FORMAT distintos; NULL/erro de acesso; instâncias RAC diferentes. Comentários/créditos históricos preservados. Não aprovado para implantação.

REFERÊNCIAS TÉCNICAS DA REVISÃO 036
 https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-INSTANCE.html

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
create or replace PROCEDURE startup_date (good_date out date)
AS
BEGIN
 SELECT startup_time INTO good_date FROM v$instance;
 DBMS_OUTPUT.PUT_LINE('Startup Date: '||TO_CHAR(good_date,'YYYY-MM-DD HH24:MI:SS'));
EXCEPTION
 WHEN NO_DATA_FOUND THEN
   good_date:=NULL;
   DBMS_OUTPUT.PUT_LINE('Startup Date: unknown');
END;
/
