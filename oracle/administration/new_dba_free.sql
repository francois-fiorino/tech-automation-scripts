/*
===============================================================================
SCRIPT: new_dba_free.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/new_dba_free.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar view histórica que combina extents alocados de DMT/LMT.

FUNCIONAMENTO DETALHADO
  UNION ALL de SYS.UET$ e X$KTFBUE com campos de segmento/extent/arquivo/bloco.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Grants diretos nos objetos internos listados e privilégios de criação apropriados, em laboratório.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.UET$, SYS.X$KTFBUE; view NEW_DBA_FREE_SPACE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Apesar do nome free, fontes representam extents alocados: não usar como espaço livre. Tabelas internas e tamanhos têm compatibilidade incerta; varredura pode ser cara. CREATE VIEW e SELECT direto.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório com grants diretos: @new_dba_free.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  View com mapeamento de extents utilizados.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: cria/modifica objetos, dados, credenciais ou sessão
  conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  UET$ qualificada com SYS; definição completa preservada. 
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

-- comment:  create view new_dba_free_space
create view new_dba_free_space (segment_file#,seg_block#,extent#,file#,block#,length) as
select segfile#, 
segblock#, 
ext#, 
file#, 
block#, 
length 
from sys.uet$ 
union all 
select ktfbuesegfno, 
ktfbuesegbno, 
ktfbueextno, 
ktfbuefno, 
ktfbuebno, 
ktfbueblks 
from sys.x$ktfbue
/


