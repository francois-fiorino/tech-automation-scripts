/*
===============================================================================
SCRIPT: asm_diskgroup_stats.sql
CATEGORIA: Oracle / asm
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/asm_diskgroup_stats.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Exibir bytes e tempo médio acumulado de I/O de cada disco ASM identificado pelo diskgroup.

FUNCIONAMENTO DETALHADO
  Une V$ASM_DISK_STAT a V$ASM_DISKGROUP_STAT por GROUP_NUMBER; mostra DISK_NUMBER/NAME e divide READ_TIME por READS e WRITE_TIME por WRITES.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Conectar ao contexto ASM autorizado e conferir escopo das views; grants de
  leitura específicos ou sessão administrativa adequada, sem alterar discos.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$ASM_DISK_STAT, V$ASM_DISKGROUP_STAT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Consultar contexto ASM autorizado; acesso via grants de diagnóstico ou sessão administrativa apropriada. Tempos são segundos nas versões atuais, mas documentação de versões antigas usava centésimos: confirmar unidade local. TIMED_STATISTICS desabilitado pode zerar tempos sem significar latência zero. Não há agregação por grupo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @asm_diskgroup_stats.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  DISKGROUP, DISK_NUMBER, DISK_NAME, BYTES_READ, AVG_READ_TIME, BYTES_WRITTEN e AVG_WRITE_TIME por disco.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Razões invertidas corrigidas para tempo/operação com NULLIF; IDs dos discos adicionados para distinguir linhas. V$ASM_DISKGROUP_STAT substitui V$ASM_DISKGROUP para evitar discovery a cada consulta. 
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

select
   '+'||g.name as diskgroup,
   s.disk_number,
   s.name as disk_name,
   s.bytes_read,
   s.read_time/nullif(s.reads,0) as avg_read_time,
   s.bytes_written,
   s.write_time/nullif(s.writes,0) as avg_write_time
from
   v$asm_disk_stat s
   join
   v$asm_diskgroup_stat g
   on s.group_number = g.group_number;
