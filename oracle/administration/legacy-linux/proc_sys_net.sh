#!/bin/sh
# SCRIPT: proc_sys_net.sh (origem histórica: proc_sys_net.sql)
# CATEGORIA: Oracle / Administração / Linux legado
# STATUS: PROPOSTA PARA REVISÃO; NÃO HOMOLOGADO; NÃO EXECUTADO.
#
# OBJETIVO E FINALIDADE
# Reproduzir ajustes históricos de bdflush, disco IDE e buffers TCP utilizados
# em exemplos antigos de ambientes Oracle. Não é recomendação para Linux atual.
#
# FUNCIONAMENTO DETALHADO
# Escreve valores fixos em /proc/sys/vm/bdflush, buffers core rmem/wmem e TCP.
# Executa hdparm -m16 -c1 -d1 -a8 nos dispositivos /dev/hda e /dev/hdb.
# Mantém todos os valores e comandos históricos para análise explícita do PR.
#
# PRÉ-REQUISITOS E PRIVILÉGIOS
# Shell POSIX, utilitário hdparm, acesso root/equivalente e kernel/dispositivos
# compatíveis com cada opção. /proc e caminhos IDE antigos podem não existir.
# Não concede privilégios e não deve ser executado em produção.
#
# OBJETOS, VIEWS E PACOTES
# Não usa SQL/Oracle. Modifica /proc/sys e atributos de dispositivos de bloco.
#
# COMPATIBILIDADE E LIMITAÇÕES
# Exemplo de Linux antigo; bdflush e IDE hda/hdb são obsoletos em muitos hosts.
# Não traduzir parâmetros para kernels/storage atuais sem estudo separado.
# Sem set -e no original: falhas intermediárias não impedem comandos seguintes.
# Não há restauração de parâmetros nem persistência configurada após reboot.
#
# EXEMPLOS DE REVISÃO
# sh -n proc_sys_net.sh  # apenas sintaxe, não executa o conteúdo.
# Execução administrativa intencional não autorizada por este arquivo/PR;
# primeiro validar em VM descartável com dispositivos exclusivamente de teste.
#
# SAÍDA ESPERADA E INTERPRETAÇÃO
# echo redireciona dados e não imprime confirmação. hdparm mostra informações
# do dispositivo e resultados; erros indicam opção/caminho/permissão inválidos.
# Saída sem erro não comprova ganho de desempenho ou segurança dos ajustes.
#
# RISCOS E IMPACTOS OPERACIONAIS
# ALTO: altera configuração global do kernel e comportamento de discos.
# Opções de DMA/multisector/buffers podem causar instabilidade, indisponibilidade
# e perda de dados em hardware/driver incompatível. Valores não dimensionados.
#
# CORREÇÕES REALIZADAS
# Extensão .sql alterada para .sh: o conteúdo é shell. Comentário inicial --
# corrigido para # e shebang adicionado. Demais comandos preservados.
# Nenhuma alteração de valores ou alegação de modernização segura do tuning.
#
# AVISO DE RESPONSABILIDADE
# Os scripts são disponibilizados para fins técnicos, educacionais e administrativos.
# Antes da utilização, analise integralmente o código, compreenda seu funcionamento
# e realize testes em ambiente controlado, preferencialmente desenvolvimento ou
# homologação. Conteúdo fornecido no estado em que se encontra (AS IS), sem garantias
# de funcionamento, compatibilidade, desempenho ou adequação a ambientes específicos.
# A utilização ocorre por conta e risco de quem executa. Os mantenedores não assumem
# responsabilidade por danos, perdas de dados, indisponibilidade ou outros impactos
# decorrentes do uso, nos limites permitidos pela legislação aplicável.

# proc_sys_net

echo '100 5000 640 2560 150 30000 5000 1884 2'>/proc/sys/vm/bdflush
hdparm -m16 -c1 -d1 -a8 /dev/hda
hdparm -m16 -c1 -d1 -a8 /dev/hdb
echo '131071'>/proc/sys/net/core/rmem_default
echo '262143'>/proc/sys/net/core/rmem_max
echo '131071'>/proc/sys/net/core/wmem_default
echo '262143'>/proc/sys/net/core/wmem_max
echo '4096 65536 4194304'>/proc/sys/net/ipv4/tcp_wmem
echo '4096 87380 4194304'>/proc/sys/net/ipv4/tcp_rmem