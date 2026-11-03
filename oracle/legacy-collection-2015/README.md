# Oracle Legacy Script Collection (2015) — análise técnica

> **Status: documentação preliminar, sem homologação.** Este diretório contém somente documentação elaborada a partir de uma coleção histórica de scripts Oracle. **Os scripts originais de terceiros não estão publicados aqui.**

## Objetivo

Registrar um inventário técnico de uma coleção legada, explicar os riscos de utilização e orientar a revisão individual antes de qualquer adaptação ou eventual redistribuição.

O material recebido contém **697 arquivos**, dos quais **693 possuem extensão SQL**, distribuídos em **19 diretórios temáticos** (incluindo o diretório raiz). A origem indicada é uma coleção de 2015; **isso não determina compatibilidade com versões atuais do Oracle**.

## Organização identificada

| Área original | Arquivos | Escopo sugerido para revisão |
| --- | ---: | --- |
| misc_scripts | 219 | Utilitários diversos; classificar individualmente |
| _dba_admin_scripts | 82 | Administração e operações |
| _table_scripts | 61 | Metadados e estruturas de tabelas |
| _sga_internals_scripts | 53 | SGA e estruturas internas |
| _sql_scripts | 51 | Diagnóstico SQL |
| _rac_tuning_scripts | 39 | Ajustes e métricas RAC |
| _awr_scripts | 32 | Histórico e relatórios AWR |
| _disk_file_scripts | 31 | Arquivos e armazenamento |
| _index_scripts | 23 | Índices e análises |
| _rac_grid_scripts | 20 | RAC / Grid / métricas globais |
| _tablespace_scripts | 20 | Espaço e tablespaces |
| _ash_scripts | 17 | ASH e atividade de sessões |
| _wait_event_scripts | 15 | Eventos de espera |
| _security_scripts | 11 | Papéis, privilégios e segurança |
| _i_o_scripts | 10 | I/O |
| _segment_scripts | 6 | Segmentos |
| _os_scripts | 5 | Integração com o sistema operacional |
| _background_events_scripts | 1 | Processos/eventos em segundo plano |
| raiz | 1 | Avisos de uso da coleção |

## Escopo e limitações

- A análise foi **estática**, sem conexão com Oracle Database e sem executar os scripts.
- **98 arquivos** receberam sinalização heurística de possíveis comandos DDL/DCL e **62** de DML. Essas contagens **não são classificações definitivas**: termos podem aparecer em comentários, strings ou SQL gerado.
- O aviso original descreve os scripts como avançados, dependentes do conhecimento do dicionário Oracle, fornecidos *as-is*, sem garantia.
- A presença de consultas a `SYS`, views `V$`/`GV$`, `DBA_HIST_*` e dicionário interno exige validação de privilégios, performance e versão.
- Referências a AWR/ASH requerem também verificar os **requisitos de licenciamento aplicáveis** antes da execução.
- O direito de **redistribuir os arquivos originais não foi comprovado**. Preservar a autoria e verificar licença/permissão expressa antes de publicação.

## Documentação

- [Casos revisados](REVIEWED_EXAMPLES.md): exemplos de leitura técnica, dependências e riscos observados.
- [Procedimento de revisão](REVIEW_PROCESS.md): checklist para documentar e validar um script antes de uso.
- O inventário integral e os scripts originais permanecem fora deste repositório público até definição de permissão de publicação.

## Próximos passos

1. Determinar a titularidade e as condições de redistribuição da coleção.
2. Priorizar consultas somente leitura e revisar arquivo por arquivo.
3. Criar **implementações próprias** quando fizer sentido, com documentação e testes em ambientes controlados.
4. Validar compatibilidade (11g/12c/19c/21c/23ai/26ai, conforme aplicável) **com evidência de testes**, não por inferência.

**Manutenção da documentação:** François Fiorino. O crédito dos scripts de terceiros não é transferido por esta análise.
