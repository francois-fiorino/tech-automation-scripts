/*
===============================================================================
SCRIPT: lock.sql
CATEGORIA: Oracle / troubleshooting
ORIGEM: Oracle Script Collection 2015 / _dba_admin_scripts/lock.sql
REVISÃO: 2026-11-03; análise estática individual, sem execução em banco Oracle.

OBJETIVO E FINALIDADE
  Relacionar detentores de locks de objetos a sessões locais aguardando a mesma transação TX.

FUNCIONAMENTO DETALHADO
  PL/SQL consulta V$LOCKED_OBJECT/DBA_OBJECTS e procura locks TX solicitados por XIDUSN/XIDSLOT/XIDSQN completos.

PRÉ-REQUISITOS E PRIVILÉGIOS
  SQL*Plus ou SQLcl; conexão ao banco/container que se deseja diagnosticar.
  SELECT nos objetos/views listados abaixo, por grants específicos ou role de catálogo apropriada. EXECUTE em DBMS_OUTPUT e SERVEROUTPUT habilitado (o script o configura).
  Não requer AWR/ASH nesta implementação.

OBJETOS, VIEWS E PACOTES
  V$LOCKED_OBJECT, DBA_OBJECTS, V$LOCK, DBMS_OUTPUT

COMPATIBILIDADE CONHECIDA E LIMITAÇÕES
  Não detecta todos os bloqueios TM, deadlocks ou cadeias RAC. Várias linhas por objeto/transação podem repetir detentores. Dados voláteis e ciclos de consulta podem ter custo.
  Não homologado em versões específicas; validar dicionário e plano em laboratório.

EXEMPLO DE EXECUÇÃO
  @lock.sql
  Executar a partir do diretório do arquivo, ou informar seu caminho completo.
  Variáveis de substituição devem receber apenas valores controlados pelo DBA.

SAÍDA ESPERADA E INTERPRETAÇÃO
  Holding Session, objeto e sessões com REQUEST>0 para o mesmo recurso TX.

RISCOS E IMPACTOS OPERACIONAIS
  Consulta de diagnóstico; não executa DDL/DML nem altera parâmetros do banco.
  Leituras do dicionário consomem recursos; avaliar custo antes de uso repetido.
  Relatórios podem expor nomes de usuários, sessões ou caminhos de arquivos.
  Comandos SET/COLUMN/BREAK/TTITLE podem alterar a apresentação da sessão cliente.
  Quando houver SPOOL, o arquivo local pode ser sobrescrito: proteger sua saída.

CORREÇÕES REALIZADAS E PENDÊNCIAS
  ID1 completo e TYPE/REQUEST adicionados: ID2 sozinho podia associar transações distintas. Rótulo Blocking trocado por Holding quando não há prova de espera. 
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
clear screen
set serveroutput on


BEGIN
dbms_output.enable(1000000);
for do_loop in (select session_id, a.object_id, xidsqn, xidusn, xidslot, oracle_username, b.owner owner, 
                b.object_name object_name, b.object_type object_type
                FROM v$locked_object a, dba_objects b
			    WHERE xidsqn != 0
				and b.object_id = a.object_id)
loop
    dbms_output.put_line('.');
    dbms_output.put_line('Holding Session   : '||do_loop.session_id);
	dbms_output.put_line('Object (Owner/Name): '||do_loop.owner||'.'||do_loop.object_name);
    dbms_output.put_line('Object Type        : '||do_loop.object_type);
	
	for next_loop in (select sid from v$lock
	                where type='TX' and request>0
                    and id1=do_loop.xidusn*65536+do_loop.xidslot
                    and id2 = do_loop.xidsqn
					and sid != do_loop.session_id)
				
	LOOP
	     dbms_output.put_line('Sessions being blocked   :  '||next_loop.sid);
    end loop;		 
end loop;

END;
/

