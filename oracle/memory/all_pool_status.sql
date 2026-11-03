/*
===============================================================================
SCRIPT: all_pool_status.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/all_pool_status.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Contar headers de buffer por pool e estado interno.

FUNCIONAMENTO DETALHADO
  Relaciona X$BH.SET_DS a X$KCBWDS e intervalos de sets X$KCBWBPD, decodifica STATE/LRBA_SEQ e agrupa.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Acesso administrativo autorizado aos objetos internos listados; validar estrutura por versão.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.X$BH, SYS.X$KCBWBPD, SYS.X$KCBWDS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Acesso administrativo; tabelas internas e códigos não têm contrato de compatibilidade. Join pode ser caro em SGA grande; não usar polling sem avaliar impacto. Estados não mapeados podem resultar NULL.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @all_pool_status.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  COUNT, BP_NAME e STATE textual conforme mapeamento histórico.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta integral preservada e mapeamento descrito como histórico. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
ttitle 'All Buffer Pool Status'
spool all_pool_status.lst
select
count(*) COUNT,
kcbwbpd.bp_name,
decode(state,0,'FREE - Not Currently Used',1, decode(lrba_seq,0,'XCUR:FRBL - Exclusive: Freeable','XCUR:RECR - Exclusive:Recreatable'),
  2,'SCUR - Shared Current',
  3,'CR - Consistent Read: Recreatable',
  4,'READ - Being Read from Disk',
  5,'MREC - Media Recover',
  6,'IREC - Instance Recovery') STATE
from sys.x$bh bh, sys.x$kcbwbpd kcbwbpd, sys.x$kcbwds kcbwds
where kcbwds.set_id >= kcbwbpd.bp_lo_sid
and kcbwds.set_id <= kcbwbpd.bp_hi_sid
and kcbwbpd.bp_size != 0
and bh.set_ds=kcbwds.addr
group by kcbwbpd.bp_name, decode(state,0,'FREE - Not Currently Used',1, decode(lrba_seq,0,'XCUR:FRBL - Exclusive: Freeable','XCUR:RECR - Exclusive:Recreatable'),
  2,'SCUR - Shared Current',
  3,'CR - Consistent Read: Recreatable',
  4,'READ - Being Read from Disk',
  5,'MREC - Media Recover',
  6,'IREC - Instance Recovery')
order by 1 desc
/
spool off
