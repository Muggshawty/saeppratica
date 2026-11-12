-- create table colaboradores(
-- id serial primary key,
-- nome varchar(200) not null,
-- email varchar(200) unique not null,
-- senha varchar(200) unique not null,
-- cargo varchar(100) not null,
-- ativo boolean default true not null
-- ); 

-- create table projetos(
-- id serial primary key,
-- nome varchar (200) not null,
-- descricao text,
-- data_inicio date not null,
-- data_prevista date not null,
-- status varchar(200) not null
-- );

-- create table demandas(
-- id serial primary key,
-- id_projeto int references projetos(id) not null,
-- titulo varchar(200) not null,
-- descricao text,
-- prioridade varchar(20) not null,
-- status varchar(200) not null,
-- prazo date
-- );

-- create table tarefas(
-- id serial primary key,
-- id_demanda int references demandas(id) not null,
-- descricao text,
-- status varchar(100) not null,
-- data_inicio date,
-- data_fim_prevista date,
-- data_conclusao date
-- );

-- create table atribuicoes(
-- id serial primary key,
-- id_tarefa int references tarefas(id),
-- id_colaborador int references colaboradores(id),
-- papel varchar(200) not null,
-- data_atribuicao timestamp default current_timestamp not null
-- );

-- create table historico_atividades(
-- id serial primary key,
-- id_tarefa int references tarefas(id),
-- id_colaborador int references colaboradores(id),
-- acao varchar(200) not null,
-- criado_em timestamp default current_timestamp
-- );

-- create or replace view vw_painel_principal as
-- select
--     c.nome                as colaborador,
--     d.titulo              as titulo_tarefa,
--     d.prioridade          as categoria,
--     t.data_fim_prevista   as prazo_entrega,
--     t.status              as status_atividade
-- from atribuicoes a
-- join colaboradores c on c.id = a.id_colaborador
-- join tarefas t       on t.id = a.id_tarefa
-- join demandas d      on d.id = t.id_demanda;


-- create or replace function fn_buscar_colaboradores(p_termo text)
-- returns table (
--     id     int,
--     nome   varchar,
--     email  varchar,
--     cargo  varchar,
--     ativo  boolean
-- )
--
-- as $$
-- begin
--     return query
--     select c.id, c.nome, c.email, c.cargo, c.ativo
--     from colaboradores c
--     where c.nome  ilike '%' || p_termo || '%'
--        or c.email ilike '%' || p_termo || '%'
--     order by c.nome;
-- end;
-- $$ language plpgsql;


-- create or replace function fn_validar_tarefa()
-- returns trigger
-- as $$
-- declare
--     v_ativo boolean;
-- begin
--     if new.id_tarefa is null or new.id_colaborador is null then
--         raise exception 'a tarefa deve estar vinculada a um colaborador.';
--     end if;

--     select ativo into v_ativo
--     from colaboradores
--     where id = new.id_colaborador;

--     if v_ativo is null then
--         raise exception 'colaborador % nao encontrado.', new.id_colaborador;
--     elsif v_ativo = false then
--         raise exception 'colaborador % esta inativo e nao pode receber tarefas.', new.id_colaborador;
--     end if;

--     update tarefas
--     set data_inicio = coalesce(data_inicio, current_date)
--     where id = new.id_tarefa;

--     insert into historico_atividades (id_tarefa, id_colaborador, acao)
--     values (new.id_tarefa, new.id_colaborador,
--             'tarefa vinculada ao colaborador (papel: ' || new.papel || ')');

--     return new;
-- end;
-- $$ language plpgsql;

-- create trigger trg_validar_tarefa
-- before insert on atribuicoes
-- for each row
-- execute function fn_validar_tarefa();


-- create or replace view vw_cronograma_prazos as
-- select
--     t.id                                   as id_tarefa,
--     d.titulo                               as demanda,
--     t.descricao                            as tarefa,
--     t.status                               as status_tarefa,
--     t.data_fim_prevista                    as prazo_final,
--     (t.data_fim_prevista - current_date)   as dias_restantes,
--     c.nome                                 as responsavel
-- from tarefas t
-- join demandas d           on d.id = t.id_demanda
-- left join atribuicoes a   on a.id_tarefa = t.id
-- left join colaboradores c on c.id = a.id_colaborador
-- order by t.data_fim_prevista asc nulls last;
