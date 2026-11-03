/*
===============================================================================
SCRIPT: dnfs_disk_stats.sql
CATEGORIA: Oracle / monitoring
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/dnfs_disk_stats.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Associar bytes de leitura/escrita Direct NFS ao programa do processo local.

FUNCIONAMENTO DETALHADO
  Une V$DNFS_STATS.PNUM a V$PROCESS.PID e soma NFS_READBYTES+NFS_WRITEBYTES por linha de estatística.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$DNFS_STATS, V$PROCESS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Requer Direct NFS para dados relevantes; não agrega por programa nem mede latência, taxa ou disco individual. PID é identificador interno da view, não SPID do sistema operacional. Confirmar colunas na versão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @dnfs_disk_stats.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  PROGRAM e NFS_TOTALBYTES acumulados; pode haver programas repetidos.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta preservada; CR isolados normalizados. 
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
   p.program,
   d.nfs_readbytes + d.nfs_writebytes as nfs_totalbytes
from
   v$dnfs_stats d
   join
   v$process p
   on d.pnum = p.pid;
