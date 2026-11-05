# Oracle Legacy Script Collection (2015) — análise técnica

> **Status: documentação preliminar, sem homologação.** Este diretório contém somente documentação elaborada a partir de uma coleção histórica de scripts Oracle. A documentação técnica está em desenvolvimento.

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

## Aviso de utilização e responsabilidade

Os scripts deste acervo destinam-se a fins técnicos, educacionais e administrativos. **Antes de executar qualquer script, leia integralmente o código e teste-o em ambiente controlado de desenvolvimento ou homologação**, com permissões mínimas, plano de recuperação e validação dos impactos.

O conteúdo é disponibilizado **no estado em que se encontra (AS IS)**, sem garantias de funcionamento, compatibilidade, desempenho ou adequação a um ambiente específico. **A execução é por conta e risco de quem utiliza.** O usuário é responsável por validar efeitos sobre dados, objetos, segurança, performance e disponibilidade. Os mantenedores não assumem responsabilidade por danos, perdas ou interrupções decorrentes do uso, nos limites permitidos pela legislação aplicável.

**Nenhum script foi homologado em banco Oracle nesta revisão estática.**

## Escopo e limitações

- A análise foi **estática**, sem conexão com Oracle Database e sem executar os scripts.
- **98 arquivos** receberam sinalização heurística de possíveis comandos DDL/DCL e **62** de DML. Essas contagens **não são classificações definitivas**: termos podem aparecer em comentários, strings ou SQL gerado.
- O aviso original descreve os scripts como avançados, dependentes do conhecimento do dicionário Oracle, fornecidos *as-is*, sem garantia.
- A presença de consultas a `SYS`, views `V$`/`GV$`, `DBA_HIST_*` e dicionário interno exige validação de privilégios, performance e versão.
- Referências a AWR/ASH requerem também verificar os **requisitos de licenciamento aplicáveis** antes da execução.
- Manter créditos e comentários históricos existentes ao revisar arquivos.

## Documentação

- [Casos revisados](REVIEWED_EXAMPLES.md): exemplos de leitura técnica, dependências e riscos observados.
- [Procedimento de revisão](REVIEW_PROCESS.md): checklist para documentar e validar um script antes de uso.
- A publicação dos scripts será feita por lotes após revisão técnica, categorização e documentação individual.

## Próximos passos

1. Priorizar scripts de diagnóstico somente leitura e revisar arquivo por arquivo.
2. Documentar objetivos, entradas, privilégios, dependências, riscos e exemplos de uso.
3. Corrigir ou modernizar scripts quando necessário, preservando uma cópia de referência.
4. Validar compatibilidade (11g/12c/19c/21c/23ai/26ai, conforme aplicável) **com evidência de testes**, não por inferência.

**Manutenção da documentação:** François Fiorino. Preservar os créditos históricos presentes nos arquivos.
