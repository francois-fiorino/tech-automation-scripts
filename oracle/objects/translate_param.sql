/*
===============================================================================
SCRIPT: translate_param.sql
CATEGORIA: Oracle / objects
ORIGEM: Oracle Script Collection 2015 / misc_scripts/translate_param.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Criar função que converte valor de parâmetro com sufixo K/M/G em número de bytes.

FUNCIONAMENTO DETALHADO
  Consulta V$PARAMETER, identifica multiplicador por LTRIM/DECODE e parte numérica por RTRIM; multiplica e retorna.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  Privilégios administrativos e grants DIRETOS conforme limitações de cada arquivo.
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$PARAMETER; função TRANSLATE_PARAM

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  CREATE PROCEDURE/SELECT direto. Algoritmo legado não cobre decimal/T/strings/unidades gerais; overflow declarado mas não tratado especificamente. Não modifica parâmetro. Verificar tipo normalizado na view.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  Somente laboratório: @translate_param.sql; testar valores sem sufixo e K/M/G.
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Número convertido ou NULL em NO_DATA_FOUND/VALUE_ERROR.

RISCOS E IMPACTOS OPERACIONAIS
  ALTO RISCO / PR DE REVISÃO: efeitos administrativos, dados, arquivos ou sessão
  conforme descritos. Não executar em produção.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  Código preservado; cópia TRANSLATE_SPS será mapeada após publicação, sem duplicar função homônima. 
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
create or replace FUNCTION translate_param( p_param_name IN v$parameter.name%TYPE )
RETURN NUMBER
AS

  l_multiplier  NUMBER;
  l_raw_value  NUMBER;
  l_final_value  NUMBER;
  
  numeric_overflow  EXCEPTION;
  PRAGMA  exception_init(numeric_overflow, -1426);

BEGIN

  SELECT decode( ltrim(upper(value),'0123456789'),
                 'G',  1024*1024*1024,
                 'M',  1024*1024,
                 'K',  1024,
                 NULL, 1,
                       0 ) AS multiplier,
         rtrim(upper(value), 'KMG') AS raw_value
    INTO l_multiplier,
         l_raw_value
    FROM v$parameter
   WHERE name = p_param_name;

  l_final_value := l_multiplier * l_raw_value;

  RETURN l_final_value;

EXCEPTION
  WHEN no_data_found OR
       value_error THEN
    RETURN to_number(NULL);
  WHEN others THEN
    RAISE;

END translate_param;
/

