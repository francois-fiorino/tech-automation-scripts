/*
===============================================================================
SCRIPT: see_4031.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / misc_scripts/see_4031.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Consultar contadores internos de heaps associados a chunks e falhas ORA-04031.

FUNCIONAMENTO DETALHADO
  Lê seis campos KGH de X$KGHLU para instância corrente, com headings históricos.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Acesso administrativo autorizado aos objetos internos listados; validar por versão.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.X$KGHLU, USERENV

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Tabela interna e significado dos contadores variam por versão/heap. Não reproduz nem corrige ORA-04031 e não identifica causa sozinho; leitura pode ter custo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @see_4031.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Chunks recorrentes/transientes/liberados, operações de pin e campos de erro/tamanho.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código original preservado. 
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
column kghlurcr heading "RECURRENT|CHUNKS" 
column kghlutrn heading "TRANSIENT|CHUNKS" 
column kghlufsh heading "FLUSHED|CHUNKS" 
column kghluops heading "PINS AND|RELEASES" 
column kghlunfu heading "ORA-4031|ERRORS" 
column kghlunfs heading "LAST ERROR|SIZE" 

select 
kghlurcr, 
kghlutrn, 
kghlufsh, 
kghluops, 
kghlunfu, 
kghlunfs 
from 
sys.x$kghlu 
where 
inst_id = userenv('Instance') 
/ 
