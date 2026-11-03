/*
===============================================================================
SCRIPT: buffer_cache_blocks.sql
CATEGORIA: Oracle / rac
ORIGEM: Oracle Script Collection 2015 / _rac_tuning_scripts/buffer_cache_blocks.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Contar endereços de blocos em caches específicos e interseção de três instâncias.

FUNCIONAMENTO DETALHADO
  Primeira consulta DISTINCT FILE#/BLOCK# na instância 1; segunda INTERSECT das instâncias 1, 2 e 3.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  GV$BH

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não filtra STATE livre nem CON_ID e não conta cópias; interpretar conforme layout da view. Só cobre três IDs fixos, não todos os nós genericamente. Varredura de buffer headers pode custar recursos.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @buffer_cache_blocks.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  NUM_BLOCKS da instância 1 e NUM_SHARED_BLKS presentes nas três instâncias fixas.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consultas originais preservadas; comentário UTF-8 decodificado corretamente. 
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

-- Run for each instance id to obtain
-- number of blocks in each instance’s cache
 
select 
   count(*) as num_blocks 
from (
   select distinct 
      file#,
      block# 
   from 
      gv$bh
   where 
      inst_id=1);

-- Run once to determine how many blocks 
-- are the same in all caches. 

select 
   count(*) as num_shared_blks
from (
   select distinct 
      file#,
      block# 
   from 
      gv$bh 
   where 
      inst_id=1
   intersect 
   select distinct 
      file#,
      block# 
   from 
      gv$bh 
   where 
      inst_id=2
   intersect 
   select distinct 
      file#,
      block# 
   from 
      gv$bh 
   where 
      inst_id=3);
