/*
===============================================================================
SCRIPT: free_spc3.sql
CATEGORIA: Oracle / storage
ORIGEM: Oracle Script Collection 2015 / _tablespace_scripts/free_spc3.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Comparar tamanho alocado e espaço não alocado por tablespace de datafiles.

FUNCIONAMENTO DETALHADO
  Agrega bytes de DBA_DATA_FILES e DBA_FREE_SPACE separadamente em KiB, faz LEFT JOIN para incluir tablespaces sem extents livres e calcula usado/livre e percentuais.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.DBA_DATA_FILES, SYS.DBA_FREE_SPACE

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não inclui tempfiles nem capacidade máxima de autoextend. Usado significa espaço não classificado como extent livre, não bytes de linhas. Falta de visibilidade de espaço livre por arquivo offline pode parecer uso total.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @free_spc3.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Tablespace, total, usado alocado, livre em KiB, percentuais de livre/usado e número de datafiles; ordena percentual usado e nome.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  INNER JOIN substituído por LEFT JOIN e NVL(free_space,0) para mostrar tablespaces sem espaço livre. NULLIF protege total zero. 
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
select tablespace_name,
       total_space,
       total_space-nvl(f.free_space,0),
       nvl(f.free_space,0),
       (nvl(f.free_space,0)/nullif(total_space,0))*100,
       ((total_space-nvl(f.free_space,0))/nullif(total_space,0))*100,
       num_files
  from (select tablespace_name,
               sum(bytes/1024) total_space,
               count(*) num_files
          from sys.dba_data_files
        group by tablespace_name) d
  left join
       (select tablespace_name TS_NAME,
               sum(bytes/1024) free_space
          from sys.dba_free_space
        group by tablespace_name) f
    on d.tablespace_name = f.TS_NAME
 order by 6,1
/
