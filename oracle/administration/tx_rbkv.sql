/*
===============================================================================
SCRIPT: tx_rbkv.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/TX_RBKV.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar view de locks TX por rollback segment com sessão/processo associados.

FUNCIONAMENTO DETALHADO
  LEFT JOIN de V$ROLLNAME a V$LOCK por ID1/65536 e TX modo 6; depois V$SESSION por SID e V$PROCESS por endereço.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/alteração/execução e SELECT DIRETO conforme LIMITAÇÕES.
  Grants por role podem não valer para views/procedimentos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$ROLLNAME, V$LOCK, V$SESSION, V$PROCESS; view TRANS_PER_ROLLBACK

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE VIEW e leitura direta. TRANSACTION é alias histórico de usuário do processo, não identificador de transação. Não é cadeia RAC completa; pode haver várias sessões/processo. DDL persistente.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @tx_rbkv.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  NAME, SID, PID (SPID), TRANSACTION (texto de P.USERNAME) e TERMINAL.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PROPOSTA DE REVISÃO: o código pode modificar objetos, dados, jobs,
  arquivos ou sessão, conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Junção incorreta SID=PID corrigida pela ponte V$SESSION.PADDR=V$PROCESS.ADDR; preservadas colunas e filtro TX. 
  Revisão estática somente; implantação depende de testes e aprovação do PR.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 042 — 04/11/2026
  Correções e melhorias: View histórica preservada com ponte correta via V$SESSION.PADDR.
  Limitações e pendências: Alias TRANSACTION é texto de P.USERNAME, não XID; só locks TX em modo6 e instância local. Várias sessões/processos e ausência de lock têm semântica de left join.
  Homologação necessária: Rollback sem lock, TX modo4/6, sessões múltiplas e processo ausente; sem concluir bloqueio RAC completo.
  Parâmetros e execução: contratos descritos acima e no corpo histórico.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e análise estática; sem compilação/execução Oracle,
  backup/recovery, comandos Windows/Unix ou uso de credenciais reais.

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
create view trans_per_rollback (name,sid,pid,transaction,terminal) as
select  r.name, l.Sid, p.spid,NVL(p.username, 'no transaction'),  p.terminal
from v$rollname r
left join v$lock l on trunc(l.id1/65536)=r.usn and l.type='TX' and l.lmode=6
left join v$session s on s.sid=l.sid
left join v$process p on p.addr=s.paddr;
