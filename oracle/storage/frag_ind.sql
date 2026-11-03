/*
===============================================================================
SCRIPT: frag_ind.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _index_scripts/frag_ind.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Distribuir segmentos por tipo e faixas de cinquenta extents.

FUNCIONAMENTO DETALHADO
  Agrupa DBA_SEGMENTS por SEGMENT_TYPE e TRUNC(EXTENTS/50), contando segmentos em cada faixa; ordena tipo/faixa/contagem.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_SEGMENTS

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Inclui todos os tipos de segmento, não apenas índices apesar do nome. Muitos extents em LMT não demonstram fragmentação prejudicial nem necessidade de rebuild.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @frag_ind.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  SEGMENT_TYPE, NUM_TYPES e Extents*50; o último valor é o número da faixa, não a quantidade multiplicada por cinquenta.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Consulta preservada; finalidade real e interpretação das faixas documentadas. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
ttitle 'Fragmentation Index'
spool frag_ind.lst
select  
 segment_type,
 count(*) num_types,
 trunc(EXTENTS/50) "Extents*50"
FROM    DBA_SEGMENTS
group by segment_type, trunc(extents/50)
order by segment_type, trunc(extents/50),count(*)
/
spool off
