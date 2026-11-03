REM ===============================================================================
REM SCRIPT: batch_substitute.bat
REM CATEGORIA: Oracle / administration/windows
REM ORIGEM: Oracle Script Collection 2015 / _awr_scripts/awr_sqlstat_deltas_detail.sql
REM REVISÃO: 2026-11-03; análise estática individual, sem execução em Windows ou Oracle.
REM 
REM OBJETIVO E FINALIDADE
REM   Substituir trechos de texto em arquivo usando batch do Windows; não é SQL/AWR.
REM 
REM FUNCIONAMENTO DETALHADO
REM   CMD percorre arquivo com FOR/F e FIND, usa CALL SET para substituir e emite linhas; argumentos são texto antigo, novo e arquivo.
REM 
REM PRÉ-REQUISITOS E PRIVILÉGIOS
REM   Windows CMD.exe em ambiente descartável. Não utilizar SQL*Plus/SQLcl.
REM   Permissão para ler o arquivo de entrada e criar a saída no Windows.
REM   Nenhum privilégio Oracle é necessário.
REM   Nenhuma consulta AWR/ASH/Oracle é realizada por este batch.
REM 
REM OBJETOS, VIEWS E PACOTES
REM   Windows CMD.exe, TYPE, FIND, FINDSTR; origem/créditos dostips.com
REM 
REM COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
REM   CALL e reinterpretação de texto permitem execução de metacaracteres do conteúdo/argumentos. Não processar arquivos não confiáveis; aspas/Unicode/linhas vazias e %% exigem testes. Não utilizar em banco Oracle.
REM   Não homologado em versões específicas; validar dicionário e plano em laboratório.
REM 
REM EXEMPLO DE EXECUÇÃO
REM   Revisão em Windows isolado: cmd /d /c batch_substitute.bat ANTIGO NOVO origem.txt > resultado.txt
REM   Executar a partir do diretório do arquivo, ou informar seu caminho completo.
REM   Variáveis de substituição devem receber apenas valores controlados pelo DBA.
REM 
REM SAÍDA ESPERADA E INTERPRETAÇÃO
REM   Texto substituído na saída; redirecionamento cria arquivo de resultado.
REM 
REM RISCOS E IMPACTOS OPERACIONAIS
REM   ALTO RISCO / PROPOSTA DE REVISÃO: o código pode modificar objetos, dados, jobs,
REM   arquivos ou sessão, conforme FUNCIONAMENTO. Não executar em produção.
REM   Leitura e processamento de arquivos consomem CPU e I/O local.
REM   Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
REM   CMD reinterpreta expansões de variáveis e metacaracteres; revisar toda a entrada.
REM   Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.
REM 
REM CORREÇÕES REALIZADAS E PENDÊNCIAS
REM   Extensão .sql corrigida para .bat; GOTO:EOF que era incondicional após & movido para bloco IF, permitindo processar argumentos. Créditos e loop preservados. 
REM   Revisão estática somente; implantação depende de testes e aprovação do PR.
REM   Comentários e créditos históricos preservados abaixo.
REM 
REM Revisão complementar 037 (2026-11-03): corpo CMD preservado; reinterpretação de CALL permanece bloqueio para entrada não confiável. Sem teste Windows. Casos necessários: arquivo com espaços no caminho, Unicode, linhas vazias, %, !, &, |, redirecionamento e aspas. Não aprovado para implantação.
REM
REM AVISO DE RESPONSABILIDADE
REM Os scripts são disponibilizados para fins técnicos, educacionais e administrativos.
REM Antes da utilização, analise integralmente o código, compreenda seu funcionamento
REM e realize testes em ambiente controlado, preferencialmente desenvolvimento ou
REM homologação. Conteúdo fornecido no estado em que se encontra (AS IS), sem garantias
REM de funcionamento, compatibilidade, desempenho ou adequação a ambientes específicos.
REM A utilização ocorre por conta e risco de quem executa. Os mantenedores não assumem
REM responsabilidade por danos, perdas de dados, indisponibilidade ou outros impactos
REM decorrentes do uso, nos limites permitidos pela legislação aplicável.
REM ===============================================================================

echo off
REM -- Prepare the Command Processor --
SETLOCAL ENABLEEXTENSIONS
SETLOCAL DISABLEDELAYEDEXPANSION

::BatchSubstitude - parses a File line by line and replaces a substring"
::syntax: BatchSubstitude.bat OldStr NewStr File
::          OldStr [in] - string to be replaced
::          NewStr [in] - string to replace with
::          File   [in] - file to be parsed
:$changed 20100115
:$source http://www.dostips.com
if "%~1"=="" (
    findstr "^::" "%~f0"
    goto :eof
)
for /f "tokens=1,* delims=]" %%A in ('"type %3|find /n /v """') do (
    set "line=%%B"
    if defined line (
        call set "line=echo.%%line:%~1=%~2%%"
        for /f "delims=" %%X in ('"echo."%%line%%""') do %%~X
    ) ELSE echo.
)
