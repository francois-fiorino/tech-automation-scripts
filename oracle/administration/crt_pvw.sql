/*
===============================================================================
SCRIPT: crt_pvw.sql
CATEGORIA: Oracle / administration
ORIGEM: Oracle Script Collection 2015 / misc_scripts/CRT_PVW.SQL
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar view PROC_COUNT com contagem de registros de fonte por objeto.

FUNCIONAMENTO DETALHADO
  CREATE VIEW sobre DBA_SOURCE agrupado por OWNER/NAME/TYPE.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios de criação/alteração/execução e SELECT DIRETO conforme LIMITAÇÕES.
  Grants por role podem não valer para views/procedimentos armazenados.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  DBA_SOURCE; nova view PROC_COUNT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Requer CREATE VIEW e SELECT direto em DBA_SOURCE. DDL faz commits implícitos; falha se view existir. Contagem não é tamanho em bytes nem cobre código externo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @crt_pvw.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  View criada; SELECT posterior retorna owner/nome/tipo/contagem.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PROPOSTA DE REVISÃO: o código pode modificar objetos, dados, jobs,
  arquivos ou sessão, conforme FUNCIONAMENTO. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Definição original preservada; nenhuma DDL executada. 
  Revisão estática somente; implantação depende de testes e aprovação do PR.
  Comentários e créditos históricos preservados abaixo.

REVISÃO COMPLEMENTAR 041 — 04/11/2026
  Correções e melhorias: CREATE VIEW integral preservado.
  Limitações e pendências: Conta registros de DBA_SOURCE, incluindo texto wrapped, não linhas físicas de arquivo/bytes ou qualidade. CREATE simples falha se existe e DDL confirma transação.
  Homologação necessária: Procedure e package/body separados, source ausente e view existente; grants diretos para compilar.
  Parâmetros e execução: contratos acima e no corpo; só ambiente controlado.
  Compatibilidade: nenhuma versão adicional homologada nesta revisão.
  Validação: leitura integral e comparação estática; sem compilação/execução
  Oracle, Windows, alteração de privilégio ou gravação de arquivo no servidor.

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
create view proc_count as
select owner,name,type,count(*) lines from dba_source
group by owner,name,type
/
