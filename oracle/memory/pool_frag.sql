/*
===============================================================================
SCRIPT: pool_frag.sql
CATEGORIA: Oracle / memory
ORIGEM: Oracle Script Collection 2015 / _sga_internals_scripts/pool_frag.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Distribuir chunks livres do shared pool em buckets de tamanho históricos.

FUNCIONAMENTO DETALHADO
  Filtra X$KSMSP por instância e classe free; agrupa usando limiares 812/4012/65548 e calcula bytes, contagem, média e máximo.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Acesso administrativo autorizado às estruturas internas listadas; validar layout e custo antes de uso.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  SYS.X$KSMSP, USERENV

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Varredura de heap interno pode ser cara e causar contenção. Buckets não provam fragmentação patológica ou causa de ORA-04031; layout muda por versão.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @pool_frag.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Bucket, FREE_SPACE em bytes, FREE_CHUNKS, AVERAGE_SIZE e BIGGEST.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Fórmula integral preservada. Recíproco LOG original é matematicamente válido no domínio selecionado; sem alteração especulativa. 
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
select 
decode( 
sign(ksmchsiz - 812), 
-1, (ksmchsiz - 16) / 4, 
decode( 
sign(ksmchsiz - 4012), 
-1, trunc((ksmchsiz + 11924) / 64), 
decode( 
sign(ksmchsiz - 65548), 
-1, trunc(1/log(ksmchsiz - 11, 2)) + 238, 
254 
) 
) 
) bucket, 
sum(ksmchsiz) free_space, 
count(*) free_chunks, 
trunc(avg(ksmchsiz)) average_size, 
max(ksmchsiz) biggest 
from 
sys.x$ksmsp 
where 
inst_id = userenv('Instance') and 
ksmchcls = 'free' 
group by 
decode( 
sign(ksmchsiz - 812), 
-1, (ksmchsiz - 16) / 4, 
decode( 
sign(ksmchsiz - 4012), 
-1, trunc((ksmchsiz + 11924) / 64), 
decode( 
sign(ksmchsiz - 65548), 
-1, trunc(1/log(ksmchsiz - 11, 2)) + 238, 
254 
) 
) 
) 
/ 
