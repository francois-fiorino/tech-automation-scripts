/*
===============================================================================
SCRIPT: block_count.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _rac_grid_scripts/block_count.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Inspecionar distribuição de ocupação dos blocos do segmento SYSTEM.TEST.

FUNCIONAMENTO DETALHADO
  Executa DBMS_SPACE.SPACE_USAGE para tipo TABLE; recebe blocos/bytes não formatados, FS1 a FS4 e cheios, imprimindo contagens por DBMS_OUTPUT.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  EXECUTE em DBMS_SPACE e DBMS_OUTPUT; objeto no próprio schema ou privilégio
  ANALYZE ANY para segmento de outro schema, conforme versão do pacote.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBMS_SPACE, DBMS_OUTPUT; segmento SYSTEM.TEST

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Requer segmento em ASSM compatível com SPACE_USAGE. SYSTEM.TEST é exemplo fixo; revisar objeto antes de rodar. FS1..FS4 representam faixas de espaço livre, não percentuais de linhas.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  SET SERVEROUTPUT ON
  @block_count.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Unformatted Blocks, FS1/FS2/FS3/FS4 Blocks e Full Blocks; classes de espaço livre (0–25%, 25–50%, 50–75%, 75–100%).

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Removida marca BOM indevidamente interpretável como SQL e adicionado / para executar bloco no SQL*Plus. Nenhum objeto foi criado. BOM UTF-8 da origem normalizado sem inserir caracteres no SQL.
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



-- block_count.sql



DECLARE
 v_unformatted_blocks number;
 v_unformatted_bytes number;
 v_fs1_blocks number;
 v_fs1_bytes number;
 v_fs2_blocks number;
 v_fs2_bytes number;
 v_fs3_blocks number;
 v_fs3_bytes number;
 v_fs4_blocks number;
 v_fs4_bytes number;
 v_full_blocks number;
 v_full_bytes number;
BEGIN
dbms_space.space_usage ('SYSTEM', 'TEST', 'TABLE', v_unformatted_blocks, v_unformatted_bytes, v_fs1_blocks, v_fs1_bytes, v_fs2_blocks, v_fs2_bytes, v_fs3_blocks, v_fs3_bytes, v_fs4_blocks, v_fs4_bytes, v_full_blocks, v_full_bytes);
dbms_output.put_line('Unformatted Blocks = '||v_unformatted_blocks);
dbms_output.put_line('FS1 Blocks            = '||v_fs1_blocks);
dbms_output.put_line('FS2 Blocks            = '||v_fs2_blocks);
dbms_output.put_line('FS3 Blocks            = '||v_fs3_blocks);
dbms_output.put_line('FS4 Blocks            = '||v_fs4_blocks);
dbms_output.put_line('Full Blocks           = '||v_full_blocks);
end;
/
