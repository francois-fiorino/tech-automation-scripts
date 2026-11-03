/*
===============================================================================
SCRIPT: file_blk_cnt.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _disk_file_scripts/file_blk_cnt.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Contar buffers tocados por objeto para um arquivo informado usando X$BH.

FUNCIONAMENTO DETALHADO
  Relaciona X$BH.OBJ a OBJ$.DATAOBJ#, filtra TCH>0 e FILE_NO; agrupa por nome/arquivo relativo e soma TCH.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Acesso administrativo autorizado aos objetos internos listados; não conceder privilégios amplos apenas para rodar este relatório.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  X$BH, SYS.OBJ$

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Tabelas internas exigem acesso administrativo; mapeamento de OBJ, FILE# e DBARFIL é dependente da versão/PDB. Nome sem OWNER pode agrupar homônimos; TCH não é contagem exata de acessos de aplicação.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  DEFINE file_no = 4
  @file_blk_cnt.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  OBJECT, FILE#, Num blocks e Touches. São headers de buffer e soma de touch counters, não leituras físicas nem blocos únicos.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Referência não qualificada OBJ$ tornada SYS.OBJ$ para evitar resolução no schema incorreto. Não alterado o mapeamento interno sem homologação. Wrappers title80/title132 ausentes substituídos por TTITLE local. SPOOL direcionado a arquivo local, sem diretório rep_out ou variável DB externa; pode substituir relatório anterior.
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
col object heading 'Object Name'
col file# heading 'File|Number'
col touches heading 'Touches'
ttitle 'SGA Block Usage For File &&file_no'
spool file_blk_cnt.lst
select
b.name object,
a.dbarfil file#,
count(a.dbablk) "Num blocks",
sum(a.tch) "Touches"
from x$bh a, sys.obj$ b
where a.obj=b.dataobj# 
and a.tch>0
and a.file#=&&file_no
group by b.name,a.dbarfil
order by 4 desc
/
spool off
ttitle off
clear columns
undef file_no

