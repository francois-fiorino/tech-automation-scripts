/*
===============================================================================
SCRIPT: delta_rep.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / misc_scripts/delta_rep.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Normalizar série customizada de deltas pelo maior delta da janela.

FUNCIONAMENTO DETALHADO
  Consulta MAX(delta) de medição/data selecionadas e depois lista valor, delta, timestamp e delta/max*100.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_RUNNING_STATS (customizada)

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não calcula DELTA a partir de contadores; depende do coletor. Máximo negativo torna interpretação não convencional. Janela inclui agora; data/mês dependem de NLS.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @delta_rep.sql
  -- Informar measurement e start_date dd-mon-yy hh24:mi:ss.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Série cronológica com delta normalizado; NULL se máximo é zero ou não há dados.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Comparações textuais e conversões implícitas substituídas por DATE BETWEEN em ambos os SELECTs; NVL(MAX,0), NULLIF e ORDER BY data real. 
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
column name format a25 heading 'Measurement|Name'
column value heading 'Measurement|Date'
column delta heading 'Measurement|Delta'
column meas_date format a23 heading 'Measurement|Date'
column normal format 999999.9999 heading 'Delta|Normalized|to 100'
undef start_date
undef measurement
column max_val new_value norm_val noprint;
  select 
	nvl(max(delta),0) max_val
  from 
	dba_running_stats
  where 
  	upper(name)=upper('&&measurement') and
	meas_date between to_date('&&start_date','dd-mon-yy hh24:mi:ss') and sysdate; 
select
   name,
   value,
   delta,
   to_char(meas_date,'dd-mon-yy hh24:mi:ss') meas_date,
   delta/nullif(&&norm_val,0)*100 normal
from
   dba_running_stats r
where
   upper(name)=upper('&&measurement')
   and meas_date between to_date('&&start_date','dd-mon-yy hh24:mi:ss') and sysdate
order by r.meas_date
/
